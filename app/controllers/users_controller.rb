class UsersController < ApplicationController
  before_action :authorize_request, only: [:index, :show, :update]

  def index
    render json: { status: 'success', user: @current_user }, status: :ok
  end

  def show
    render json: { status: 'success', user: @current_user }, status: :ok
  end

  def update
    if @current_user.update(user_params)
      render json: { status: 'success', message: 'User details updated successfully', user: @current_user }, status: :ok
    else
      render json: { status: 'error', message: 'User update failed', errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :password, :date_of_birth)
  end
end
