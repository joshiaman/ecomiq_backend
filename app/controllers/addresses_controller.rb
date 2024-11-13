class AddressesController < ApplicationController
    before_action :authorize_request
    before_action :set_address, only: [:show, :update, :destroy]
  
    # GET /addresses
    def index
      addresses = @current_user.addresses
      render json: { status: 'success', addresses: addresses }, status: :ok
    end
  
    # GET /addresses/:id
    def show
      render json: { status: 'success', address: @address }, status: :ok
    end
  
    # POST /addresses
    def create
      address = @current_user.addresses.build(address_params)
      if address.save
        render json: { status: 'success', message: 'Address created successfully', address: address }, status: :created
      else
        render json: { status: 'error', message: 'Address creation failed', errors: address.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PUT /addresses/:id
    def update
      if @address.update(address_params)
        render json: { status: 'success', message: 'Address updated successfully', address: @address }, status: :ok
      else
        render json: { status: 'error', message: 'Address update failed', errors: @address.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /addresses/:id
    def destroy
      @address.destroy
      render json: { status: 'success', message: 'Address deleted successfully' }, status: :ok
    end
  
    private
  
    def set_address
      @address = @current_user.addresses.find_by(id: params[:id])
      unless @address
        render json: { status: 'error', message: 'Address not found' }, status: :not_found
      end
    end
  
    def address_params
      params.permit(:street, :city, :state, :zip, :country)
    end
  end
  