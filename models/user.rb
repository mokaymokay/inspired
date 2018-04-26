class User < ActiveRecord::Base
  has_many :posts

  validates :first_name, :username, :email, presence: true
  validates :email, uniqueness: true
  validates :password, length: { in: 6..20 }
end
