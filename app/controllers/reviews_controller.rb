# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
    before_action :authorize_request, only: [:create]

    def create
      order = Order.find(params[:order_id])
      
      if order.payment_status == 'paid'
        review = Review.new(review_params.merge(user_id: @current_user.id, order_id: order.id))
        
        if review.save
          render json: { message: 'Review created successfully' }, status: :created
        else
          render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Review can only be created for orders with paid status' }, status: :forbidden
      end
    end

    def show
        if params[:order_id]
          reviews = Review.where(order_id: params[:order_id])
          render json: reviews, status: :ok
        elsif params[:product_id]
          reviews = Review.where(product_id: params[:product_id])
          render json: reviews, status: :ok
        else
          render json: { error: 'Please provide either order_id or product_id' }, status: :unprocessable_entity
        end
    end
  
    private
    def review_params
        params.permit(:rating, :message, :product_id)
    end
end
  