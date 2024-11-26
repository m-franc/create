class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :description
      t.string :location
      t.date :date
      t.boolean :status
      t.string :deadline
      t.string :priority
      t.references :project_user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
