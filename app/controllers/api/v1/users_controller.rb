module Api::V1
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy, :update_active]

    # GET /api/v1/users
    def index
      users = User.by_email(params[:email])
        .by_role(params[:role])
        .by_text(params[:text])
        .excluding_system_emails
        .sorted

      @pagy, @users = pagy(users, items: params[:limit])
      render json: paginate_response(@pagy, @users)
    end

    # GET /api/v1/users/1
    def show
      render json: @user
    end

    # POST /api/v1/users
    def create
      @user = User.new(user_create_params)
      if @user.save
        #send_password_reset_email(@user)
        render json: UserSerializer.new(@user).serializable_hash, status: :created
      else
        render_error_response
      end
    end

    # PATCH/PUT /api/v1/users/1
    def update
      raise ApiErrors::UnprocessableEntityError.new(details: @user.errors) unless @user.update(user_update_params)
      render json: @user
    end

    # PATCH /api/v1/users/1/active
    def update_active
      raise ApiErrors::BadRequestError.new(
        details: "Active parameter is required",
      ) unless params[:active].in?([true, false])

      if @user.update(active: params[:active])
        render json: @user
      else
        raise ApiErrors::UnprocessableEntityError.new(details: @user.errors)
      end
    end

    # DELETE /api/v1/users/1
    def destroy
      @user.destroy
      head :no_content
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise ApiErrors::NotFoundError.new(message: "User not found")
    end

    def send_password_reset_email(user)
      Email::PasswordResetService.new(user).call
    rescue ArgumentError => e
      Rails.logger.error "PasswordResetService error: #{e.message}"
    end

    def render_error_response
      error = ApiErrors::UnprocessableEntityError.new(details: @user.errors)
      render json: error.to_h, status: error.status
    end

    def user_create_params
      params.require(:user).permit(
        :first_name,
        :middle_name,
        :last_name,
        :second_last_name,
        :email,
        :phone
      )
    rescue ActionController::ParameterMissing => e
      raise ApiErrors::BadRequestError.new(message: e.message)
    end

    def user_update_params
      params.require(:user).permit(
        :first_name,
        :middle_name,
        :last_name,
        :second_last_name,
        :phone,
        :password
      )
    rescue ActionController::ParameterMissing => e
      raise ApiErrors::BadRequestError.new(message: e.message)
    end
  end
end
