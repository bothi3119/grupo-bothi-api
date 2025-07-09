class ApplicationController < ActionController::API
  include Authenticable

  before_action :authenticate_request, unless: :authentication_controller?

  private

  def authentication_controller?
    self.class.module_parent == Api::V1 &&
    self.class.name.demodulize == "AuthenticationController"
  end
end
