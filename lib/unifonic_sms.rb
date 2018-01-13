require 'net/http'
require "unifonic_sms/version"
require 'unifonic_sms/error_code'
require 'unifonic_sms/normalizer'
require 'unifonic_sms/configuration'

module UnifonicSms  
  class << self

    attr_accessor :configuration

    # Get the Configurations or Reset.
    # 
    # @return [QiwaSms::Configuration] Configuration.
    def configuration
      @configuration ||= Configuration.new
    end

    # Reset Configuration to nil.
    def reset
      @configuration = Configuration.new
    end

    # Holds the configurtion block.
    def configure
      yield(configuration)
    end    

    # Get the api key from the configurations.
    # 
    # @return [String] Api Key.
    def api_key
      configuration.api_key
    end    

    # Get the phone number of the sender from the configurations.
    # 
    # @return [String] Phone Number.
    def sender_phone
      configuration.sender_phone
    end

    # Get the base url for api call.
    # 
    # @param method_url [String] the api method url.
    # @return [String] Url for Api Call. 
    def base_path (method_url)
      "/rest/#{method_url}"
    end

    # Get Account's Current Balance.
    #
    # @return [String] balance of the Account.
    # @return [String] shared balance with sub accounts.
    # @return [String] currency code used with cost.
    # @return [String] Code status of the response if 0 its a success else its an error.
    def balance
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Account/GetBalance")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { balance: response_body["data"]["Balance"],
                 currency_code: response_body["data"]["CurrencyCode"],
                 shared_balance: response_body["data"]["SharedBalance"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end         
    end 

    # Send SMS message.
    #
    # @param [String] phone The Recipient phone number.
    # @param [String] message Body of the message to be sent.
    # @param [String, nil] time_schedualed Schedualed time to send the message. 
    #
    # @return [String] Message ID.
    # @return [String] Status of message possible values are "Queued" , "Sent", "Failed" and "Rejected".
    # @return [String] Number of unit in a message.
    # @return [String] Price of a message total units.
    # @return [String] The currency code used eith cost.
    # @return [String] Current balance of your account.
    # @return [String] The mobile number the message was sent to.
    # @return [String] Date a message was created in, in the following format "yyyy-mm-dd hh:mm:ss".
    # @return [String] Code status of the response if 0 its a success else its an error.
    def send_message (phone, message, time_schedualed = nil)
      # Adjust Parameters
      recipient = Normalizer.normalize_number(phone)
      message = Normalizer.normalize_message(message)

      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/Send")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}&Recipient=#{recipient}&Body=#{message}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.nil?
      body += '&Priority=High'
      body += '&TimeScheduled=#{time_schedualed}' unless time_schedualed.nil?
      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { message_id: response_body["data"]["MessageID"], 
                 status: response_body["data"]["Status"], 
                 number_of_units: response_body["data"]["NumberOfUnits"],
                 cost: response_body["data"]["Cost"],
                 currency_code: response_body["data"]["CurrencyCode"],
                 balance: response_body["data"]["Balance"],
                 recipient: response_body["data"]["Recipient"],
                 time_created: response_body["data"]["TimeCreated"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end

    # Send Bulk SMS messages
    # Max is 1,000 recipents per request.
    #
    # @param [String] phones The Recipients phone numbers seperated by comma.
    # @param [String] message Body of the message to be sent.
    # @param [String, nil] time_schedualed Schedualed time to send the message. 
    #
    # @return [Array<Hash>] Messages.
    # @return [String] Status of message possible values are "Queued" , "Sent", "Failed" and "Rejected".
    # @return [String] Number of unit in a message.
    # @return [String] Price of a message total units.
    # @return [String] The currency code used eith cost.
    # @return [String] Current balance of your account.
    # @return [String] The mobile numbers the message was sent to.
    # @return [String] Date a message was created in, in the following format "yyyy-mm-dd hh:mm:ss".
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def send_bulk (phones, message, time_schedualed = nil)
      # Adjust Parameters
      recipients = []
      phone_numbers = phones.split(",")
      phone_numbers.each do |phone|
        recipients.push(Normalizer.normalize_number(phone))
      end
      message = Normalizer.normalize_message(message)

      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/SendBulk")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}&Recipient="

      # Add Recipents to body attributes
      recipients.each_with_index do |phone, index|
        body += phone
        if index != (recipients.count - 1)
          body += ","
        end
      end

      body += "&Body=#{message}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.nil?
      body += '&TimeScheduled=#{time_schedualed}' unless time_schedualed.nil?
      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { messages: response_body["data"]["Messages"], 
                  status: response_body["data"]["Status"], 
                  number_of_units: response_body["data"]["NumberOfUnits"],
                  cost: response_body["data"]["Cost"],
                  currency_code: response_body["data"]["CurrencyCode"],
                  balance: response_body["data"]["Balance"],
                  recipient: response_body["data"]["Recipient"],
                  time_created: response_body["data"]["TimeCreated"],
                  code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # Get Message Status.
    #
    # @param [String] message_id The ID of the message.
    #
    # @return [String] Status of message possible values are "Queued" , "Sent", "Failed" and "Rejected".
    # @return [String] DLR Message delivery status returned by networks, the possible values are "Delivered" or "Undeliverable", and are available for advanced plans.
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def message_status (message_id)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}&MessageID=#{message_id}"
      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["Status"].nil? 
        return { status: response_body["Status"], code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # To get a summarized report for sent messages within a specific timer interval
    #
    # @param [String, nil] date_from The start date for the report time interval, date format should be yyyy-mm-dd.
    # @param [String, nil] date_to The end date for the report time interval, date format should be yyyy-mm-dd.
    # @param [String, nil] status Filter messages report according to a specific message status, "Sent", "Queued", "Rejected" or "Failed".
    # @param [String, nil] dlr Message delivery status returned by networks, the possible values are "Delivered" or "Undeliverable", and are available for advanced plans.
    # @param [String, nil] country Filter messages report according to a specific destination country.
    #    
    # @return [String] Number of messages.
    # @return [String] Number of unit in a message.
    # @return [String] Price of a message total units.
    # @return [String] The currency code used eith cost.
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def messages_report (date_from = nil, date_to = nil, status = nil, dlr = nil, country = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessagesReport")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.nil?
      body += "&DateFrom=#{date_from}" unless date_from.nil?
      body += "&DateTo=#{date_to}" unless date_to.nil?
      body += "&Status=#{status}" unless status.nil?
      body += "&DLR=#{dlr}" unless dlr.nil?
      body += "&Country=#{country}" unless country.nil?

      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["TotalTextMessages"].nil? 
        return { total_text_messages: response_body["TotalTextMessages"],
                 number_of_units: response_body["NumberOfUnits"], 
                 cost: response_body["Cost"],
                 currency_code: response_body["CurrencyCode"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # Get latest 10,000 messages details if no message id was provided.
    #
    # @param [String, nil] message_id The ID of the message.
    # @param [String, nil] date_from The start date for the report time interval, date format should be yyyy-mm-dd.
    # @param [String, nil] date_to The end date for the report time interval, date format should be yyyy-mm-dd.
    # @param [String, nil] status Filter messages report according to a specific message status, "Sent", "Queued", "Rejected" or "Failed".
    # @param [String, nil] dlr Message delivery status returned by networks, the possible values are "Delivered" or "Undeliverable", and are available for advanced plans.
    # @param [String, nil] country Filter messages report according to a specific destination country.
    # @param [String, nil] limit Number of messages to return in the report, where the limit maximum is 10,000 and messages are sorted by sending date.
    #    
    # @return [String] Number of messages.
    # @return [String] Page number.
    # @return [Array<Hash>] Messages.
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def messages_details (message_id = nil, date_from = nil, date_to = nil, status = nil, dlr = nil, country = nil, limit = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessagesDetails")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}" unless message_id.nil?
      body += "&SenderID=#{sender_phone}" unless sender_phone.nil?
      body += "&DateFrom=#{date_from}" unless date_from.nil?
      body += "&DateTo=#{date_to}" unless date_to.nil?
      body += "&Status=#{status}" unless status.nil?
      body += "&DLR=#{dlr}" unless dlr.nil?
      body += "&Country=#{country}" unless country.nil?
      body += "&Limit=#{limit}" unless limit.nil?

      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { total_text_messages: response_body["data"]["TotalTextMessages"],
                 page: response_body["data"]["Page"], 
                 messages: response_body["data"]["messages"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end   

    # Get a summarized report for scheduled sent messages.
    #
    # @param [String, nil] message_id The ID of the message.
    #    
    # @return [String] Message ID.
    # @return [String] Message Body.
    # @return [String] Sender ID.
    # @return [String] Recipient.
    # @return [String] Time Schedualed.
    # @return [String] Status.
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def schedualed_messages (message_id = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetScheduled")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}" unless message_id.nil?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 
        return { message_id: response_body["MessageID"],
                 message_body: response_body["MessageBody"], 
                 sender_id: response_body["SenderID"],
                 recipient: response_body["Recipient"],
                 time_schedualed: response_body["TimeScheduled"],
                 status: response_body["Status"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # Get a summarized report for scheduled sent messages.
    #
    # @param [String] message_id The ID of the message.
    #    
    # @return [String] Success if stopped will return "true" else will return empty "".
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def stop_schedualed_messages (message_id)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/StopScheduled")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}"

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { success: response_body["Success"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end     

    # The Keyword method enables you to manage your numbers, 
    # create auto replies to incoming messages or set a webhook directly from your API,
    # Check Keywords Management to view and edit your keywords.
    #
    # @see http://software.unifonic.com/en/inbox/keywords?channel=SMS
    #
    # @param [String] number to manage.
    # @param [String] keyword to use.
    # @param [String] rule for the keyword.
    # @param [String, nil] message Set an auto reply to send back to the user (Ex: You have been successfully registered ).
    # @param [String, nil] webhook_url Defines the source that you want to make the callback to for example “www.google.com”.
    # @param [String, nil] message_parameter Set the parameters that the source takes for example https://www.google.jo/search?q=hello&oq=hello then your parameters that you have to set are q and oq.
    # @param [String, nil] recipient_parameter Set the parameters that the source takes for example https://www.google.jo/search?q=hello&oq=hello then your parameters that you have to set are q and oq.
    # @param [String, nil] request_type Defines the http callback methods , it can be either [Post: Requests data from a specified resource] or [Get: Submits data to be processed to a specified resource].
    # @param [String, nil] resource_number your inbound number for example 70001.
    #    
    # @return [String] Success True, to indicate successfully create of a new keyword.
    # @return [String] Code status of the response if 0 its a success else its an error. 
    def keyword (number, keyword, rule, message = nil, webhook_url = nil, message_parameter = nil, recipient_parameter = nil, request_type = nil, resource_number = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/Keyword")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&Number=#{number}"
      body += "&Keyword=#{keyword}"
      body += "&Rule=#{rule}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.nil?
      body += "&Message=#{message}" unless message.nil?
      body += "&WebhookURL=#{webhook_url}" unless webhook_url.nil?
      body += "&MessageParameter=#{message_parameter}" unless message_parameter.nil?
      body += "&RecipientParameter=#{recipient_parameter}" unless recipient_parameter.nil?
      body += "&RequestType =#{request_type}" unless request_type.nil?
      body += "&ResourceNumber  =#{resource_number}" unless resource_number.nil?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { success: response_body["Success"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # The Keyword method enables you to manage your numbers, 
    # create auto replies to incoming messages or set a webhook directly from your API,
    # Check Keywords Management to view and edit your keywords.
    #
    # @see http://software.unifonic.com/en/inbox/keywords?channel=SMS
    #
    # @param [String] number to manage.
    # @param [String, nil] keyword to use.
    # @param [String, nil] date_from The start date for the report time interval, date format should be yyyy-mm-dd.
    # @param [String, nil] date_to The end date for the report time interval, date format should be yyyy-mm-dd.    
    #    
    # @return [String] Number of messages.
    # @return [String] message from Recipient number.
    # @return [Array<Hash>] received message.
    # @return [String] Code status of the response if 0 its a success else its an error.
    def inbox (number, keyword = nil, date_from = nil, date_to = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/Inbox")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&Number=#{number}"
      body += "&Keyword=#{keyword}" unless keyword.nil?
      body += "&FromDate=#{date_from}" unless date_from.nil?
      body += "&ToDate=#{date_to}" unless date_to.nil?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { number_of_messages: response_body["data"]["NumberOfMessages"],
                 message_from: response_body["data"]["MessageFrom"],
                 message: response_body["data"]["Message"],
                 date_recieved: response_body["data"]["DateReceived"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end   

    # The Keyword method enables you to manage your numbers, 
    # create auto replies to incoming messages or set a webhook directly from your API,
    # Check Keywords Management to view and edit your keywords.
    #
    # @see http://software.unifonic.com/en/inbox/keywords?channel=SMS
    #
    # @param [String, nil] country_code The Country code to check its prices.
    #    
    # @return [Hash] Country Data.
    # @return [String] Country name.
    # @return [String] Code status of the response if 0 its a success else its an error.
    def pricing (country_code = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/Pricing")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&CountryCode=#{country_code}" unless country_code.nil?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].nil? 
        return { country: response_body["data"]["CountryCode"],
                 country_name: response_body["data"]["CountryName"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end                                   
  end
end
