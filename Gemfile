# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'tty-prompt'
gem 'tty-table'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'byebug'
  gem 'factory_bot'
  gem 'ffaker'
  gem 'pry'#, '~> 0.14'
  gem 'pry-byebug'#, '~> 3.8.0'
  gem 'pry-rails'
  gem 'rspec'
  gem 'shoulda-matchers'
end
