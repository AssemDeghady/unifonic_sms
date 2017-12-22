RSpec.describe UnifonicSms do

  describe "Default Attributes" do

    it "has a version number" do
      expect(UnifonicSms::VERSION).not_to be nil
    end

    it "Can get base path based on method url" do
      url = UnifonicSms.base_path("Messages/Send")

      expect(url).not_to be "/rest/Messages/Send"
    end

    it "Has an Api key" do
      expect(UnifonicSms.api_key).not_to be nil
    end 

    it "Has a sender phone number" do
      expect(UnifonicSms.sender_phone).not_to be nil
    end     

  end

  describe "SMS Methods" do

    it "Can send SMS message to one number" do
      response = UnifonicSms.send_message("+012345954939", "https://www.questionpro.com/t/AN0XRZbIuJ")

      p "====================="
      p response

      expect(response).not_to be nil
    end

  end

end
