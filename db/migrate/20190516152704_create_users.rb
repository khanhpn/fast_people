class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :age
      t.text :emails
      t.text :landline
      t.text :wireless
      t.text :link

      t.timestamps
    end
  end
end
