class Users::SignIn < Users::BaseService
  validates :email, :password, presence: true

  validate :password_is_correct

  private
end
