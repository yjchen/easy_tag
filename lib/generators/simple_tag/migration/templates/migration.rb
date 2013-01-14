class SimpleTagMigration < ActiveRecord::Migration

  def change
    create_table :simple_tag_tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :simple_tag_tag_contexts do |t|
      t.string :name

      t.timestamps
    end

    create_table :simple_tag_taggings do |t|
      t.references :tag
      t.references :tag_context
      t.references :tagger

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
    
      t.timestamps
    end

    add_index :simple_tag_taggings, :tag_id
    add_index :simple_tag_taggings, :tagger_id
    add_index :simple_tag_taggings, :tag_context_id
    add_index :simple_tag_taggings, [:taggable_id, :taggable_type]
  end

end
