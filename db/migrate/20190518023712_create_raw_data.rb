class CreateRawData < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_data do |t|
      t.text :raw_url
      t.text :proxy_url

      t.timestamps
    end
  end
end
