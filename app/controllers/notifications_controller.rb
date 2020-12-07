# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    verify_admin { return }
    @notifications = Notification.last(100)
  end

  def create
    verify_admin { return }
    params_adj = notification_params { return }
    @notification = Notification.new(params_adj)
    if @notification.save
      @notification
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  def show
    verify_admin { return }
    begin
      @notification = Notification.find(params[:id])
    rescue
      render json: { errors: "No such notification" }, status: 422
    end
  end

  def update
    verify_admin { return }
    begin
      @notification = Notification.find(params[:id])
    rescue
      render json: { errors: "No such notification" }, status: 422
      return
    end
    params_adj = notification_params { return }
    if @notification.update(params_adj)
      @notification
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  def destroy
    verify_admin { return }
    begin
      @notification = Notification.find(params[:id])
    rescue
      render json: { errors: "No such notification" }, status: 422
      return
    end
    if @notification.destroy
      @notification
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  private

  def notification_params
    params_adj = params.permit(:message)
    # byebug
    username = @current_user.name
    @employee = Employee.find_by({ username: username })
    params_adj[:employee] = @employee
    params_adj
  end
end
