module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_internal_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ApiErrors::BaseError, with: :handle_api_error

    # Custom validation error for JWT
    rescue_from JWT::DecodeError, with: :handle_unauthorized
    rescue_from JWT::ExpiredSignature, with: :handle_unauthorized
  end

  private

  def handle_api_error(error)
    render json: error.as_json, status: error.status
  end

  def handle_bad_request(error)
    error = ApiErrors::BadRequestError.new(
      message: error.message,
      details: { param: error.param },
    )
    handle_api_error(error)
  end

  def handle_unauthorized(error)
    error = ApiErrors::UnauthorizedError.new(
      message: "Invalid or expired token",
      details: error.message,
    )
    handle_api_error(error)
  end

  def handle_forbidden(error)
    error = ApiErrors::ForbiddenError.new(
      message: "You are not authorized to perform this action",
      details: error.message,
    )
    handle_api_error(error)
  end

  def handle_not_found(error)
    error = ApiErrors::NotFoundError.new(
      message: "Resource not found",
      details: error.message,
    )
    handle_api_error(error)
  end

  def handle_unprocessable_entity(error)
    error = ApiErrors::UnprocessableEntityError.new(
      message: "Validation failed",
      details: error.record.errors.full_messages,
    )
    handle_api_error(error)
  end

  def handle_internal_error(error)
    # Log the error for debugging
    Rails.logger.error("#{error.class.name}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))

    error = ApiErrors::BaseError.new(
      message: "Internal server error",
      details: Rails.env.production? ? nil : error.message,
    )
    handle_api_error(error)
  end
end
