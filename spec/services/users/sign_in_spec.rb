require 'rails_helper'

RSpec.describe Users::SignIn, type: :service do
  let!(:user) { create :user }

  it 'generates the jwt token on call' do
    data = {
      email: user.email,
      password: user.password,
    }

    service = described_class.new(data, user: user)

    token = service.call

    decoded_jwt = JWT.decode(token, Rails.application.secret_key_base)[0]

    expect(decoded_jwt).to include(
      'id' => service.user.id,
      'exp' => be_within(1.second).of(2.hours.from_now.to_i)
    )
  end

  it 'fails if the password is invalid' do
    data = {
      email: user.email,
      password: 'invalid',
    }

    service = described_class.new(data, user: user)

    service.call

    expect(service.errors).to contain_exactly(
      'Email or password is invalid'
    )
  end

  it 'fails if the email is invalid' do
    service = described_class.new(
      email: 'some@user.com',
      password: user.password,
    )

    service.call

    expect(service.errors).to contain_exactly(
      'Email or password is invalid'
    )
  end
end
