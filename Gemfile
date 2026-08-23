# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in kitchen-openstack.gemspec
gemspec development_group: :test
group :test do
  gem "rake"
  gem "kitchen-inspec"
  gem "rspec", "~> 3.2"
  gem "simplecov", "~> 1.0"
end

group :docs do
  gem "yard"
end

group :debug do
  gem "pry"
end

group :cookstyle do
  gem "cookstyle"
end
