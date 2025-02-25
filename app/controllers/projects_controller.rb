class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :accept, :decline]
  
  # GET /projects
  def index
    @projects_user = ProjectUser.where(user: current_user)
    @projects = Project.where(user: current_user)
    @user = current_user
  end

  # GET /projects/:id
  def show
    @project = Project.find(params[:id])
    @task = Task.new
    @note = Note.new
    @document = Document.new
    @tasks = @project.tasks.order(created_at: :desc)
    @joined_users = @project.joined_users
    @notes = @project.notes.includes(:user).order(created_at: :desc)
    @documents = @project.documents.includes(:user)
    @folders = @project.documents.pluck(:folder_name).uniq
    @documents = @project.documents

    # # Debug logging
    # Rails.logger.debug "Project: #{@project.inspect}"
    # Rails.logger.debug "Notes count: #{@notes.count}"

    @documents = @project.documents.includes(:user)
    @joined_users = @project.joined_users
  end

  # GET /projects/new
  def new
    @project = Project.new
    if params[:query].present?
      @users = User.search_by_name_and_email(params[:query])
    else
      @users = User.all
    end
    @note = @project.notes.new
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.user = current_user
    @joined_users = @project.joined_users

    dates = params["project"]["starting_date"].split("to").map(&:strip)
    @project.starting_date = dates[0]
    @project.end_date = dates[1]

    if @project.save
      init_status_project_users(@project, "0")
      if params[:project][:image].present?
        @project.image.attach(params[:project][:image])
      end
      flash[:notice] = "Project created ✅"
      redirect_to project_path(@project)
    else
      render :new
    end

    # @note = @project.notes.new(note_params)
  # if @note.save
  #   redirect_to project_notes_path(@project), notice: 'Note was successfully created.'
  # else
  #   render :new
  # end
  end

  # GET /projects/:id/edit
  def edit
    @project = Project.find(params[:id])
  end

  # PATCH/PUT /projects/:id
  def update
    if @project.update(project_params)
      if params[:project][:image].present?
        @project.image.attach(params[:project][:image])
      end
      flash[:notice] = "Project successfully updated 💾"
      redirect_to project_path(@project)
    else
      flash[:alert] = "Unable to update the project. Please fix the errors."
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  def accept
    @project = Project.find(params[:id])
    project_user = ProjectUser.find_by(user: current_user, project: @project)
    project_user.update(status: "1")
    flash[:notice] = "Project joined !"
    redirect_to projects_path
  end

  def decline
    flash[:notice] = "Project not joined 🗑️"
    redirect_to projects_path
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :location, :status, :notes, :description, :image, :starting_date, :end_date, joined_user_ids: [])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end

  def init_status_project_users(project, value)
    project.joined_users.each do |joined_user|
      project_user = ProjectUser.find_by(user: joined_user, project: project)
      project_user.update!(status: value)
    end
  end
end
