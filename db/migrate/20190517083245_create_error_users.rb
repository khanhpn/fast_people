class CreateErrorUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :error_users do |t|
      t.string :model_family
      t.string :name
      t.string :zip_code
      t.text :link
      t.text :error

      t.timestamps
    end
  end
end
