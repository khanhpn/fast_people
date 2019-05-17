class AddModelFamilyToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :model_family, :string
  end
end
