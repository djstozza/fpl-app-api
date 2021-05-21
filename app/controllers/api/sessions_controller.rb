# Handle sessions
class Api::SessionsController < Devise::SessionsController
  before_action :authenticate_user!, only: [:update]

  def create
    user = User.find_by(email: sign_in_params[:email])
    service = Users::SignIn.call(sign_in_params, user: user)
    token = service.token

    return respond_with service unless token

    respond_with token: token, user: UserSerializer.new(user)
  end

  def update
    token = Users::BaseService.call({}, user: current_user).token

    respond_with token: token, user: UserSerializer.new(current_user)
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end
end
