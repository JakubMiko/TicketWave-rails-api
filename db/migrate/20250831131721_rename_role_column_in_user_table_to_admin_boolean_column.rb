class RenameRoleColumnInUserTableToAdminBooleanColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    remove_column :users, :role, :string
  end
end
