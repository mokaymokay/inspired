class Post < ActiveRecord::Base
  has_many :taggings
  has_many :tags, through: :taggings

  validates :quote, :author, presence: true
end
