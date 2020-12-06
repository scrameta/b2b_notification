# frozen_string_literal: true

class AssignmentsController < ApplicationController
  def index
    verify_admin { return }
    @assignments = NotificationAssignment.where(params.require('notification_id'))
  end

  def create
    verify_admin { return }
    params_adj = assignment_params { return }
    @assignment = NotificationAssignment.new(params_adj)
    if @assignment.save
      @assignment
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  def show
    verify_admin { return }
    @assignment = NotificationAssignment.find(params[:id])
  end

  def update
    verify_admin { return }
    @assignment = NotificationAssignment.find(params[:id])
    params_adj = assignment_params_update { return }
    if @assignment.update(params_adj)
      @assignment
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  def destroy
    verify_admin { return }
    @assignment = NotificationAssignment.find(params[:id])
    if @assignment.destroy
      @assignment
    else
      render json: { errors: 'Failed to store to database' }, status: 500
    end
  end

  private

  def assignment_params
    params_adj = params.permit(:notification_id, :client)
    @client = Client.find_by({ username: params_adj[:client] })
    if @client
      @notification = Notification.find(params[:notification_id])
      params_adj[:client] = @client
      params_adj[:notification] = @notification
      params_adj.delete(:notification_id)
      params_adj
    else
      render json: { errors: "#{params_adj[:client]} unknown" }, status: 422 and yield
    end
  end

  def assignment_params_update
    params_adj = params.permit(:client)
    @client = Client.find_by({ username: params_adj[:client] })
    if @client
      params_adj[:client] = @client
      params_adj
    else
      render json: { errors: "#{params_adj[:client]} unknown" }, status: 422 and yield
    end
  end
end
