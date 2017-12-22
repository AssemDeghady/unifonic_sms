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

    # Transform the object to the acceptable json format by questionpro.
    # 
    # @return [Json] options in the call request.
    def options (phone = nil, message = nil)
      return "?AppSid=#{api_key}&SenderID=#{sender_phone}&Recipient=#{phone}&Body=#{message}"
    end             

    def send_message (phone, message)
      url = base_path("Messages/Send")
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      recipient_phone = Normalizer.normalize_number(phone)
      message_normalized = Normalizer.normalize_message(message)

      params = options(recipient_phone, message_normalized)

      url = url + options_string(recipient_phone, message_normalized)

      response = post(url, headers: headers)
      
      # path = sms_path.to_s
      # body = "AppSid=#{appsid}&Recipient=#{to}&Body=#{message_normalized}"
      # body += "&SenderID=#{sender_phone}" if !sender_phone.blank? 
      # body += '&Priority=High'
      
      # response = http.post(path, body, headers)
      # if response.code.to_i >= 200 && response.code.to_i < 300 && !JSON.parse(response.body)["data"].blank? &&
      #   (JSON.parse(response.body)["data"]["Status"] == "Sent" || JSON.parse(response.body)["data"]["Status"] == "Queued")
      #   return { message_id: JSON.parse(response.body)["data"]["MessageID"], code: 0 }
      # else
      #   result = ErrorCode.get_error_code(JSON.parse(response.body)["errorCode"]) 
      #   return result[:error]   
      # end   

      return response
    end


    # def self.send_sms(credentials, mobile_number, message, sender, options = nil)
    #   to = SmsSenderOts::MobileNumberNormalizer.normalize_number(mobile_number)
    #   message_normalized = SmsSenderOts::MobileNumberNormalizer.normalize_message(message)
    #   appsid = credentials['password']
    #   http = Net::HTTP.new('api.unifonic.com', 80)
    #   path = '/rest/Messages/Send'

    #   body = options()
    #   headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    #   response = http.post(path, body, headers)
    #   if response.code.to_i >= 200 && response.code.to_i < 300 && !JSON.parse(response.body)["data"].blank? &&
    #     (JSON.parse(response.body)["data"]["Status"] == "Sent" || JSON.parse(response.body)["data"]["Status"] == "Queued")
    #     return { message_id: JSON.parse(response.body)["data"]["MessageID"], code: 0 }
    #   else
    #     result = SmsSenderOts::ErrorCodes.get_error_code(JSON.parse(response.body)["errorCode"]) 
    #     raise result[:error]
    #     return result
    #   end
    # end
  end
end
