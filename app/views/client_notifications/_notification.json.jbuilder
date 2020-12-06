json.extract! notification, :id, :created_at, :updated_at
json.url client_notifications_url(notification, format: :json)
