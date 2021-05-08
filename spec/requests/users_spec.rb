require 'rails_helper'

RSpec.describe 'users', type: :request do
  let!(:user) { create :user }

  describe 'PUT' do
    it 'responds with an updated token' do
      token = Users::BaseService.call({}, user: user)

      api.put api_users_path,
              params: {
                user: {
                  email: 'new@email.com',
                  username: 'new',
                },
              },
              headers: { 'Authorization' => "Bearer #{token}" }

      expect(api.data['user']).to include(
        'email' => 'new@email.com',
        'username' => 'new',
      )
    end
  end
end
