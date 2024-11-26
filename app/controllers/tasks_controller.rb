class TasksController < ApplicationController
  before_action :authenticate_user!, :set_project, :set_task

  def index
    @tasks = Task.find_by(task_user: current_user)
  end

  def new
    @task = Task.new
  end

  def create
    @task.new(task_params)
    @task.task_user = current_user
    if @task.save
      flash[:notice] = "Task created ✅"
      redirect_to @tasks
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = @task.task_user
    @project = @task.project
  end

  def edit
  end

  def update
    @task = set_task
    if @task.update(task_params)
      flash[:notice] = "Task successfully updated 💾"
      redirect_to @task
    else
      flash[:alert] = "Unable to update the task. Please fix the errors."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
  end

  private

  def task_params
    params.require(:task).permit(:name, :description)
  end

  def set_task
    @task = Task.find(params[:id]) if params[:id].present?
  end

  def set_project
    @projet = Project.find(params[:project_id]) if params[:project_id].present?
  end
end
