class AddIdToMasterDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :master_data, :id_user_info, :string, index: true
  end
end
