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

  context 'with admin' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_admins[0].email, 'password' => @user_admins[0].password }
      @hdr = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'create and assign notification' do
      post '/notifications.json', headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:success)
      notification_id = JSON.parse(response.body)['id']

      post "/notifications/#{notification_id}/assignments.json", headers: @hdr, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id1 = JSON.parse(response.body)['id']

      post "/notifications/#{notification_id}/assignments.json", headers: @hdr, params: {'client': @clients[2].username}
      expect(response).to have_http_status(:success)
      assignment_id2 = JSON.parse(response.body)['id']

      get "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['client']['username']).to eq(@clients[0].username)

      get "/assignments/#{assignment_id2}.json", headers: @hdr
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['client']['username']).to eq(@clients[2].username)
    end

    it 'create and delete notification' do
      post '/notifications.json', headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:success)
      notification_id = JSON.parse(response.body)['id']

      post "/notifications/#{notification_id}/assignments.json", headers: @hdr, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id1 = JSON.parse(response.body)['id']

      post "/notifications/#{notification_id}/assignments.json", headers: @hdr, params: {'client': @clients[2].username}
      expect(response).to have_http_status(:success)
      assignment_id2 = JSON.parse(response.body)['id']

      delete "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:success)

      get "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such notification/

      get "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such assignment/

      get "/assignments/#{assignment_id2}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such assignment/

      delete "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such notification/
    end

    it 'create and delete assignment' do
      post '/notifications.json', headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:success)
      notification_id = JSON.parse(response.body)['id']

      post "/notifications/#{notification_id}/assignments.json", headers: @hdr, params: {'client': @clients[0].username}
      expect(response).to have_http_status(:success)
      assignment_id1 = JSON.parse(response.body)['id']

      get "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:success)

      delete "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:success)

      get "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such assignment/

      delete "/assignments/#{assignment_id1}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such assignment/
    end

    it 'create and edit notification' do
      post '/notifications.json', headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:success)
      notification_id = JSON.parse(response.body)['id']

      put "/notifications/#{notification_id}.json", headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:success)

      delete "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:success)

      get "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such notification/

      delete "/notifications/#{notification_id}.json", headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such notification/

      put "/notifications/#{notification_id}.json", headers: @hdr, params: {'message': Faker::Lorem.paragraphs, 'employee': @admins[0]}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /No such notification/
    end
  end
end
