class DocumentsController < ApplicationController
  before_action :set_project
  before_action :set_document, only: [:destroy, :download]
  before_action :check_project_member
  before_action :check_owner, only: [:destroy]
  before_action :store_return_to, only: [:destroy]

  def index
    @folders = Document.where(project: @project, user: current_user)
                       .pluck(:folder_name)
                       .uniq

    @documents = if current_user == @project.user
                  @project.documents
                else
                  @project.documents.where(user: current_user)
                end
  end

  def new
    @document = @project.documents.new
  end

  def create
    @document = @project.documents.new(document_params)
    @document.user = current_user

    if params[:document][:file].present?
      # Debug logs
      Rails.logger.debug "Original filename: #{params[:document][:file].original_filename}"

      # Sauvegarder l'extension du fichier original
      original_filename = params[:document][:file].original_filename
      @document.file_extension = File.extname(original_filename).delete('.')

      # Debug logs
      Rails.logger.debug "Extracted extension: #{@document.file_extension}"

      folder_path = "projects/#{@project.id}/#{@document.folder_name}"
      upload = Cloudinary::Uploader.upload(
        params[:document][:file],
        folder: folder_path,
        resource_type: 'auto'
      )
      @document.cloudinary_id = upload['public_id']
    end

    if @document.save
      # Debug logs
      if params[:redirect_tab] == 'document'
        redirect_to project_path(@project, tab: 'document'), notice: 'Document was successfully uploaded.'
      else
        redirect_to project_path(@project), notice: 'Document was successfully uploaded.'
      end
    else
      render :new
    end
  end

  def destroy
    if @document.cloudinary_id.present?
      Cloudinary::Uploader.destroy(@document.cloudinary_id)
    end
    @document.destroy
    redirect_to project_path(@project, anchor: 'document-tab-pane'), notice: 'Document was successfully deleted.'
  end

  def download
    if @document.cloudinary_id.present?
      begin
        # Get file info from Cloudinary
        info = Cloudinary::Api.resource(@document.cloudinary_id)

        # Get the file
        response = Cloudinary::Downloader.download(@document.cloudinary_id)

        # Build filename with extension
        extension = info['format']
        filename = "#{@document.name}.#{extension}"

        # Send file to browser without redirecting
        send_data response,
                filename: filename,
                disposition: 'attachment',
                type: info['resource_type']
        return
      rescue => e
        Rails.logger.error "Cloudinary error: #{e.message}"
        redirect_to project_path(@project, anchor: 'document-tab-pane'), alert: 'Error downloading the document.'
      end
    else
      redirect_to project_path(@project, anchor: 'document-tab-pane'), alert: 'Document not found.'
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_document
    @document = @project.documents.find(params[:id])
  end

  def check_project_member
    unless @project.user == current_user || @project.joined_users.include?(current_user)
      redirect_to projects_path, alert: 'You are not authorized to access this project.'
    end
  end

  def check_owner
    unless @project.user == current_user
      redirect_to project_documents_path(@project), alert: 'Only project owner can perform this action.'
    end
  end

  def store_return_to
    session[:return_to] = params[:return_to] if params[:return_to].present?
  end

  def document_params
    # Assurez-vous que file_extension est inclus dans les paramètres autorisés
    params.require(:document).permit(:name, :folder_name, :file, :file_extension)
  end
end
