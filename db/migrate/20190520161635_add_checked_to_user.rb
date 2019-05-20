class AddCheckedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_checked, :boolean, index: true
  end
end
