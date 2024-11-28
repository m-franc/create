class SearchesController < ApplicationController
  def index
    @query = params[:query].to_s.strip
    
    if @query.present?
      search_pattern = "%#{@query.split('').join('%')}%"
      
      # Debug logs pour la recherche d'utilisateurs
      Rails.logger.debug "Index - Recherche d'utilisateurs avec pattern: #{search_pattern}"
      @users = User.where("LOWER(email) LIKE LOWER(?) OR LOWER(username) LIKE LOWER(?)", 
                         search_pattern, search_pattern)
      Rails.logger.debug "Index - Nombre d'utilisateurs trouvés: #{@users.count}"
      Rails.logger.debug "Index - SQL généré: #{@users.to_sql}"
      
      @projects = accessible_projects
        .where("LOWER(projects.name) LIKE LOWER(?) OR LOWER(projects.description) LIKE LOWER(?)", 
               search_pattern, search_pattern)
      
      @documents = accessible_documents
        .where("LOWER(documents.name) LIKE LOWER(?) OR LOWER(documents.folder_name) LIKE LOWER(?)", 
               search_pattern, search_pattern)
      
      @notes = accessible_notes
        .where("LOWER(notes.title) LIKE LOWER(?) OR LOWER(notes.content) LIKE LOWER(?)", 
               search_pattern, search_pattern)
      
      @tasks = accessible_tasks
        .where("LOWER(tasks.name) LIKE LOWER(?) OR LOWER(tasks.description) LIKE LOWER(?)", 
               search_pattern, search_pattern)

      @grouped_results = {
        "Projet" => @projects,
        "Document" => @documents,
        "Note" => @notes,
        "Task" => @tasks,
        "Utilisateur" => @users
      }.reject { |_, items| items.empty? }
    else
      @grouped_results = {}
    end
  end

  def suggestions
    query = params[:query].to_s.strip
    return render json: { suggestions: [] } if query.empty?

    suggestions = []
    search_pattern = "%#{query.split('').join('%')}%"

    # Projets
    accessible_projects
      .where("LOWER(projects.name) LIKE LOWER(?) OR LOWER(projects.description) LIKE LOWER(?)", 
             search_pattern, search_pattern)
      .limit(5)
      .each do |project|
        suggestions << {
          text: project.name,
          type: 'Projet',
          url: project_path(project),
          context: truncate(project.description, length: 50)
        }
      end

    # Documents
    Document.where(user_id: current_user.id)
      .where("LOWER(documents.name) LIKE LOWER(?) OR LOWER(documents.folder_name) LIKE LOWER(?)", 
             search_pattern, search_pattern)
      .limit(5)
      .each do |doc|
        suggestions << {
          text: doc.name,
          type: 'Document',
          url: project_documents_path(doc.project),  
          download_url: download_project_document_path(doc.project, doc),  
          context: doc.folder_name.present? ? "Dans le dossier: #{doc.folder_name}" : "Dans: #{doc.project.name}"
        }
      end

    # Notes
    accessible_notes
      .where("LOWER(notes.title) LIKE LOWER(?) OR LOWER(notes.content) LIKE LOWER(?)", 
             search_pattern, search_pattern)
      .limit(5)
      .each do |note|
        suggestions << {
          text: note.title,
          type: 'Note',
          url: project_note_path(note.project, note),
          context: truncate(note.content)
        }
      end

    # Tâches
    accessible_tasks
      .where("LOWER(tasks.name) LIKE LOWER(?) OR LOWER(tasks.description) LIKE LOWER(?)", 
             search_pattern, search_pattern)
      .limit(5)
      .each do |task|
        project = task.project
        suggestions << {
          text: task.name,
          type: 'Tâche',
          url: project_path(project),
          context: truncate(task.description)
        }
      end

    # Utilisateurs
    Rails.logger.debug "Recherche d'utilisateurs avec pattern: #{search_pattern}"
    users = User.where("LOWER(email) LIKE LOWER(?) OR LOWER(username) LIKE LOWER(?)", 
                      search_pattern, search_pattern)
    Rails.logger.debug "Nombre d'utilisateurs trouvés: #{users.count}"
    Rails.logger.debug "SQL généré: #{users.to_sql}"
    
    users.limit(5).each do |user|
      Rails.logger.debug "Utilisateur trouvé: #{user.email} (#{user.username})"
      suggestions << {
        text: user.username.presence || user.email,
        type: 'Utilisateur',
        url: user_path(user),
        context: user.username ? "Email: #{user.email}" : nil
      }
    end

    # Trier les suggestions par pertinence
    suggestions = sort_suggestions_by_relevance(suggestions, query)
    suggestions = suggestions.first(15)

    render json: { suggestions: suggestions }
  end

  private

  def accessible_projects
    Project.left_joins(:project_users)
           .where("projects.user_id = ? OR project_users.user_id = ?", 
                  current_user.id, current_user.id)
           .distinct
  end

  def accessible_documents
    Document.where(user_id: current_user.id)
  end

  def accessible_notes
    Note.joins(:project)
        .joins("LEFT JOIN project_users ON project_users.project_id = projects.id")
        .where("projects.user_id = ? OR project_users.user_id = ?", 
               current_user.id, current_user.id)
        .distinct
  end

  def accessible_tasks
    Task.joins(:project)
        .joins("LEFT JOIN project_users ON project_users.project_id = projects.id")
        .where("projects.user_id = ? OR project_users.user_id = ?", 
               current_user.id, current_user.id)
        .distinct
  end

  def truncate(text, length: 50)
    return "" if text.blank?
    text.length > length ? "#{text[0...length]}..." : text
  end

  def find_matching_content(content, query)
    return nil if content.blank?
    
    # Rechercher le contexte autour du mot correspondant
    content.downcase.split(/[[:space:]]+/).each_with_index do |word, index|
      if word.include?(query.downcase)
        start_idx = [index - 3, 0].max
        end_idx = [index + 3, content.split(/[[:space:]]+/).length - 1].min
        context_words = content.split(/[[:space:]]+/)[start_idx..end_idx]
        return "...#{context_words.join(' ')}..."
      end
    end
    nil
  end

  def sort_suggestions_by_relevance(suggestions, query)
    suggestions.sort_by do |suggestion|
      score = 0
      
      # Bonus si le texte commence par la requête
      if suggestion[:text].downcase.start_with?(query.downcase)
        score -= 15
      end
      
      # Bonus si le texte contient exactement la requête
      if suggestion[:text].downcase.include?(query.downcase)
        score -= 10
      end
      
      # Bonus basé sur la position de la correspondance
      match_position = suggestion[:text].downcase.index(query.downcase)
      score += (match_position || 100)
      
      # Bonus pour les correspondances de type
      if query.downcase.start_with?('n') && suggestion[:type] == 'Note'
        score -= 5
      elsif query.downcase.start_with?('d') && suggestion[:type] == 'Document'
        score -= 5
      elsif query.downcase.start_with?('p') && suggestion[:type] == 'Projet'
        score -= 5
      elsif query.downcase.start_with?('t') && suggestion[:type] == 'Tâche'
        score -= 5
      elsif query.downcase.start_with?('u') && suggestion[:type] == 'Utilisateur'
        score -= 5
      end
      
      score
    end
  end
end
