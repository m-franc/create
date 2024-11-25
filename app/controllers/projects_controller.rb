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
    @project = Project.find(params[:id])
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
      flash[:notice] = "Project saved 💾"
      redirect_to @project, notice: 'Project created ✅'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /projects/:id/edit
  # Formulaire pour modifier un projet existant
  def edit
    @project = Project.find(project_params)
    if @project.save
      flash[:notice] = "Project edited 💾"
    else
      render :new, status: :unprocessable_entity
    end
  end


  def set_project
    @project = Project.find(params[:id])
  end


  private
  # Filtre les paramètres autorisés pour un projet
  def project_params
    params.require(:project).permit(:name, :description, :start_date, :end_date, :status)
  end
end
  # PATCH/PUT /projects/:id
