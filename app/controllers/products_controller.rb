class ProductsController < ApplicationController
  def index
    render Views::Products::IndexView.new(products: Product.active.in_stock)
  end

  def show
    render Views::Products::ShowView.new(product: Product.find(params[:id]))
  end
end
