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
<<<<<<< HEAD
    @task = Task.new(task_params)
    @task.project = @project
    @task.user = current_user
=======
    project_user = @project.project_users.find_by(user: current_user)
    @task = Task.new(task_params)
    @task.project_user = project_user
>>>>>>> master

    if @task.save
      flash[:notice] = "Task created ✅"
      redirect_to project_tasks_path(@project)
    else
      flash[:alert] = "Unable to create the task. Please fix the errors."
      render :new, status: :unprocessable_entity
    end
  end

  def show
<<<<<<< HEAD
    # @user = @task.task_users
=======
    @user = @task.project_user.user
    @project = @task.project
>>>>>>> master
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
<<<<<<< HEAD
    params.require(:task).permit(:name, :description, :location, :date, :deadline, :status, :priority)
=======
    params.require(:task).permit(:name, :description, :location, :date, :status, :deadline, :priority)
>>>>>>> master
  end

  def set_task
    @task = Task.find(params[:id]) if params[:id].present?
  end

  def set_project
<<<<<<< HEAD
    @project = Project.find(params[:project_id]) if params[:project_id].present?
=======
    @project = Project.find(params[:project_id])
>>>>>>> master
  end
end
