class AddExportToExcel < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :export_excel, :bool, index: true
  end
end
