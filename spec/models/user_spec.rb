# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(create :user).to be_valid
  end

  describe '.email' do
    it 'must be present' do
      expect { create :user, email: nil }.to raise_error(ActiveRecord::RecordInvalid, /Email can't be blank/)
    end

    it 'must be unique' do
      user = create :user
      expect { create :user, email: user.email }
        .to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
    end

    it 'must be valid' do
      expect { create :user, email: 'foo' }.to raise_error(ActiveRecord::RecordInvalid, /Email is invalid/)
    end
  end

  describe '.username' do
    it 'must be present' do
      expect { create :user, username: nil }.to raise_error(ActiveRecord::RecordInvalid, /Username can't be blank/)
    end

    it 'must be unique' do
      user = create :user
      expect { create :user, username: user.username }
        .to raise_error(ActiveRecord::RecordInvalid, /Username has already been taken/)
    end
  end

  describe '.password' do
    it 'must be present' do
      expect { create :user, password: nil }.to raise_error(ActiveRecord::RecordInvalid, /Password can't be blank/)
    end

    it "must be greater than #{described_class::MIN_PASSWORD_LENGTH}" do
      expect { create :user, password: SecureRandom.alphanumeric(described_class::MIN_PASSWORD_LENGTH - 1) }
        .to raise_error(
          ActiveRecord::RecordInvalid,
          /Password is too short \(minimum is #{described_class::MIN_PASSWORD_LENGTH} characters\)/
        )
    end

    it "must be less than #{described_class::MAX_PASSWORD_LENGTH}" do
      expect { create :user, password: SecureRandom.alphanumeric(described_class::MAX_PASSWORD_LENGTH + 1) }
        .to raise_error(
          ActiveRecord::RecordInvalid,
          /Password is too long \(maximum is #{described_class::MAX_PASSWORD_LENGTH} characters\)/
        )
    end
  end
end
