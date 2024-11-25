class AddJobToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :job, :string
  end
end
