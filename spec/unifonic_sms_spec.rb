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
          with(body: {"AppSid"=>"#{UnifonicSms.api_key}"},
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
          with(body: {"AppSid"=>"#{UnifonicSms.api_key}", 
                      "Body"=>"#{@test_message_body}", 
                      "Priority"=>"High", "Recipient"=>"#{@test_filtered_recipent_number}", 
                      "SenderID"=>"#{UnifonicSms.sender_phone}"},
               headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { data: {
                            "MessageID"  => "6542",
                            "Status"  => "Sent",
                            "NumberOfUnits"  => "1",
                            "Cost" => 0.4,
                            "Balance" => "100",
                            "Recipient" => "#{@test_filtered_recipent_number}",
                            "DateCreated" => "2014-07-22"
                          }}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.send_message(@test_recipent_number, @test_message_body)

      expect(response[:message_id]).not_to be nil
    end

    it "Can send Bulk SMS messages to multiple numbers" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/SendBulk").
          with(body: {"AppSid"=>"#{UnifonicSms.api_key}", 
                      "Body"=>"#{@test_message_body}", 
                      "Recipient"=>"#{@test_number}, #{@test_number}, #{@test_number}",
                      "SenderID"=>"#{UnifonicSms.sender_phone}"},
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

      response = UnifonicSms.send_bulk("#{@test_number}, #{@test_number}, #{@test_number}", @test_message_body)

      expect(response[:cost]).not_to be nil
    end

    it "Can get SMS message status" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetMessageIDStatus")
          .with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "MessageID"=>"#{@test_message_id}"},
                 headers: {'Content-Type'=>'application/x-www-form-urlencoded'})
          .to_return(status: 200, 
                    body: {"Status" => "Sent"}.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.message_status(@test_message_id)

      expect(response[:status]).not_to be nil
    end    

    it "Can get SMS messages report" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetMessagesReport").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}",                      
                      "SenderID"=>"#{UnifonicSms.sender_phone}"},
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
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "SenderID"=>"#{UnifonicSms.sender_phone}"},
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

    it "Can get SMS Schedualed messages" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/GetScheduled").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: {
                            "MessageID" => "24",
                            "MessageBody" => "test",
                            "SenderID" => "123456",
                            "Recipient" => "962795516342,962795516348",
                            "TimeScheduled" => "2015-04-29 12:38:06",
                            "Status" => "scheduled"                      
                          }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.schedualed_messages

      expect(response[:code]).to eq(0)
    end  

    it "Can stop SMS Schedualed messages" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/StopScheduled").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "MessageID"=>"#{@test_message_id}"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: {
                            "success" => "true",
                            "message" => "",
                            "errorCode" => "ER-00",
                            "data" => nil                    
                          }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.stop_schedualed_messages(@test_message_id)

      expect(response[:code]).to eq(0)
    end 

    it "Can create Keyword method enables you to manage your numbers" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/Keyword").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "Keyword"=>"#{@test_keyword}", 
                        "Number"=>"#{@test_number}", "Rule"=>"#{@test_role}", "SenderID"=>"#{UnifonicSms.sender_phone}"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { "success" => "true" }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.keyword(@test_number, @test_keyword, @test_role)

      expect(response[:code]).to eq(0)
    end 

    it "Can create Retrieve all incoming messages" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/Inbox").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "Number"=>"#{@test_number}"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { 
                            "success" => "true",
                            "message" => "",
                            "errorCode" => "ER-00",
                            data: {
                              "NumberOfMessages" => 19,
                              Messages: [
                                {
                                  "MessageFrom" => "+962795949563",
                                  "Message" => "new",
                                  "DateReceived" => "2015-09-15 13:40:56"
                                },
                                {
                                  "MessageFrom" => "+962795949563",
                                  "Message" => "Areen",
                                  "DateReceived" => "2015-09-15 13:18:10"
                                }
                              ]
                            }
                          }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.inbox(@test_number)

      expect(response[:code]).to eq(0)
    end  

    it "Can retrieve outbound messaging pricing for a given country" do  

      if @mock_test
        stub_request(:post, "http://api.unifonic.com/rest/Messages/Pricing").
          with( body: {"AppSid"=>"#{UnifonicSms.api_key}", "CountryCode"=>"#{@test_country_code}"},
                headers: {'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(status: 200, 
                    body: { 
                            "success" => "true",
                            "message" => "",
                            "errorCode" => "ER-00",
                            data: {
                              Jordan: {
                                Orange: {
                                  "CountryCode" => "JO",
                                  "CountryPrefix" => "962",
                                  "OperatorPrefix" => "77",
                                  "MCC" => "416",
                                  "MNC" => "77",
                                  "Cost" => "0.02800"
                                },
                                Umnia: {
                                  "CountryCode" => "JO",
                                  "CountryPrefix" => "962",
                                  "OperatorPrefix" => "78",
                                  "MCC" => "416",
                                  "MNC" => "3",
                                  "Cost" => "0.02800"
                                },
                                Zain: {
                                  "CountryCode" => "JO",
                                  "CountryPrefix" => "962",
                                  "OperatorPrefix" => "79",
                                  "MCC" => "416",
                                  "MNC" => "1",
                                  "Cost" => "0.02800"
                                }
                              },
                              "CurrencyCode" => "USD"
                            }
                          }.to_json, 
                    headers: {'Content-Type'=>'application/json'})
      end

      response = UnifonicSms.pricing(@test_country_code)

      expect(response[:code]).to eq(0)
    end                 

  end

end
