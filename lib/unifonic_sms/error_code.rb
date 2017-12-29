module UnifonicSms
  module ErrorCode    
    # Translates the error code returned by the Api call
    # @see https://unifonic.docs.apiary.io/#reference/errors-list for references
    #
    # @param [String] error_code the error code recieved from response.
    def self.get_error_code(error_code)      
      case error_code
        when "ER-01"
          {error: "Invalid AppSid", code: 1}
        when "ER-02"
          {error: "Missing parameter", code: 2}
        when "ER-03"
          {error: "Sender ID already exists", code: 3}
        when "ER-04"
          {error: "Wrong sender ID format, sender ID should not exceed 11 characters or 16 numbers, only English letters allowed with no special characters or spaces", code: 4}
        when "ER-05"
          {error: "Sender ID is blocked and can't be used", code: 5}
        when "ER-06"
          {error: "Sender ID doesn't exist", code: 6}
        when "ER-07"
          {error: "Default sender ID can't be deleted", code: 7}
        when "ER-08"
          {error: "Sender ID is not approved", code: 8}
        when "ER-09"
          {error: "No sufficient balance", code: 9}
        when "ER-10"
          {error: "Wrong number format , mobile numbers must be in international format without 00 or + Example: (4452023498)", code: 10}
        when "ER-11"
          {error: "Unsupported destination", code: 11}
        when "ER-12"
          {error: "Message body exceeded limit", code: 12}
        when "ER-13"
          {error: "Service not found", code: 13}
        when "ER-14"
          {error: "Sender ID is blocked on the required destination", code: 14}
        when "ER-15"
          {error: "User is Not active", code: 15}
        when "ER-16"
          {error: "Exceed throughput limit", code: 16}
        when "ER-17"
          {error: "Inappropriate content in message body", code: 17}
        when "ER-18"
          {error: "Invalid Message ID", code: 18}
        when "ER-19"
          {error: "Wrong date format, date format should be yyyy-mm-dd", code: 19}
        when "ER-20"
          {error: "Page limit Exceeds (10000)", code: 20}
        when "ER-21"
          {error: "Method not found.", code: 21}
        when "ER-22"
          {error: "Language not supported", code: 22}
        when "ER-23"
          {error: "You have exceeded your Sender ID's requests limit, delete one sender ID to request a new one", code: 23}
        when "ER-24"
          {error: "Wrong Status data , message status should be one of the following statuses \"Queued\" , \"Sent\" , \"Failed\" or \"Rejected\"", code: 24}
        when "ER-25"
          {error: "This request is not included in your account plan", code: 25}
        when "ER-26"
          {error: "Invalid Call ID", code: 26}
        when "ER-27"
          {error: "Wrong Status Data", code: 27}
        when "ER-28"
          {error: "Wrong Email Format", code: 28}
        when "ER-29"
          {error: "Invalid Email ID", code: 29}
        when "ER-30"
          {error: "Invalid Security Type", code: 30}
        when "ER-31"
          {error: "Wrong Passcode", code: 31}
        when "ER-32"
          {error: "Passcode expired", code: 32}
        when "ER-33"
          {error: "Wrong channel type, Channel value should be TextMessage, Call or Both", code: 33}
        when "ER-34"
          {error: "Wrong time to live value TTL, TTL should be between 1 and 60 minutes, and should not exceed the Expiry time", code: 34}
        when "ER-35"
          {error: "MessageID already sent", code: 35}
        when "ER-36"
          {error: "Wrong voice type, voice value should be Male or Female", code: 36}
        when "ER-37"
          {error: "", code: 37}
        when "ER-38"
          {error: "Invalid number; number is not available or had expired for the submitted AppSid", code: 38}
        when "ER-39"
          {error: "Invalid Rule ; rule should be: Is, StartsWith, Contains, Any. Only \"Is\" is available for a shared number", code: 39}
        when "ER-40"
          {error: "Keyword not defined", code: 40}
        when "ER-41"
          {error: "Invalid Country code", code: 41}
        else 
          {error: "Unknown error code", code: error_code}
      end
    end
  end
end