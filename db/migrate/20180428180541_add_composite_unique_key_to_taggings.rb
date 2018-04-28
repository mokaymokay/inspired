class AddCompositeUniqueKeyToTaggings < ActiveRecord::Migration[5.2]
  def change
    add_index :taggings, [:post_id, :tag_id], :unique => true
  end
end
