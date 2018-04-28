class UpdateForeignKeys < ActiveRecord::Migration[5.2]
  def change
    # remove the old foreign keys
    remove_foreign_key :posts, :users
    remove_foreign_key :taggings, :posts
    remove_foreign_key :taggings, :tags
    # add the new foreign keys
    add_foreign_key :posts, :users, on_delete: :cascade
    add_foreign_key :taggings, :posts, on_delete: :cascade
    add_foreign_key :taggings, :tags, on_delete: :cascade
  end
end
