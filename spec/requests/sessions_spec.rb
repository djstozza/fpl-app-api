require 'rails_helper'

RSpec.describe 'sessions', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:user) { create :user }

  describe 'GET' do
    it 'returns the user token' do
      api.post api_sessions_path, params: { user: { email: user.email, password: user.password } }

      decoded_jwt = JWT.decode(api.data['token'], Rails.application.secrets.secret_key_base)[0]

      expect(decoded_jwt).to include(
        'id' => user.id,
        'exp' => be_within(1.second).of(ENV['SESSION_EXPIRY'].to_i.minutes.from_now.to_i)
      )

      expect(api.data).to include(
        'user' => a_hash_including(
          'id' => user.to_param,
          'email' => user.email,
          'username' => user.username,
        )
      )
    end

    it 'fails if invalid attributes are passed' do
      api.post api_sessions_path, params: { user: { email: user.email, password: 'invalid' } }

      expect(api.response).to have_http_status(:unprocessable_entity)
      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'Email or password is invalid'),
      )

      api.post api_sessions_path, params: { user: { email: 'invalid@email.com', password: user.password } }

      expect(api.response).to have_http_status(:unprocessable_entity)
      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'Email or password is invalid'),
      )
    end
  end

  describe 'PUT' do
    it 'responds with an updated token' do
      token = Users::BaseService.call({}, user: user)

      travel_to ENV['SESSION_EXPIRY'].to_i.minutes.from_now - 1.minute do
        api.put api_sessions_path, params: {}, headers: { 'Authorization' => "Bearer #{token}" }

        decoded_jwt = JWT.decode(api.data['token'], Rails.application.secrets.secret_key_base)[0]

        expect(decoded_jwt).to include(
          'id' => user.id,
          'exp' => ENV['SESSION_EXPIRY'].to_i.minutes.from_now.to_i
        )
      end
    end

    it 'fails if the token has expired' do
      token = Users::BaseService.call({}, user: user)

      travel_to ENV['SESSION_EXPIRY'].to_i.minutes.from_now + 1.minute do
        api.put api_sessions_path, params: {}, headers: { 'Authorization' => "Bearer #{token}" }

        expect(api.response).to have_http_status(:unauthorized)
      end
    end
  end
end
