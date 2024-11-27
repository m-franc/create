class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/:id
  def show
    @project = Project.find(params[:id])
    @joined_users = @project.users
  end

  # GET /projects/new
  def new
    @project = Project.new
    if params[:query].present?
      @users = User.search_by_name_and_email(params[:query])
    else
      @users = User.all
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.user = current_user

    if @project.save!
      flash[:notice] = "Project created ✅"
      redirect_to @project
    else
      raise
    end
  end

  # GET /projects/:id/edit
  def edit
  end

  # PATCH/PUT /projects/:id
  def update
    if @project.update(project_params)
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
    @project = Project.find_by(id: params[:id])
    redirect_to projects_path, alert: 'Project not found.' if @project.nil?
  end

  def project_params
    params.require(:project).permit(:name, :location, :status, :notes, :date, :image, :description, joined_user_ids: [])
  end



end
