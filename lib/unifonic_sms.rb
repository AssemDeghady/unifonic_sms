require 'net/http'
require "unifonic_sms/version"
require 'unifonic_sms/error_code'
require 'unifonic_sms/normalizer'
require 'unifonic_sms/configuration'

module UnifonicSms  
  class << self

    attr_accessor :configuration

    # Get the Configurations or Reset
    # 
    # @return [QiwaSms::Configuration] Configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Reset Configuration to nil
    def reset
      @configuration = Configuration.new
    end

    # Holds the configurtion block
    def configure
      yield(configuration)
    end    

    # Get the api key from the configurations
    # 
    # @return [String] Api Key
    def api_key
      configuration.api_key
    end    

    # Get the phone number of the sender from the configurations
    # 
    # @return [String] Phone Number
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

    def balance
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { balance: response_body["data"]["Balance"],
                 currency_code: response_body["data"]["CurrencyCode"],
                 shared_balance: response_body["data"]["SharedBalance"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end         
    end 

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
      body += "&SenderID=#{sender_phone}" unless sender_phone.blank? 
      body += '&Priority=High'
      body += '&TimeScheduled=#{time_schedualed}' unless time_schedualed.blank?
      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
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

    # Max is 1,000 recipents per request.
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
      body += "&SenderID=#{sender_phone}" unless sender_phone.blank? 
      body += '&TimeScheduled=#{time_schedualed}' unless time_schedualed.blank?
      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
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

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { status: response_body["data"]["Status"], code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    def messages_report (date_from = nil, date_to = nil, status = nil, dlr = nil, country = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.blank?
      body += "&DateFrom=#{date_from}" unless date_from.blank?
      body += "&DateTo=#{date_to}" unless date_to.blank?
      body += "&Status=#{status}" unless status.blank?
      body += "&DLR=#{dlr}" unless dlr.blank?
      body += "&Country=#{country}" unless country.blank?

      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { total_text_messages: response_body["data"]["TotalTextMessages"],
                 number_of_units: response_body["data"]["NumberOfUnits"], 
                 cost: response_body["data"]["Cost"],
                 currency_code: response_body["data"]["CurrencyCode"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    # Return latest 10,000 messages details if no message id was provided
    def messages_details (message_id = nil, date_from = nil, date_to = nil, status = nil, dlr = nil, country = nil, limit = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}" unless message_id.blank?
      body += "&SenderID=#{sender_phone}" unless sender_phone.blank?
      body += "&DateFrom=#{date_from}" unless date_from.blank?
      body += "&DateTo=#{date_to}" unless date_to.blank?
      body += "&Status=#{status}" unless status.blank?
      body += "&DLR=#{dlr}" unless dlr.blank?
      body += "&Country=#{country}" unless country.blank?
      body += "&Limit=#{limit}" unless limit.blank?

      
      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { total_text_messages: response_body["data"]["TotalTextMessages"],
                 page: response_body["data"]["Page"], 
                 messages: response_body["data"]["messages"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end   

    def schedualed_messages (message_id = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}" unless message_id.blank?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { message_id: response_body["data"]["MessageID"],
                 message_body: response_body["data"]["MessageBody"], 
                 sender_id: response_body["data"]["SenderID"],
                 recipient: response_body["data"]["Recipient"],
                 time_schedualed: response_body["data"]["TimeScheduled"],
                 status: response_body["data"]["Status"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    def stop_schedualed_messages (message_id)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&MessageID=#{message_id}"

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { success: response_body["Success"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end     

    def keyword (number, keyword, rule, message = nil, webhook_url = nil, message_parameter = nil, recipient_parameter = nil, request_type = nil, resource_number = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&Number=#{number}"
      body += "&Keyword=#{keyword}"
      body += "&Rule=#{rule}"
      body += "&SenderID=#{sender_phone}" unless sender_phone.blank?
      body += "&Message=#{message}" unless message.blank?
      body += "&WebhookURL=#{webhook_url}" unless webhook_url.blank?
      body += "&MessageParameter=#{message_parameter}" unless message_parameter.blank?
      body += "&RecipientParameter=#{recipient_parameter}" unless recipient_parameter.blank?
      body += "&RequestType =#{request_type}" unless request_type.blank?
      body += "&ResourceNumber  =#{resource_number}" unless resource_number.blank?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
        return { success: response_body["Success"],
                 code: 0 }
      else
        result = ErrorCode.get_error_code(response_body["errorCode"]) 

        return result   
      end   
    end 

    def keyword (number, keyword = nil, from_date = nil, to_date = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&Number=#{number}"
      body += "&Keyword=#{keyword}" unless keyword.blank?
      body += "&FromDate=#{from_date}" unless from_date.blank?
      body += "&ToDate=#{to_date}" unless to_date.blank?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
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

    def pricing (country_code = nil)
      # Initialize Request
      http = Net::HTTP.new('api.unifonic.com', 80)
      path = base_path("Messages/GetMessageIDStatus")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      # Add Body Parameters to request
      body = "AppSid=#{api_key}"
      body += "&CountryCode=#{country_code}" unless country_code.blank?

      # Send Call Request
      response = http.post(path, body, headers)
      response_body = JSON.parse(response.body)

      if response.code.to_i == 200 && !response_body["data"].blank? 
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
