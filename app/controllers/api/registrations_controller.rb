# Handle user sign ups
class Api::RegistrationsController < Devise::RegistrationsController

  def create
    service = Users::SignUp.new(sign_up_params)
    token = service.call

    return respond_with service unless token

    respond_with token: token, user: UserSerializer.new(service.user)
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :username, :password)
  end
end
