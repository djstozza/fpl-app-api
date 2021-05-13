require 'rails_helper'

RSpec.describe 'api/passwords', type: :request do
  let!(:user) { create :user }

  describe 'PUT' do
    it 'changes the password' do
      token = Users::BaseService.call({}, user: user)

      api.put api_passwords_path,
              params: { user: { password: user.password, new_password: 'new password', } },
              headers: { 'Authorization' => "Bearer #{token}" }

      expect(api.response).to have_http_status(:success)

      expect(api.data['user']).to include(
        'id' => user.to_param,
        'email' => user.email,
        'username' => user.username,
      )
    end

    it 'fails if the params are invalid' do
      token = Users::BaseService.call({}, user: user)

      api.put api_passwords_path,
              params: { user: { password: user.password, new_password: user.password, } },
              headers: { 'Authorization' => "Bearer #{token}" }

      expect(api.errors).to contain_exactly(
        a_hash_including(
          'detail' => "New password must be different from your current password",
          'source' => 'new_password',
        ),
      )
    end
  end
end
