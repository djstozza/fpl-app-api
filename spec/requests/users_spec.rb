require 'rails_helper'

RSpec.describe 'api/users', type: :request do
  let!(:user) { create :user }

  describe 'PUT' do
    before { api.authenticate(user) }

    it 'updates the user details' do
      api.put api_users_path,
              params: {
                user: {
                  email: 'new@email.com',
                  username: 'new',
                },
              }

      expect(api.response).to have_http_status(:success)

      expect(api.data['user']).to include(
        'email' => 'new@email.com',
        'username' => 'new',
      )
    end

    it 'fails if the params are invalid' do
      api.put api_users_path,
              params: {
                user: {
                  email: 'invalid',
                  username: '',
                },
              }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'Email is invalid', 'source' => 'email'),
        a_hash_including('detail' => "Username can't be blank", 'source' => 'username'),
      )
    end
  end
end
