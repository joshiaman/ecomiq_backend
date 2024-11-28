# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
    before_action :authorize_request, only: [:create]

    def create
      order = Order.find(params[:order_id])

      if order.payment_status == 'paid' && order.order_items.pluck(:product_id).include?(params[:product_id].to_i)
        review = Review.new(review_params.merge(user_id: @current_user.id, order_id: order.id))
        
        if review.save
          render json: { message: 'Review created successfully' }, status: :created
        else
          render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        end
      elsif order.payment_status != 'paid'
        render json: { error: 'Review can only be created for products in your order' }, status: :unprocessable_entity
      else
        render json: {message: "Oops!! Product you are trying to review is not a part of your order"}, status: :unprocessable_entity
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
  