source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

if RUBY_VERSION < "1.9"
  gem 'activesupport', '~> 3.1.12'
  gem 'nokogiri', '~> 1.5.0'
else
  gem 'activesupport'
end
gem 'i18n'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", "~> 2.5.0"
  gem "rdoc", "~> 3.8"
  gem "mocha", "~> 0.10.0"
  gem "bundler"
  gem "jeweler"
  gem "simplecov"
end
