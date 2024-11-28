# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :authorize_request, only: [:index, :show]

  def index
    products = Product.includes(:category, :vendor).all

    # Apply filters
    products = products.where(category_id: params[:category_id]) if params[:category_id].present?
    products = products.where('price >= ?', params[:min_price]) if params[:min_price].present?
    products = products.where('price <= ?', params[:max_price]) if params[:max_price].present?

    # Filter by stock availability
    if params[:in_stock].present? && params[:in_stock] == 'true'
      products = products.joins(:inventory).where('inventories.stock > ?', 0)
    end

    render json: products
  end

  # app/controllers/products_controller.rb
  def show
    product = Product.includes(:category, :vendor).find_by(id: params[:id])

    if product.present?
      render json: product.as_json(
        include: {
          category: { only: [:id, :name] },
          vendor: { only: [:id, :name] },
        },
        methods: [:reviews, :avg_product_rating],
        except: [:created_at, :updated_at] # Exclude unwanted fields if needed
      )
    else
      render json: { error: 'Product not found' }, status: :not_found
    end
  end

end
