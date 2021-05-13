class Users::ChangePassword < Users::BaseService
  validate :password_is_correct
  validate :valid_new_password

  validates :new_password, presence: true

  validates :new_password,
            allow_nil: true,
            length: { minimum: User::MIN_PASSWORD_LENGTH, maximum: User::MAX_PASSWORD_LENGTH }

  def call
    return unless valid?

    user.update(password: new_password)

    return errors.merge!(user.errors) if user.errors.any?

    true
  end

  private

  def valid_new_password
    return unless new_password === password

    errors.add(:new_password, 'must be different from your current password')
  end

  def password_is_correct
    return if user.valid_password?(password)

    errors.add(:password, 'is incorrect')
  end
end
