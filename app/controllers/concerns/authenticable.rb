module Authenticable
  include JwtHelper
  include ApiErrors

  def authenticate_request
    authorization_header = request.headers["Authorization"]

    unless authorization_header
      raise ApiErrors::UnauthorizedError.new(message: "Authorization header is missing")
    end

    token = authorization_header.split(" ").last

    begin
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      raise ApiErrors::UnauthorizedError.new(
        message: "Invalid user credentials",
        details: "User not found with provided token",
      )
    rescue JWT::DecodeError => e
      raise ApiErrors::UnauthorizedError.new(
        message: "Invalid token",
        details: e.message,
      )
    rescue JWT::ExpiredSignature => e
      raise ApiErrors::UnauthorizedError.new(
        message: "Token has expired",
        details: "Please login again to get a new token",
      )
    rescue => e
      raise ApiErrors::UnauthorizedError.new(
        message: "Authentication failed",
        details: e.message,
      )
    end
  end

  def current_user
    @current_user
  end
end
