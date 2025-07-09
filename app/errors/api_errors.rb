module ApiErrors
  class BaseError < StandardError
    attr_reader :status, :message, :details

    def initialize(status: nil, message: nil, details: nil)
      @status = status || :internal_server_error
      @message = message || "Something went wrong"
      @details = details
    end

    def as_json
      {
        error: {
          status: Rack::Utils.status_code(status),
          message: message,
          details: details,
        },
      }
    end
  end

  class BadRequestError < BaseError
    def initialize(message: "Bad Request", details: nil)
      super(status: :bad_request, message: message, details: details)
    end
  end

  class UnauthorizedError < BaseError
    def initialize(message: "Unauthorized", details: nil)
      super(status: :unauthorized, message: message, details: details)
    end
  end

  class ForbiddenError < BaseError
    def initialize(message: "Forbidden", details: nil)
      super(status: :forbidden, message: message, details: details)
    end
  end

  class NotFoundError < BaseError
    def initialize(message: "Not Found", details: nil)
      super(status: :not_found, message: message, details: details)
    end
  end

  class UnprocessableEntityError < BaseError
    def initialize(message: "Unprocessable Entity", details: nil)
      super(status: :unprocessable_entity, message: message, details: details)
    end
  end
end
