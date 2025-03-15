class OrderItemsController < ApplicationController
    before_action :authorize_request
  
    # Displays all items in the user's cart
    def index
        @cart_items = @current_user.order_items.where(order_id: nil).includes(:product)
        render json: @cart_items.as_json(include: {
            product: {
            only: [:id, :name, :description, :price, :sku, :product_image]
            }
        })
    end
  
    # Adds a product to the user's cart (order items without an order_id)
    def add_to_cart
      @order_item = @current_user.order_items.find_or_initialize_by(product_id: params[:product_id], order_id: nil)
  
      if @order_item.new_record?
        @order_item.quantity = params[:quantity] || 1
        @order_item.price = @order_item.product.price
        @order_item.save
        render json: { message: "Product added to cart", order_item: @order_item }, status: :created
      else
        @order_item.increment(:quantity, params[:quantity] || 1)
        @order_item.price = @order_item.product.price
        @order_item.save
        render json: { message: "Product quantity updated in cart", order_item: @order_item }
      end
    end
  
    # Updates the quantity of a product in the user's cart
    def update_quantity
      @order_item = @current_user.order_items.find_by(product_id: params[:product_id], order_id: nil)
  
      if @order_item
        @order_item.update(quantity: params[:quantity], price: @order_item.product.price)
        render json: { message: "Product quantity updated", order_item: @order_item }
      else
        render json: { error: "Product not found in cart" }, status: :not_found
      end
    end
  
    # Removes a product from the user's cart
    def remove_from_cart
      @order_item = @current_user.order_items.find_by(product_id: params[:product_id], order_id: nil)
      
      if @order_item
        @order_item.destroy
        render json: { message: "Product removed from cart" }, status: :ok
      else
        render json: { error: "Product not found in cart" }, status: :not_found
      end
    end
  
    # Clears all items from the user's cart
    def clear_cart
      @current_user.order_items.where(order_id: nil).destroy_all
      render json: { message: "Cart cleared" }, status: :ok
    end
  end
  