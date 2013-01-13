class SimpleTagMigration < ActiveRecord::Migration

  def self.up
    create_table :tags do |t|
      t.string :name
    end

    create_table :tag_context do |t|
      t.string :name
    end

    create_table :taggings do |t|
      t.references :tag
      t.references :tag_context
      t.references :tagger

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
    
      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, :tagger_id
    add_index :taggings, :tag_context_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end

  def self.down
    drop_table :taggings
    drop_table :tag_context
    drop_table :tags
  end

end
