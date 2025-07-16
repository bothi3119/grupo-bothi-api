require "resend"

Resend.configure do |config|
  config.api_key = Rails.env.production? ?
    Rails.application.credentials.dig(:resend, :api_key) :
    ENV["RESEND_API_KEY"]
end
