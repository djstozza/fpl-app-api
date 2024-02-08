class Api::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update]

  def update
    service = Users::Update.new(user_params, user: current_user)

    return respond_with service unless service.call

    respond_with({ user: UserSerializer.new(service.user) })
  end

  private

  def user_params
    params.require(:user).permit(:email, :username)
  end
end
