class AddFileExtensionToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :file_extension, :string
  end
end
