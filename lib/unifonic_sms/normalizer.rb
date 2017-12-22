module UnifonicSms
  module Normalizer
    def self.normalize_number(number)
      n = number.dup
      while n.start_with?('+') || n.start_with?('0')
        n.slice!(0)
      end
      return n
    end

    def self.normalize_message(message)
      message.encode(Encoding::UTF_8)
    end
  end
end