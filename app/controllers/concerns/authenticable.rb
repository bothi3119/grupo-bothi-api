module Authenticable
  include JwtHelper

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    begin
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
