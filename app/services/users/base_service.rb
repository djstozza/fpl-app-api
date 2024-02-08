class Users::BaseService < ApplicationService
  attr_reader :user, :email, :username, :password, :new_password, :token

  def initialize(data, options = {})
    @user = options[:user] || User.new
    @email = data[:email]
    @username = data[:username]
    @password = data[:password]
    @new_password = data[:new_password]
    @token = nil
  end

  def call
    return unless valid?

    generate_jwt
  end

  private

  def password_is_correct
    return if user&.valid_password?(password)

    errors.add('email or password', 'is invalid')
  end

  def generate_jwt
    @token = JWT.encode(
      {
        id: user.id,
        exp: (ENV['SESSION_EXPIRY'].to_i || 120).minutes.from_now.to_i,
      },
      Rails.application.secrets.secret_key_base,
    )
  end
end
