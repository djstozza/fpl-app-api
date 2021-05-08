class Users::Update < Users::BaseService
  validate :valid_user

  def call
    valid?
  end

  private

  def valid_user
    user.update(
      email: email,
      username: username,
    )

    errors.merge!(user.errors) if user.errors.any?
  end
end
