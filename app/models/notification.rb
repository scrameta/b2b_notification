# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :employee
  has_many :notification_assignments, dependent: :destroy
end
