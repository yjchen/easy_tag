$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simple_tag/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simple_tag"
  s.version     = SimpleTag::VERSION
  s.authors     = ["Yen-Ju Chen"]
  s.email       = ["yjchenx@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SimpleTag."
  s.description = "TODO: Description of SimpleTag."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.11"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
