# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"

  add_group "Core", "lib/better_seo"
  add_group "DSL", "lib/better_seo/dsl"
  add_group "Generators", "lib/better_seo/generators"
  add_group "Validators", "lib/better_seo/validators"

  minimum_coverage 90
end

require "better_seo"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset BetterSeo configuration before each test
  config.before(:each) do
    BetterSeo.reset_configuration! if BetterSeo.respond_to?(:reset_configuration!)
  end

  # Random order
  config.order = :random
  Kernel.srand config.seed
end
