require 'rails_helper'

RSpec.describe Users::Update, type: :service do
  let!(:user) { create :user }
  it 'updates the email and username' do
    data = { email: 'new@email.com', username: 'new' }

    service = described_class.new(data, user: user)
    service.call

    expect(user.reload).to have_attributes(
      email: 'new@email.com',
      username: 'new',
    )
  end

  it 'fails if params are missing' do
    service = described_class.new({}, user: user)

    service.call

    expect(service.errors.full_messages).to contain_exactly(
      "Email can't be blank",
      "Username can't be blank",
    )
  end

  it 'fails if the email or username has already been taken' do
    another_user = create :user
    data = { email: another_user.email, username: another_user.username }

    service = described_class.new(data, user: user)
    service.call

    expect(service.errors.full_messages).to contain_exactly(
      'Email has already been taken',
      'Username has already been taken',
    )
  end
end
