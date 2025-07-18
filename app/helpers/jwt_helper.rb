# app/helpers/jwt_helper.rb
module JwtHelper
  SECRET_KEY = ENV["SECRET_KEY_BASE"]
  DEFAULT_EXPIRATION = 24.hours

  def jwt_encode(payload, exp = DEFAULT_EXPIRATION.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
    ActiveSupport::HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    raise e # Re-raise the exception so it can be handled by the controller
  end

  # Class methods for backward compatibility
  class << self
    def jwt_encode(payload, exp = DEFAULT_EXPIRATION.from_now)
      payload = payload.dup
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, "HS256")
    end

    def jwt_decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
      ActiveSupport::HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      raise e
    end
  end
end
