class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :username
      t.string :name
      t.string :surname
      t.logical :admin

      t.timestamps
    end
  end
end
