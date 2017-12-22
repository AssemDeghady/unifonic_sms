module UnifonicSms
  class Configuration
    
    attr_accessor :api_key, :sender_phone

    def initialize
      @api_key = nil
      @sender_phone = nil
    end
  end
end