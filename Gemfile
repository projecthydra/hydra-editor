source "https://rubygems.org"

# Declare your gem's dependencies in hydra-editor.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec path: File.expand_path('..', __FILE__)

# To use debugger
# gem 'debugger'
#
# gem 'sass', '~> 3.2.15'
# gem 'sprockets', '~> 2.11.0'

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
