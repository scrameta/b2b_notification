class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :username
      t.string :name
      t.string :surname

      t.timestamps
    end

    add_index :clients,:username
  end
end
