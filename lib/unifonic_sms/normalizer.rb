module UnifonicSms
  module Normalizer
    # Normalize phone numbers to be used by Unifonic
    # must remove any '+' or '0' at the start.
    #
    # @param [String] number the phone number to be normalized.
    #
    # @example Normalize a phone number
    #   "Normalizer.normalize_number('+01234667876')" #=> "1234667876" 
    def self.normalize_number(number)
      n = number.dup
      while n.start_with?('+') || n.start_with?('0')
        n.slice!(0)
      end
      return n
    end

    # Normalize message to be used by Unifonic
    # must be in UTF-8 Encoding.
    #
    # @param [String] message the message that will be sent.
    #
    # @example Normalize an SMS message
    #   "Normalizer.normalize_message('Test Message').encoding" #=> "UTF_8" 
    def self.normalize_message(message)
      message.encode(Encoding::UTF_8)
    end
  end
end