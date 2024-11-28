class RemoveReferenceProjectUserOnTasks < ActiveRecord::Migration[7.1]
  def change
    remove_reference :tasks, :project_user, index: true, foreign_key: true
  end
end
