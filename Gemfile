source 'https://rubygems.org'

ruby '2.3.1'

gem 'annotate'
gem 'devise'
gem 'enumerize'
gem 'fit-commit'
gem 'haml'
gem 'haml-rails', '~> 0.9'
gem 'jquery-rails'
gem 'pg'
gem 'rails', '4.2.6'
gem 'rails-settings-cached'
gem 'sass-rails', '~> 5.0'
gem 'semantic-ui-sass', github: 'doabit/semantic-ui-sass'
gem 'simple_form'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.5'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'factory_girl_rails', "~> 4.0"
  gem 'shoulda-matchers', '~> 3.1', require: false
end

group :production do
  gem 'rails_12factor'
end