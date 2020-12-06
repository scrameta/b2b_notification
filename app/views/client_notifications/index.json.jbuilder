# frozen_string_literal: true

json.array! @notifications, partial: 'client_notifications/notification', as: :notification
