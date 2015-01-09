$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bamboo_user/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "bamboo_user"
  s.version = BambooUser::VERSION
  s.authors = ["Praveen Kumar Sinha"]
  s.email = ["praveen.kumar.sinha@gmail.com"]
  s.homepage = "https://github.com/praveenkumarsinha/BambooUser"
  s.summary = "Small rails engine to provide a ready-to-use user engine for login and signup"
  s.description = "Small rails engine to provide a ready-to-use user engine for login and signup"
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.1.1"
  s.add_dependency 'bcrypt', '>= 3.1.7' # Use ActiveModel has_secure_password
  s.add_dependency 'rmagick', '>= 2.13.3'
  s.add_dependency 'photofy', '>= 0.3.1'
end
