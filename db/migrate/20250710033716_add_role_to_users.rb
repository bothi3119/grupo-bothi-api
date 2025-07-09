class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    def change
      add_column :users, :role, :integer, default: 0, null: false
    end
  end
end
