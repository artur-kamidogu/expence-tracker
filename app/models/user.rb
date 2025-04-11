class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable
  has_many :categories, dependent: :destroy
  has_many :transactions, dependent: :destroy
  enum role: { user: 0, moderator: 1, admin: 2 }
  after_initialize :set_default_role, if: :new_record?
  validates :name, presence: true, length: { maximum: 50 }
  def set_default_role
    self.role ||= :user
  end
end
