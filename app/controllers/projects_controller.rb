class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]


  # GET /projects
  # Affiche une liste de tous les projets
  def index
    @projects = Project.all
  end

  # GET /projects/:id
  # Affiche les détails d'un projet spécifique
  def show
    # `@project` est déjà défini via le callback `set_project`
  end

  # GET /projects/new
  # Formulaire pour créer un nouveau projet
  def new
    @project = Project.new
  end

  # POST /projects
  # Crée un nouveau projet
  def create
    @project = Project.new(project_params)
    if @project.save
      flash[:notice] = "Project created ✅"
      redirect_to @project
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /projects/:id/edit
  # Formulaire pour modifier un projet existant
  def edit
    # `@project` est déjà défini via le callback `set_project`
  end

  # PATCH/PUT /projects/:id
  # Met à jour un projet existant
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
  # Supprime un projet existant
  def destroy
    @project.destroy
    flash[:notice] = "Project deleted 🗑️"
    redirect_to projects_path
  end

  private

  # Définit le projet à manipuler
  def set_project
    def set_project
      @project = Project.find(params[:id]) if params[:id].present?
    end
  end

  # Filtre les paramètres autorisés pour un projet
  def project_params
    params.require(:project).permit(:name, :description, :start_date, :end_date, :status)
  end
end
