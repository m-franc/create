class RenameDateToStartingAndEndDateInProjects < ActiveRecord::Migration[7.1]
  def change
    # Supprime la colonne `date`
    remove_column :projects, :date, :date

    # Ajoute les colonnes `starting_date` et `end_date`
    add_column :projects, :starting_date, :date
    add_column :projects, :end_date, :date
  end
end
