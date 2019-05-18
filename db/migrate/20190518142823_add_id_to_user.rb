class AddIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :id_user_info, :string, index: true
    add_column :error_users, :id_user_info, :string, index: true
  end
end
