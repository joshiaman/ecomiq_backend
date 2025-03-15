class PaymentsController < ApplicationController
  before_action :authorize_request, only: [:create, :confirm_payment]
  before_action :set_order

  def create
    payment = @order.build_payment(amount: @order.total_price)
    order_id = payment.process_paypal_payment

    if order_id.present?
      # Store the PayPal order ID in the Payment record
      payment.paypal_order_id = order_id
      payment.save!

      # Return the PayPal order ID to the frontend
      render json: { paypal_order_id: order_id, order_id: payment.order_id }, status: :ok
    else
      render json: { error: 'Payment creation failed' }, status: :unprocessable_entity
    end
  end

  # Capture payment after the user returns from PayPal
  def confirm_payment
    payment = @order.payment
    order_id = payment.paypal_order_id
  
    if order_id.blank?
      render json: { error: 'Invalid order' }, status: :unprocessable_entity
      return
    end

    # Call PayPal to capture the payment
    capture_response = payment.capture_paypal_payment(order_id)

    if capture_response == "COMPLETED"
      @order.update(payment_status: Order::PAYMENT_STATUSES[:paid])
      @order.status == Order::STATES[:complete]
      @order.order_items.each(&:adjust_inventory)
      render json: { message: 'Payment confirmed', order: @order }, status: :ok
    else
      @order.payment_status == Order::PAYMENT_STATUSES[:unpaid]
      @order.status == Order::STATES[:incomplete]
      render json: { error: 'Payment confirmation failed' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end
end
