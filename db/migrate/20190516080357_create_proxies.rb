class CreateProxies < ActiveRecord::Migration[5.2]
  def change
    create_table :proxies do |t|
      t.string :name
      t.integer :port
      t.boolean :elite, default: true, index: true
      t.timestamps
    end
  end
end
