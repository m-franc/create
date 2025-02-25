class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, except: [:index, :new, :create, :toggle_status]

  def index
    # project_user_ids = @project.project_users.pluck(:id)
    # @tasks = Task.where(project_user_id: project_user_ids)
    @tasks = Task.all

    
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.project = @project
    @task.user = current_user
    dates = params["task"]["date"].split("to").map(&:strip)
    @task.date = dates[0]
    @task.deadline = dates[1]
    if @task.save
      flash[:notice] = "Task created ✅"
      redirect_to project_path(@project, anchor: 'contact-tab')
    else
      flash[:alert] = "Unable to create the task. Please fix the errors."
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    dates = params["task"]["date"].split("to").map(&:strip)
    @task.date = dates[0]
    @task.deadline = dates[1]
    if @task.update(task_params)
      flash[:notice] = "Task successfully updated 💾"
      redirect_to project_path(@project, anchor: 'contact-tab')
    else
      flash[:alert] = "Unable to update the task. Please fix the errors."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_path(@project, anchor: 'contact-tab'), notice: 'Task was successfully deleted.'
  end



    def all_task
      @tasks = current_user.tasks.order(deadline: :asc)
      today = Date.today
    end


  def toggle_status
    @task = Task.find(params[:id])
    @task.update(completed: params[:completed])

    respond_to do |format|
      format.json { render json: { completed: @task.completed, success: true } }
    end
  end


  private

  def task_params
    params.require(:task).permit(:name, :description, :location, :status, :priority)
  end

  def set_task
    @task = Task.find(params[:id]) if params[:id].present?
  end

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end
end
