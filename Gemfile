source 'https://rubygems.org'

ruby '2.3.1'

gem 'acts-as-taggable-on', '~> 4.0'
gem 'annotate'
gem 'bitly'
gem 'devise'
gem 'enumerize'
gem 'fit-commit'
gem 'google-api-client', '~> 0.9'
gem 'haml'
gem 'haml-rails', '~> 0.9'
gem 'httparty'
gem 'jquery-rails'
gem 'kaminari'
gem 'pg'
gem 'pundit'
gem 'rails', '4.2.6'
gem 'rails-settings-cached'
gem 'sass-rails', '~> 5.0'
gem 'semantic-ui-sass', github: 'doabit/semantic-ui-sass'
gem 'simple_form'
# gem 'turbolinks', '~> 5.0.0'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'byebug'
  gem 'database_cleaner'
  gem 'faker'
  gem 'rspec-rails', '~> 3.5'
  gem 'spring-commands-rspec'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem 'factory_girl_rails', "~> 4.0"
  gem 'shoulda-matchers', '~> 3.1', require: false
  gem "simplecov"
end

group :production do
  gem 'rails_12factor'
end