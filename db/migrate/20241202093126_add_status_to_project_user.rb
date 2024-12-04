class AddStatusToProjectUser < ActiveRecord::Migration[7.1]
  def change
    add_column :project_users, :status, :string
  end
end
