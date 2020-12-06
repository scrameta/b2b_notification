# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :username
      t.string :name
      t.string :surname
      t.boolean :admin

      t.timestamps
    end

    add_index :employees, :username
  end
end
