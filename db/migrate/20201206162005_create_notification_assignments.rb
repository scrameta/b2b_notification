# frozen_string_literal: true

class CreateNotificationAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_assignments do |t|
      t.references :notification, foreign_key: true
      t.references :client, foreign_key: true
      t.boolean :read

      t.timestamps
    end
  end
end
