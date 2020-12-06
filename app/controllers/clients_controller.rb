# frozen_string_literal: true

class ClientsController < ApplicationController
  def index
    verify_admin { return }
    @clients = Client.all
  end
end
