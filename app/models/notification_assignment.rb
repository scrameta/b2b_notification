class NotificationAssignment < ApplicationRecord
  belongs_to :notification
  belongs_to :client
end
