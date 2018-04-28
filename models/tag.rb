class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :posts, through: :taggings, dependent: :destroy
end
