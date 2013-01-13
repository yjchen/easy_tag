class SimpleTagMigration < ActiveRecord::Migration

  def self.up
    create_table :simple_tag_tags do |t|
      t.string :name
    end

    create_table :simple_tag_tag_contexts do |t|
      t.string :name
    end

    create_table :simple_tag_taggings do |t|
      t.references :tag
      t.references :tag_context
      t.references :tagger

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
    
      t.datetime :created_at
    end

    add_index :simple_tag_taggings, :tag_id
    add_index :simple_tag_taggings, :tagger_id
    add_index :simple_tag_taggings, :tag_context_id
    add_index :simple_tag_taggings, [:taggable_id, :taggable_type]
  end

  def self.down
    drop_table :simple_tag_taggings
    drop_table :simple_tag_tag_context
    drop_table :simple_tag_tags
  end

end
