require "bundler/setup"
require "unifonic_sms"
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Change these to a working account with Unifonic
  config.before(:all) do
    @mock_test = true

    if @mock_test
      WebMock.disable_net_connect!(allow_localhost: true)
    end

    UnifonicSms.configure do |config|
      config.api_key = "gNNWJSGUf4x8J3ftiZTCcgdesDmC8"
      config.sender_phone = "966596666011"
    end
  end    
end
