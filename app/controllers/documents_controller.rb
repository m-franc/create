class DocumentsController < ApplicationController
  before_action :set_project
  before_action :set_document, only: [:destroy, :download]
  before_action :check_project_member
  before_action :check_owner, only: [:destroy]

  def index
    @folders = if current_user == @project.user
                 Document.where(project: @project).pluck(:folder_name).uniq
               else
                 Document.where(project: @project, user: current_user).pluck(:folder_name).uniq
               end
    
    @documents = if current_user == @project.user
                  @project.documents
                else
                  @project.documents.where(user: current_user)
                end
  end

  def new
    @document = @project.documents.new
  end

  def create
    @document = @project.documents.new(document_params)
    @document.user = current_user

    if params[:document][:file].present?
      folder_path = "projects/#{@project.id}/#{@document.folder_name}"
      upload = Cloudinary::Uploader.upload(
        params[:document][:file],
        folder: folder_path,
        resource_type: 'auto'
      )
      @document.cloudinary_id = upload['public_id']
    end

    if @document.save
      redirect_to project_documents_path(@project), notice: 'Document was successfully uploaded.'
    else
      render :new
    end
  end

  def destroy
    if @document.cloudinary_id.present?
      Cloudinary::Uploader.destroy(@document.cloudinary_id)
    end
    @document.destroy
    redirect_to project_documents_path(@project), notice: 'Document was successfully deleted.'
  end

  def download
    if @document.cloudinary_id.present?
      redirect_to Cloudinary::Utils.cloudinary_url(@document.cloudinary_id, resource_type: 'auto')
    else
      redirect_to project_documents_path(@project), alert: 'Document not found.'
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_document
    @document = @project.documents.find(params[:id])
  end

  def check_project_member
    unless @project.user == current_user || @project.joined_users.include?(current_user)
      redirect_to projects_path, alert: 'You are not authorized to access this project.'
    end
  end

  def check_owner
    unless @project.user == current_user
      redirect_to project_documents_path(@project), alert: 'Only project owner can perform this action.'
    end
  end

  def document_params
    params.require(:document).permit(:name, :folder_name, :file)
  end
end
