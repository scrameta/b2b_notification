require 'rails_helper'

#TODO, should probably be using shared examples...

describe "basic portfolio test", :type => :request do

  before(:all) do
    @notadmins = FactoryBot.create_list(:employee, 5, admin: false)
    @admins = FactoryBot.create_list(:employee, 3, admin: true)
    @clients = FactoryBot.create_list(:client, 7)
    @user_notadmins = @notadmins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_admins = @admins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_clients = @clients.map { |i| FactoryBot.create(:user,name: i.username) }
    @notifications = @admins.map { |i| FactoryBot.create_list(:random_notification, 4, employee: i) }
    @portfolios0 = FactoryBot.create_list(:portfolio,3,client: @clients[0])
    @portfolios1 = FactoryBot.create_list(:portfolio,1,client: @clients[1])
  end

  context 'with client' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_clients[0].email, 'password' => @user_clients[0].password }
      @hdr_client0 = { "Authorization" => JSON.parse(response.body)['auth_token'] }
      
      post '/authenticate', params: { 'email' => @user_clients[1].email, 'password' => @user_clients[1].password }
      @hdr_client1 = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'lists own portfolios' do
      get '/client_portfolios.json', headers: @hdr_client0
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(3)
      expect(JSON.parse(response.body).map { |i| i['id']}).to eq(@portfolios0.map { |i| i['id']})

      get '/client_portfolios.json', headers: @hdr_client1
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body).map { |i| i['id']}).to eq(@portfolios1.map { |i| i['id']})
    end

    # TODO: More to do here, but time to submit... and sleep!
  end
end

