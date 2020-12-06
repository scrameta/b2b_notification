class ClientsController < ApplicationController
  def index
    verify_admin { return }
    @clients = Client.all
  end
end
