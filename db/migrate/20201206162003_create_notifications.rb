# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :message
      t.references :employee, foreign_key: true

      t.timestamps
    end
  end
end
