require 'rails_helper'

describe "Message Template API" do
  describe "get /api/v1/message_templates" do
    before do
      @created_message_templates = create_list(:message_template, 5)
      get "/api/v1/message_templates"
    end

    it "is successful" do
  		expect(response).to be_success
    end
    
    it "returns all attributes for each message template" do
      expect_json_keys("message_templates.*", [:id, :content, :platform])
    end
    
    it 'returns the correct JSON data types for all attributes' do
      expect_json_types("message_templates.*", {id: :integer, content: :string, platform: :string})
    end
    
    it 'returns all created message templates' do
      expect_json_sizes("message_templates", @created_message_templates.length);
    end
    
    it 'returns the correct values for all the attributes of a message_template' do
      expect_json("message_templates.0", 
                  id: @created_message_templates[0][:id],
                  content: @created_message_templates[0][:content],
                  platform: @created_message_templates[0][:platform])
    end
  end
  
  describe "post /api/v1/message_templates/" do
    before do
      @body = {:content => "This is some content with a {parameter}", :platform => :twitter}
      post "/api/v1/message_templates", @body
    end

    it "is successful" do
  		expect(response).to be_success
    end
    
    it "returns the id attribute of the newly created message template" do
      expect_json_keys([:id])
    end
    
    it 'returns the correct JSON data type for the id attribute' do
      expect_json_types({id: :integer})
    end
    
    it 'successfully creates a new message template' do
      message_template = MessageTemplate.first
      
      expect_json(id: message_template.id)
      expect(message_template.content).to eq(@body[:content])
      expect(message_template.platform).to eq(@body[:platform])
    end
  end
end