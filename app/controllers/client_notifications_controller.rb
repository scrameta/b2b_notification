class ClientNotificationsController < ApplicationController
  def index
    @client = verify_client { return }
    @notifications = NotificationAssignment.where(client: @client)
  end

  def show
    @client = verify_client { return }
    assignment = NotificationAssignment.find(params[:id])
    @notification = assignment.notification
    unless assignment.update(:read=>true)
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end
end
