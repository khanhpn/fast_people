class CreateMasterData < ActiveRecord::Migration[5.2]
  def change
    create_table :master_data do |t|
      t.string :model_family, index: true
      t.string :name, index: true
      t.string :zip_code, index: true
      t.timestamps
    end
  end
end
