class Users::SignUp < Users::BaseService
  validate :valid_user

  private

  def valid_user
    user.update(
      email: email,
      username: username,
      password: password,
    )

    errors.merge!(user.errors) if user.errors.any?
  end
end
