class AddSystemMessageToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :system_message, :boolean
  end
end
