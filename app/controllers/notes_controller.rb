class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :check_owner, only: [:new, :create, :edit, :update, :destroy]

  def index
    @project = Project.find(params[:project_id])
    @notes = @project.notes
  end

  def show
  end

  def new
    @project = Project.find(params[:project_id])
    @note = @project.notes.build
  end

  def edit
  end

  def create
    @project = Project.find(params[:project_id])
    @note = @project.notes.build(note_params)
    @note.user = current_user

    if @note.save
      redirect_to project_notes_path(@project), notice: 'Note was successfully created.'
    else
      render :new
    end
  end

  def update
    if @note.update(note_params)
      redirect_to project_notes_path(@note.project), notice: 'Note was successfully updated.'
    else
      render :edit
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
