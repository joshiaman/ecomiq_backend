class AuthenticationController < ApplicationController
  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      render json: { status: 'success', message: 'User created successfully', token: user.generate_jwt, user: user }, status: :created
    else
      render json: { status: 'error', message: 'User creation failed', errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { status: 'success', message: 'Login successful', token: user.generate_jwt, user: user }, status: :ok
    else
      render json: { status: 'error', message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :date_of_birth)
  end
end
