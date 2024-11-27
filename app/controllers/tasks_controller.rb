class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, except: [:index, :new, :create]

  def index
    project_user_ids = @project.project_users.pluck(:id)
    @tasks = Task.where(project_user_id: project_user_ids)
  end

  def new
    @task = Task.new
  end

  def create
    project_user = @project.project_users.find_by(user: current_user)
    @task = Task.new(task_params)
    @task.project_user = project_user

    if @task.save
      flash[:notice] = "Task created ✅"
      redirect_to project_tasks_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = @task.project_user.user
    @project = @task.project
  end

  def edit
  end

  def update
    if @task.update(task_params)
      flash[:notice] = "Task successfully updated 💾"
      redirect_to project_tasks_path(@project)
    else
      flash[:alert] = "Unable to update the task. Please fix the errors."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_tasks_path(@project), notice: 'Task was successfully deleted.'
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :location, :date, :status, :deadline, :priority)
  end

  def set_task
    @task = Task.find(params[:id]) if params[:id].present?
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
