require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"

module ActiveSupport
  class TestCase
    # Disable parallelization for SimpleCov to work correctly
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helper to create the singleton user for tests
    def create_portfolio_user(attrs = {})
      User.destroy_all # Ensure singleton
      User.create!(
        email: attrs[:email] || "test@example.com",
        password: "password123",
        password_confirmation: "password123",
        full_name: attrs[:full_name] || "Test User",
        headline: attrs[:headline] || "Software Developer",
        bio: attrs[:bio] || "A test bio",
        location: attrs[:location] || "Test City"
      )
    end

    def json_response
      JSON.parse(response.body)
    end
  end
end
