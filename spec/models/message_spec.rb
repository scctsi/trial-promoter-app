# == Schema Information
#
# Table name: messages
#
#  id                          :integer          not null, primary key
#  message_template_id         :integer
#  content                     :text
#  tracking_url                :string(2000)
#  buffer_profile_ids          :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  website_id                  :integer
#  message_generating_id       :integer
#  message_generating_type     :string
#  promotable_id               :integer
#  promotable_type             :string
#  medium                      :string
#  image_present               :string
#  image_id                    :integer
#  publish_status              :string
#  buffer_publish_date         :datetime
#  social_network_publish_date :datetime
#

require 'rails_helper'
require 'google/apis/analytics_v3'

describe Message do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to belong_to :message_template }
  it { is_expected.to enumerize(:publish_status).in(:pending, :published_to_buffer, :published_to_social_network).with_default(:pending).with_predicates(true) }
  it { is_expected.to have_one :buffer_update }
  it { is_expected.to have_many :metrics }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }
  it { is_expected.to belong_to(:promotable) }
  it { is_expected.to enumerize(:medium).in(:ad, :organic).with_default(:organic) }
  it { is_expected.to enumerize(:image_present).in(:with, :without).with_default(:without) }
  it { is_expected.to belong_to :image }

  it 'stores an array of Buffer profiles ids' do
    message = build(:message)
    message.buffer_profile_ids = ["1234abcd", "1234efgh", "1234ijkl"]

    message.save
    message.reload

    expect(message.buffer_profile_ids).to eq(["1234abcd", "1234efgh", "1234ijkl"])
  end
  
  describe "adding metrics" do
    it 'always updates existing metrics from a particular source' do
      message = build(:message)
  
      message.metrics << Metric.new(source: :twitter, data: {"likes": 1})
      message.metrics << Metric.new(source: :twitter, data: {"likes": 2})
  
      expect(message.metrics.length).to eq(1)
      expect(message.metrics[0].data[:likes]).to eq(2)
    end

    it "allows metrics from buffer, google_analytics and the message's platform" do
      message = build(:message)
  
      message.metrics << Metric.new(source: :twitter, data: {"likes": 1})
      message.metrics << Metric.new(source: :google_analytics, data: {"users": 1})
      message.metrics << Metric.new(source: :buffer, data: {"likes": 1})
  
      expect(message.metrics.length).to eq(3)
    end

    it "raises an exception if metrics are being added from a platform other than the message's platform" do
      skip "Cannot get this test to work!"
      message = build(:message)
  
      message.metrics << Metric.new(source: :facebook, data: {'likes': 1})
      expect { message.metrics << Metric.new(source: :facebook, data: {"likes": 1}) }.to raise_error(InvalidMetricSourceError, "Message platform is twitter, but metric source was facebook")
    end
  end
  
  describe 'parsing Google Analytics data' do
    before do
      @ga_data = Google::Apis::AnalyticsV3::GaData.new
      @ga_data.column_headers = []
      %w(ga:campaign ga:sourceMedium ga:adContent).each do |dimension|
        column_header = Google::Apis::AnalyticsV3::GaData::ColumnHeader.new
        column_header.column_type = "DIMENSION"
        column_header.data_type = "STRING"
        column_header.name = dimension
        @ga_data.column_headers << column_header
      end
      %w(ga:sessions ga:users).each do |metric|
        column_header = Google::Apis::AnalyticsV3::GaData::ColumnHeader.new
        column_header.column_type = "METRIC"
        column_header.data_type = "INTEGER"
        column_header.name = metric
        @ga_data.column_headers << column_header
      end
      # Data returned by google uses the same order as the column_headers added above
      @ga_data.rows = []
      @ga_data.rows << ['trial-promoter', 'google / organic', '1-tcors-test-10', '1', '2']
      @ga_data.rows << ['trial-promoter', 'google / organic', '1-tcors-test-11', '2', '3']
      @ga_data.rows << ['trial-promoter', 'google / organic', '1-tcors-test-12', '4', '5']
    end

    it 'parses Google Analytics data into a format that can be used to add metrics to individual messages' do
      ga_metrics = Message.parse_ga_data(@ga_data)
      
      expect(ga_metrics).to eq({'1-tcors-test-10' => { 'ga:sessions' => 1, 'ga:users' => 2}, '1-tcors-test-11' => { 'ga:sessions' => 2, 'ga:users' => 3}, '1-tcors-test-12' => { 'ga:sessions' => 4, 'ga:users' => 5} })
    end
    
    it 'raises an exception if asked to parse Google Analytics data with no ga:adContent dimension metric' do
      @ga_data.column_headers.delete_if { |column_header| column_header.name == 'ga:adContent' }
    
      expect { Message.parse_ga_data(@ga_data) }.to raise_error(MissingAdContentDimensionError, 'Google Analytics data must contain the ga:adContent dimension')
    end
  end

  it "parameterizes id and the experiments's param together" do
    experiment = create(:experiment, name: 'TCORS 2')
    message = create(:message, message_generating: experiment)
    expect(message.to_param).to eq("#{experiment.to_param}-message-#{message.id.to_s}")
  end

  describe 'querying' do
    before do
      @messages = build_list(:message, 5)
      @messages[0].buffer_update = BufferUpdate.new(:buffer_id => "buffer1", :status => :sent, :service_update_id => 'service1')
      @messages[0].save
      @messages[1].buffer_update = BufferUpdate.new(:buffer_id => "buffer2", :status => :sent, :service_update_id => 'service2')
      @messages[1].save
      @messages[2].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => nil)
      @messages[2].save
    end

    it 'finds the message that has a specific service update id' do
      message = Message.find_by_service_update_id('service2')

      expect(message).not_to be_nil
      expect(message.buffer_update.service_update_id).to eq('service2')
    end

    it 'returns nil if no message exists for a specific service update id' do
      message = Message.find_by_service_update_id('unknown')

      expect(message).to be_nil
    end
    
    it 'finds the message that has a specific param' do
      message = Message.find_by_param(@messages[2].to_param)
      
      expect(message).not_to be_nil
      expect(message.to_param).to eq(@messages[2].to_param)
    end

    it 'raises an exception if there is no message with the param' do
      expect { Message.find_by_param('missing-param') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
