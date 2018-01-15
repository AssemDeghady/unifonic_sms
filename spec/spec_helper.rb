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

    @test_recipent_number = "+012345954939"
    @test_filtered_recipent_number = "12345954939"
    @test_message_body = "Lorem Ipsum dolo, amet nakht"
    @test_number = "12345678909"
    @test_keyword = "google"
    @test_role = "www.google.com"
    @test_message_id = 48
    @test_country_code = "KSA"

    UnifonicSms.configure do |config|
      config.api_key = "gNNWJasdSKDMwkeopeoODMWowmdkWOImkm"
      config.sender_phone = "9665966612331"
    end
  end    
end
