class OrdersController < ApplicationController
  before_action :authorize_request, only: [:index, :pending_payment, :checkout]

  def index
    @orders = @current_user.orders.includes(order_items: :product).where(payment_status: Order::PAYMENT_STATUSES[:paid])
    render json: @orders.as_json(include: {
      order_items: {
        include: {
          product: { only: [:id, :name, :description, :price, :sku] }
        },
        only: [:id, :quantity, :price]
      }
    })
  end

  def checkout
    cart_items = @current_user.order_items.where(order_id: nil)

    if cart_items.empty?
      render json: { error: "Your cart is empty" }, status: :unprocessable_entity
      return
    end

    # Create order and associate all cart items with it
    @order = @current_user.orders.build(total_price: calculate_total(cart_items))
    if @order.save
      cart_items.update_all(order_id: @order.id)
      render json: { message: "Order created, please proceed to payment", order: @order }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def pending_payment
    orders = @current_user.orders.where(payment_status: Order::PAYMENT_STATUSES[:unpaid])
    if !(orders.empty?)
      orders.includes(order_items: :product)
      render json: orders.as_json(include: {
      order_items: {
        include: {
          product: { only: [:id, :name, :description, :price, :sku] }
        },
        only: [:id, :quantity, :price]
      }
    }) 
    else
      render json: { error: "Order is already confirmed or completed" }, status: :unprocessable_entity
    end
  end

  private
  def calculate_total(cart_items)
    cart_items.sum { |item| item.quantity * item.product.price  * 1.18 }
  end
end
