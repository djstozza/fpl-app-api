require 'rails_helper'

RSpec.describe Users::SignUp, type: :service do
  it 'creates a user and generates a token on call' do
    service = described_class.new(
      email: 'user@example.com',
      username: 'user1',
      password: 'password',
    )

    token = service.call
    decoded_jwt = JWT.decode(token, Rails.application.secret_key_base)[0]

    expect(decoded_jwt).to match(
      'id' => service.user.id,
      'exp' => be_within(1.second).of(2.hours.from_now.to_i)
    )

    expect(service.user).to have_attributes(
      email: 'user@example.com',
      username: 'user1',
      password: 'password',
    )
  end

  it 'fails if params are missing' do
    service = described_class.new({})

    service.call

    expect(service.errors.full_messages).to contain_exactly(
      "Email can't be blank",
      "Username can't be blank",
      "Password can't be blank",
    )
  end

  it 'fails if the email is invalid' do
    service = described_class.new(
      email: 'invalid',
      username: 'user1',
      password: 'password',
    )

    service.call

    expect(service.errors.full_messages).to contain_exactly(
      'Email is invalid',
    )
  end

  it 'fails if the email or username has already been taken' do
    user = create :user

    service = described_class.new({ email: user.email, username: user.username, password: 'password' })
    service.call

    expect(service.errors.full_messages).to contain_exactly(
      'Email has already been taken',
      'Username has already been taken',
    )
  end
end
