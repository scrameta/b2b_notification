class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  protected

  def verify_admin
    username = @current_user.name
    employee = Employee.find_by({ username: username })
    return employee if employee&.admin

    render json: { errors: "#{username} is not a Yova admin" }, status: 422 and yield
  end

  def verify_client
    username = @current_user.name
    client = Client.find_by({ username: username })
    return client if client

    render json: { errors: "#{username} unknown" }, status: 422 and yield
  end
end
