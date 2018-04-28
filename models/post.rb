class Post < ActiveRecord::Base
  belongs_to :user

  has_many :taggings
  has_many :tags, through: :taggings, dependent: :destroy

  default_scope { order(created_at: :desc) }
end
