require 'rails_helper'

RSpec.describe Users::ChangePassword, type: :service do
  let!(:user) { create :user }

  it 'updates the pasword' do
    data = { password: user.password, new_password: 'new password' }

    service = described_class.new(data, user: user)
    service.call

    expect(user.reload).to have_attributes(password: 'new password')
  end

  it 'fails if the new password is invalid' do
    new_password = SecureRandom.alphanumeric(User::MIN_PASSWORD_LENGTH - 1)
    service = described_class.new({ password: user.password, new_password: new_password }, user: user)

    service.call

    expect(service.errors.full_messages)
      .to contain_exactly("New password is too short (minimum is #{User::MIN_PASSWORD_LENGTH} characters)")

    new_password = SecureRandom.alphanumeric(User::MAX_PASSWORD_LENGTH + 1)
    service = described_class.new({ password: user.password, new_password: new_password }, user: user)

    service.call

    expect(service.errors.full_messages)
      .to contain_exactly("New password is too long (maximum is #{User::MAX_PASSWORD_LENGTH} characters)")
  end

  it 'fails if the new password is the same as the current password' do
    service = described_class.new({ password: user.password, new_password: user.password }, user: user)
    service.call

    expect(service.errors.full_messages)
      .to contain_exactly('New password must be different from your current password')
  end

  it 'fails if the password is invalid' do
    service = described_class.new({ password: 'wrong', new_password: 'new password' }, user: user)

    service.call

    expect(service.errors.full_messages)
      .to contain_exactly('Password is incorrect')
  end
end
