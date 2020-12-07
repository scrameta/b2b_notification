require 'rails_helper'

describe "create notification test", :type => :request do

  before(:all) do
    @notadmins = FactoryBot.create_list(:employee, 5, admin: false)
    @admins = FactoryBot.create_list(:employee, 3, admin: true)
    @clients = FactoryBot.create_list(:client, 7)
    @user_notadmins = @notadmins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_admins = @admins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_clients = @clients.map { |i| FactoryBot.create(:user,name: i.username) }
    @notifications = @admins.map { |i| FactoryBot.create_list(:random_notification, 4, employee: i) }
  end

  context 'with client' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_clients[0].email, 'password' => @user_clients[0].password }
      @hdr_client0 = { "Authorization" => JSON.parse(response.body)['auth_token'] }

      post '/authenticate', params: { 'email' => @user_clients[1].email, 'password' => @user_clients[1].password }
      @hdr_client1 = { "Authorization" => JSON.parse(response.body)['auth_token'] }

      post '/authenticate', params: { 'email' => @user_clients[2].email, 'password' => @user_clients[2].password }
      @hdr_client2 = { "Authorization" => JSON.parse(response.body)['auth_token'] }

      post '/authenticate', params: { 'email' => @user_admins[0].email, 'password' => @user_admins[0].password }
      @hdr_admins = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'not visible by default' do
      get "/client_notifications.json", headers: @hdr_client0
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(0)

      get "/client_notifications.json", headers: @hdr_client1
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(0)

      get "/client_notifications.json", headers: @hdr_client2
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(0)
    end

    it 'sees own assignments only' do
      post "/notifications/#{@notifications[0][1]['id']}/assignments.json", headers: @hdr_admins, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id1 = JSON.parse(response.body)['id']

      get "/client_notifications.json", headers: @hdr_client0
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)

      post "/notifications/#{@notifications[1][2]['id']}/assignments.json", headers: @hdr_admins, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id2 = JSON.parse(response.body)['id']

      post "/notifications/#{@notifications[0][1]['id']}/assignments.json", headers: @hdr_admins, params: {'client': @clients[2].username}
      expect(response).to have_http_status(:success)
      assignment_id2 = JSON.parse(response.body)['id']

      get "/client_notifications.json", headers: @hdr_client0
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)

      get "/client_notifications.json", headers: @hdr_client1
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(0)

      get "/client_notifications.json", headers: @hdr_client2
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it 'marks as read' do
      post "/notifications/#{@notifications[0][1]['id']}/assignments.json", headers: @hdr_admins, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id1 = JSON.parse(response.body)['id']

      post "/notifications/#{@notifications[0][1]['id']}/assignments.json", headers: @hdr_admins, params: {'client': @clients[1].username}
      expect(response).to have_http_status(:success)
      assignment_id2 = JSON.parse(response.body)['id']

      get "/assignments/#{assignment_id1}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be false

      get "/assignments/#{assignment_id2}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be false

      get "/client_notifications/#{assignment_id1}.json", headers: @hdr_client0
      expect(response).to have_http_status(:success)

      get "/assignments/#{assignment_id1}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be true

      get "/assignments/#{assignment_id2}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be false

      get "/client_notifications/#{assignment_id2}.json", headers: @hdr_client0
      expect(response).to have_http_status(:success)

      get "/assignments/#{assignment_id1}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be true

      get "/assignments/#{assignment_id2}.json", headers: @hdr_admins
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['read']).to be true
    end
  end
end
