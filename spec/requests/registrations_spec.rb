require 'rails_helper'

RSpec.describe 'api/registrations', type: :request do
  it 'creates a new user' do
    expect do
      api.post api_registrations_path, params: {
        user: {
          email: 'email@example.com',
          username: 'user1',
          password: '12345678',
        },
      }
    end
    .to change(User, :count).from(0).to(1)

    decoded_jwt = JWT.decode(api.data['token'], Rails.application.secret_key_base)[0]

    user = User.first

    expect(decoded_jwt).to include(
      'id' => user.id,
      'exp' => be_within(1.second).of(2.hours.from_now.to_i)
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
    api.post api_registrations_path, params: { user: { email: 'invalid', password: '12345' } }
    expect(api.response).to have_http_status(:unprocessable_entity)
    expect(api.errors).to contain_exactly(
      a_hash_including('detail' => 'Email is invalid', 'source' => 'email'),
      a_hash_including(
        'detail' => "Password is too short (minimum is #{User::MIN_PASSWORD_LENGTH} characters)",
        'source' => 'password',
      ),
      a_hash_including('detail' => "Username can't be blank", 'source' => 'username'),
    )
  end
end
