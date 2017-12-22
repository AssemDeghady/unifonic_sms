RSpec.describe UnifonicSms::Normalizer do

  describe "Normalizer Methods" do

    it "Can normalize phone numbers" do
      normalized_number = UnifonicSms::Normalizer.normalize_number("+0123467887")

      expect(normalized_number).to eq("123467887")
    end

    it "Can normalize sms message's content" do
      normalized_message = UnifonicSms::Normalizer.normalize_message("Test Message")

      expect(normalized_message.encoding.to_s).to eq("UTF-8")
    end

  end

end