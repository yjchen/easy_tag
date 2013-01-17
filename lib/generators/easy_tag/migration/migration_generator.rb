require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module EasyTag
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc 'add easy tag'

    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    def create_migration_file
      migration_template 'migration.rb', 'db/migrate/easy_tag_migration'
    end
  end
end
