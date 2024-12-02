class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  def index
    @projects = Project.all

  end

  # GET /projects/:id
  def show
    @joined_users = @project.joined_users
    @project = Project.find(params[:id])
    @documents = @project.documents
    @tasks = @project.tasks.includes(:user).order(deadline: :asc)
    @notes = @project.notes.includes(:user).order(created_at: :desc).limit(3)
    @note = Note.new
    @document = Document.new
    @folders = @project.documents.pluck(:folder_name).uniq

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

    if @project.save
      if params[:project][:image].present?
        @project.image.attach(params[:project][:image])
      end
      flash[:notice] = "Project created ✅"
      redirect_to @project
    else
      render :new
    end

    @note = @project.notes.new(note_params)
  if @note.save
    redirect_to project_notes_path(@project), notice: 'Note was successfully created.'
  else
    render :new
  end
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
      redirect_to @project
    else
      flash[:alert] = "Unable to update the project. Please fix the errors."
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  def destroy
    @project.destroy
    flash[:notice] = "Project deleted 🗑️"
    redirect_to projects_path
  end





  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :location, :status, :notes, :date, :description, :image, joined_user_ids: [])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
