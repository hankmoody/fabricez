source 'http://rubygems.org'

gem 'rails', '3.1.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "rake", "0.8.7"
gem 'devise'
gem 'paperclip' , :path => "vendor/gems/paperclip"
gem 'kaminari'
gem 'aws-sdk'
gem "simple_form"
gem 'client_side_validations'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
#  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem "rspec-rails", :group => [:test, :development]
gem 'ruby-debug19', :require => 'ruby-debug', :group => [:development, :test]
group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'factory_girl_rails'
  gem "capybara"
  gem "guard-rspec"  
  gem "spork", "> 0.9.0.rc"
  # gem "guard-spork"
  gem "win32console"
end
