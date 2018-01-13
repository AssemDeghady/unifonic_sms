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

  describe "Account Methods" do

    it "Can get account's balance" do

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Account/GetBalance").
          with(body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8"},
              headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: {
                      "success" => "true",
                      "message" => "",
                      "errorCode" => "ER-00",
                      data: {
                        "Balance" => "48.03200",
                        "CurrencyCode" => "USD",
                        "SharedBalance" => "0.00000"
                      }                    
                    }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.balance

      expect(response[:balance]).not_to be nil
    end

  end

  describe "SMS Methods" do

    it "Can send SMS message to one number" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/Send").
          with(body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8", 
                      "Body"=>"https://www.questionpro.com/t/AN0XRZbIuJ", 
                      "Priority"=>"High", "Recipient"=>"12345954939", 
                      "SenderID"=>"966596666011"},
               headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { data: {
                            "MessageID"  => "6542",
                            "Status"  => "Sent",
                            "NumberOfUnits"  => "1",
                            "Cost" => 0.4,
                            "Balance" => "100",
                            "Recipient" => "12345954939",
                            "DateCreated" => "2014-07-22"
                          }}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.send_message("+012345954939", "https://www.questionpro.com/t/AN0XRZbIuJ")

      expect(response[:message_id]).not_to be nil
    end

    it "Can send Bulk SMS messages to multiple numbers" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/SendBulk").
          with(body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8", 
                      "Body"=>"https://www.questionpro.com/t/AN0XRZbIuJ", 
                      "Recipient"=>"12345954939, 012345954939, 12345954939",
                      "SenderID"=>"966596666011"},
               headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { 
                            data: {
                              Messages: [
                                {
                                  "MessageID" => "310856",
                                  "Recipient" => "962795949563",
                                  "Status" => "Queued"
                                },
                                {
                                  "MessageID" => "310857",
                                  "Recipient" => "962790606334",
                                  "Status" => "Queued"
                                }
                              ],
                              "NumberOfUnits" => 2,
                              "Cost" => 0,
                              "Balance" => 136408.541,
                              "TimeCreated" => "2014-10-16 09:16:55",
                              "CurrencyCode" => "USD"
                            }}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.send_bulk("+012345954939, 012345954939, 12345954939", "https://www.questionpro.com/t/AN0XRZbIuJ")

      expect(response[:cost]).not_to be nil
    end

    it "Can get SMS message status" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetMessageIDStatus")
          .with( body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8", "MessageID"=>"6423"},
                 headers: {'Content-Type'=>'application/x-www-form-urlencoded'})
          .to_return(status: 200, 
                    body: {"Status" => "Sent"}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.message_status(6423)

      expect(response[:status]).not_to be nil
    end    

    it "Can get SMS messages report" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetMessagesReport").
          with( body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8",                      
                      "SenderID"=>"966596666011"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { "TotalTextMessages" => "150",
                            "NumberOfUnits" => "160",
                            "Cost" => "35"}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.messages_report

      expect(response[:total_text_messages]).not_to be nil
    end  

    it "Can get SMS messages details" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetMessagesDetails").
          with( body: {"AppSid"=>"gNNWJSGUf4x8J3ftiZTCcgdesDmC8", "SenderID"=>"966596666011"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { 
                      data: {
                        "TotalTextMessages" => "3",
                        "Page" => "1",
                        messages: [
                          {
                            "MessageID" => "6423",
                            "Body" => "Message Body",
                            "Recipient" => 962795989856,
                            "Status" => "Sent",
                            "Datecreated" => "2014-07-22",
                            "SenderID" => "TestSender",
                            "NumberOfUnits" => "2",
                            "Cost" => "0.04",

                          },
                          {
                            "message_id" => "6422",
                            "Body" => "Message Body",
                            "Recipient" => 962795989876,
                            "Status" => "Sent",
                            "Datecreated" => "2014-07-22",
                            "SenderID" => "TestSender",
                            "NumberOfUnits" => "1",
                            "Cost" => "0.02",
                          },
                          {
                            "message_id" => "6421",
                            "Body" => "Message Body",
                            "Recipient" => 9627895985555,
                            "Status" => "Sent",
                            "Datecreated" => "2014-07-22",
                            "SenderID" => "TestSender",
                            "NumberOfUnits" => "2",
                            "Cost" => "0.04",
                          }
                        ],
                        "TotalTextMessages" => "6421",
                        "page" => 1
                      }
                    }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.messages_details

      expect(response[:total_text_messages]).not_to be nil
    end            

  end

end
