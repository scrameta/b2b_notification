require 'rails_helper'

#TODO, should probably be using shared examples...

describe "get all notifications route", :type => :request do

  before(:all) do
    @notadmins = FactoryBot.create_list(:employee, 5, admin: false)
    @admins = FactoryBot.create_list(:employee, 3, admin: true)
    @clients = FactoryBot.create_list(:client, 7)
    @user_notadmins = @notadmins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_admins = @admins.map { |i| FactoryBot.create(:user,name: i.username) }
    @user_clients = @clients.map { |i| FactoryBot.create(:user,name: i.username) }
    @notifications = @admins.map { |i| FactoryBot.create_list(:random_notification, 4, employee: i) }
  end

  context 'without authtoken' do
    it 'returns unauthorized' do
      get '/notifications.json'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'with admin' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_admins[0].email, 'password' => @user_admins[0].password }
      @hdr = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'returns status code 200' do
      get '/notifications.json', headers: @hdr
      expect(response).to have_http_status(:success)
    end

    it 'returns all notifications' do
      get '/notifications.json', headers: @hdr
      expect(JSON.parse(response.body).size).to eq(12)
      expect(JSON.parse(response.body)[0].keys).to eq(["id", "created_at", "updated_at", "url"])
    end
  end

  context 'with not admin' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_notadmins[0].email, 'password' => @user_notadmins[0].password }
      @hdr = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'returns status code 422' do
      get '/notifications.json', headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns admin error' do
      get '/notifications.json', headers: @hdr
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /is not a Yova admin/
    end
  end

  context 'with client' do
    before(:context) do
      post '/authenticate', params: { 'email' => @user_clients[0].email, 'password' => @user_clients[0].password }
      @hdr = { "Authorization" => JSON.parse(response.body)['auth_token'] }
    end

    it 'returns status code 200' do
      get '/notifications.json', headers: @hdr
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns admin error' do
      get '/notifications.json', headers: @hdr
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)['errors']).to match /is not a Yova admin/
    end
  end
end
