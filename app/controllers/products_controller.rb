# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :authorize_request, only: [ :show, :top_products]

  def index
    products = Product.includes(:category, :vendor).all

    # Apply filters
    products = products.where(category_id: params[:category_id]) if params[:category_id].present?
    products = products.where('price >= ?', params[:min_price]) if params[:min_price].present?
    products = products.where('price < ?', params[:max_price]) if params[:max_price].present?

    # Filter by stock availability
    if params[:in_stock].present? && params[:in_stock] == 'true'
      products = products.where('sku > ?', 0)
    elsif params[:in_stock].present? && params[:in_stock] == 'false'
      products = products.where('sku <= ?', 0)
    end
    

    # Ensure product_image URL is returned correctly
    products = products.map do |product|
      product.as_json.merge(
        product_image: product.product_image.url,
        availability: product.availability
      )
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

  def top_products
  # Fetch top categories based on total order quantity
    top_categories = Category.joins(products: { order_items: :order })
      .where(orders: { status: 'completed' })
      .select('categories.*, COALESCE(SUM(order_items.quantity), 0) AS total_quantity')
      .group('categories.id')
      .order('total_quantity DESC')
      .limit(3)

    # Ensure we have at least 3 categories (fallback to alphabetical order)
    if top_categories.size < 3
      additional_categories = Category.where.not(id: top_categories.pluck(:id)).order(:name).limit(3 - top_categories.size)
      top_categories += additional_categories
    end

    # Fetch top 5 products for each selected category
    top_products_by_category = top_categories.map do |category|
      top_products = category.products.joins(:order_items)
        .select('products.*, COALESCE(SUM(order_items.quantity), 0) AS total_quantity')
        .group('products.id')
        .order('total_quantity DESC')
        .limit(5)

      # Ensure at least 5 products exist, filling with alphabetical order if needed
      if top_products.size < 5
        additional_products = category.products.where.not(id: top_products.pluck(:id)).order(:name).limit(5 - top_products.size)
        top_products += additional_products
      end

      {
        category: {
          id: category.id,
          name: category.name,
          products: random_products.as_json(only: [:id, :name, :price])
        }
      }
    end

    render json: top_products_by_category
  end

  def random_categories_with_products
    eligible_categories = Category.joins(:products)
      .group('categories.id')
      .having('COUNT(products.id) >= 5')
    
    selected_categories = eligible_categories.order('RANDOM()').limit(3)
  
    # Step 3: Fetch 5 random products for each selected category
    categories_with_products = selected_categories.map do |category|
      random_products = category.products.order('RANDOM()').limit(5)
  
      {
        category: {
          id: category.id,
          name: category.name,
          products: random_products.as_json(only: [:id, :name, :price], methods: [:product_image_url])
        }
      }
    end

    render json: categories_with_products
  end
  
end
