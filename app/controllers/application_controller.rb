class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session, if: -> { request.format.json? }
    
    private

    def authorize_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header
        @current_user = User.decode_jwt(token)
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    end
end
