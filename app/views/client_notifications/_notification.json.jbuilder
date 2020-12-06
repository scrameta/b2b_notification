json.extract! notification, :id, :created_at, :updated_at
json.url clientNotifications_url(notification, format: :json)
