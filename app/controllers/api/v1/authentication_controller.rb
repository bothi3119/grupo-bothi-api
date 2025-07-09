module Api::V1
  class AuthenticationController < ApplicationController

    # POST /api/v1/auth/login
    def login
      user = User.find_by(email: params[:email].downcase)
      if user&.authenticate(params[:password])
        token = jwt_encode(user_id: user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    private

    def login_params
      params.permit(:email, :password)
    end
  end
end
