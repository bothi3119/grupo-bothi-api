class ResendMailer
  DEFAULT_SUBJECT = "Configura tu contraseña en Grupo Bothi"

  class << self
    def password_reset(user:, reset_url:)
      validate_parameters(user, reset_url)
      email_params = build_email_params(user, reset_url)
      send_email(email_params)
    rescue Resend::Error => e
      handle_email_error(user, e)
      false
    end

    private

    def validate_parameters(user, reset_url)
      raise ArgumentError, "User parameter is required" unless user.present?
      raise ArgumentError, "reset_url parameter is required" unless reset_url.present?
      raise ArgumentError, "User email is required" unless user.email.present?
    end

    def build_email_params(user, reset_url)
      binding.pry
      {
        from: sender_email,
        to: user.email,
        subject: DEFAULT_SUBJECT,
        html: password_reset_html(user, reset_url),
      }
    end

    def password_reset_html(user, reset_url)
      ApplicationController.render(
        template: "resend_mailer/password_reset",
        layout: false,
        locals: { user: user, reset_url: reset_url },
      )
    end

    def sender_email
      Rails.application.credentials.dig(:resend, :from_email) ||
      ENV["RESEND_FROM_EMAIL"]
    end

    def send_email(params)
      Resend::Emails.send(params)
    end

    def handle_email_error(user, error)
      error_details = {
        error: "EmailDeliveryError",
        message: error.message,
        user_id: user&.id,
        email: user&.email,
        time: Time.current.iso8601,
      }

      Rails.logger.error error_details.to_json
      Sentry.capture_exception(error) if defined?(Sentry)
    end
  end
end
