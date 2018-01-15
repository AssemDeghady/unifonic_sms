# Unifonic Sms

A Ruby client that allows you to send SMS messages via [Unifonic](http://www.unifonic.com/).

See Messages section in the [Api Documentation](https://unifonic.docs.apiary.io/#reference/messages) to learn about the available actions.

**Note:** All and only the messages methods are supported plus the account's get balance method. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unifonic_sms'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unifonic_sms

## Usage

First make an initializer `unifonic_sms.rb` inside `config/initializers` and add the configurations

```ruby
UnifonicSms.configure do |config|
  config.api_key = "xxxxxx-xxxxxxxxx-xxxxxx-xxxxxxxxxx"
  config.sender_phone = "1234567890123"
end
```

Then start using the available module methods

```ruby
# Get Account Balance.
UnifonicSms.balance

# Send SMS Message.
UnifonicSms.send_message("+012347647843", "Test Message Body")

# Send Bulk SMS Messages.
UnifonicSms.send_bulk("12347647843, 12391283123, 1209831923, 12031293102", "Test Message Body")

# Get SMS Message Status.
UnifonicSms.message_status(3902) # message_id

# Get SMS Messages Report.
UnifonicSms.messages_report

# Get SMS Message Details.
UnifonicSms.messages_details

# Get Schedualed SMS Messages.
UnifonicSms.schedualed_messages

# Stop Schedualed SMS Message.
UnifonicSms.stop_schedualed_messages(3902) # message_id

# Create Keyword.
UnifonicSms.keyword("127318923789", "google", "www.google.com")

# Get Inbox Messages.
UnifonicSms.inbox("127318923789")

# Get Pricing Details. 
UnifonicSms.pricing("KSA") # Country Code
```

## Testing:

By default calls are stubbed, If you want to disable the stubbing you must make `@mock_test` equal `false` in the `spec_helper.rb` file, Then make sure to set all the other variables in the `spec_helper.rb` file to real values.

## Generate documentation:

You must have [Yard](https://github.com/lsegal/yard) gem installed.

```bash
yardoc
```

Documentation will be generated in `/docs`

## Contributing

1. Fork it.

2. Create your feature branch (`git checkout -b my-new-feature`)

3. Commit your changes (`git commit -am 'Add some feature'`)

4. Push to the branch (`git push origin my-new-feature`)

5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
