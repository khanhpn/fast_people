class AddInfoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :zip_code, :string
    add_column :users, :name, :string
  end
end
