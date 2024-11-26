class AddNameToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :name, :string
  end
end
