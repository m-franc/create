class AddImageToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :image, :string
  end
end
