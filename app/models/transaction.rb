class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  validates :amount, presence: true
  validates :date, presence: true
  validates :category, presence: true

  def self.total_incomes
    joins(:category).where(categories: {
      category_type: 'income'
    }).sum(:amount)
  end

  def self.total_expenses
    joins(:category).where(categories: {
      category_type: 'expense'
    }).sum(:amount)
  end

  def self.total_balance
    total_incomes - total_expenses
  end

  def self.total_incomes_per_month
    joins(:category).where(categories: {
      category_type: 'income'
    }).group_by_month(:date, format: '%b %Y').sum(:amount)
  end

  def self.total_expenses_per_month
    joins(:category).where(categories: {
      category_type: 'expense'
    }).group_by_month(:date, format: '%b %Y').sum(:amount)
  end  
end
