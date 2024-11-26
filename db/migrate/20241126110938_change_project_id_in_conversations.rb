class ChangeProjectIdInConversations < ActiveRecord::Migration[7.1]
  def change
    change_column_null :conversations, :project_id, true
  end
end
