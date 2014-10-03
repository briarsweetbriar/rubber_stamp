$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rubber_stamp/version_number"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rubber_stamp"
  s.version     = RubberStamp::VERSION_NUMBER
  s.authors     = ["timothycommoner"]
  s.email       = ["timothythehuman@gmail.com"]
  s.homepage    = "https://github.com/timothycommoner/rubber_stamp"
  s.summary     = "Adds model versioning to a Rails app, with the ability to " +
                  "approve and declined revisions."
  s.description = "With RubberStamp, you can make any model " +
                  "versionable. This will record suggested changes to the " +
                  "model, which can then be approved or declined according " +
                  "to your application's design."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile",
            "README.rdoc"]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "diff_match_patch_native", '~> 1.0.2'

  s.add_development_dependency "pg"
  s.add_development_dependency "byebug"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-spork"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'timecop'
end