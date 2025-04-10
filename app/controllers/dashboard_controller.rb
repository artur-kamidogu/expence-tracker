class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @categories = current_user.categories
    @transactions = current_user.transactions.includes(:category)

    @total_per_category = @transactions.group(:name).sum(:amount)
  end
end
