class RenameUserFieldsToEnglish < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :name, :first_name
    rename_column :users, :second_name, :middle_name

    # Actualiza los índices si es necesario
    if index_exists?(:users, :email)
      remove_index :users, :email
      add_index :users, :email, unique: true
    end
  end
end
