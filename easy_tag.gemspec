$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "easy_tag/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "easy_tag"
  s.version     = EasyTag::VERSION
  s.authors     = ["Yen-Ju Chen"]
  s.email       = ["yjchenx@gmail.com"]
  s.homepage    = "https://github.com/yjchen/easy_tag"
  s.summary     = "A very simple tagging system for Rails"
  s.description = "A very simple tagging system for Rails to be forked or extended."
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
  s.signing_key = File.join(Dir.home,'/.gem/trust/gem-private_key.pem')
  s.cert_chain = ['gem-public_cert.pem']

  s.add_dependency "rails", ">= 4.0.0"

  s.add_development_dependency "sqlite3"
end
