class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :check_owner, only: [:new, :create, :edit, :update, :destroy]

  def index
    @project = Project.find(params[:project_id])
    @notes = @project.notes
  end

  def dashboard_show

    @project = Project.find(params[:id])
  end

  def show
    @note = Note.find(params[:id])
  end

  def new
    @note = Note.new
    @project = Project.find(params[:project_id])
    @note.project = @project
  end

  def edit
  end

  def create
    @project = Project.find(params[:project_id])
    @note = Note.new(note_params)
    @note.project = @project
    @note.user = current_user
    if @note.save
      redirect_to project_note_path(@project, @note), notice: 'Note was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      redirect_to project_note_path(@project, @note), notice: 'Note was successfully updated.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    project = @note.project
    @note.destroy
    redirect_to project_notes_path(project), notice: 'Note was successfully deleted.'
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end

  def check_owner
    @project = Project.find(params[:project_id])
    unless @project.user == current_user
      redirect_to project_notes_path(@project), alert: 'Only project owner can perform this action.'
    end
  end




end
