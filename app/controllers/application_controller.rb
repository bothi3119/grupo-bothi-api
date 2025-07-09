class ApplicationController < ActionController::API
  include ErrorHandler
  include Authenticable
  include Pagy::Backend
  include PaginationConcern

  before_action :authenticate_request, unless: :authentication_controller?

  private

  def authentication_controller?
    self.class.module_parent == Api::V1 &&
    self.class.name.demodulize == "AuthenticationController"
  end
end
