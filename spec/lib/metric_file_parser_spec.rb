require 'rails_helper'

RSpec.describe MetricFileParser do
  before do
    @metric_file_parser = MetricFileParser.new
    
    twitter_metrics_csv_file_content = <<-CSV
"Tweet id","Tweet permalink","Tweet text","time","impressions","engagements","engagement rate","retweets","replies","favorites","user profile clicks","url clicks","hashtag clicks","detail expands","permalink clicks","app opens","app installs","follows","email tweet","dial phone","media views","media engagements","promoted impressions","promoted engagements","promoted engagement rate","promoted retweets","promoted replies","promoted favorites","promoted user profile clicks","promoted url clicks","promoted hashtag clicks","promoted detail expands","promoted permalink clicks","promoted app opens","promoted app installs","promoted follows","promoted email tweet","promoted dial phone","promoted media views","promoted media engagements"
"649293177409679360","https://twitter.com/USCTrials/status/649293177409679360","Diagnosed with #KidneyCancer? Leading researcher David Quinn @KeckMedUSC is looking for #ClinicalTrial participants http://t.co/gispyAPj8L","2015-09-30 18:42 +0000","424.0","3.0","0.007075471698113208","1.0","2.0","3.0","4.0","5.0","6.0","7.0","8.0","0","0","0","0","0","0","0","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"
"649064976133525504","https://twitter.com/USCTrials/status/649064976133525504","This clinical research study for #GynCSM is now accepting participants http://t.co/ea2ktYDEf9 http://t.co/RIuqAn51Jz","2015-09-30 03:35 +0000","411.0","8.0","0.019464720194647202","0.0","0.0","1.0","1.0","4.0","0.0","2.0","0.0","0","0","0","0","0","0","0","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"
    CSV
    csv = CSV.new(twitter_metrics_csv_file_content)
    @twitter_metrics_csv = csv.read

    facebook_metrics_csv_file_content = <<-CSV
Post ID,Permalink,Post Message,Type,Countries,Languages,Posted,Audience Targeting,Lifetime Post Total Reach,Lifetime Post organic reach,Lifetime Post Paid Reach,Lifetime Post Total Impressions,Lifetime Post Organic Impressions,Lifetime Post Paid Impressions,Lifetime Engaged Users,Lifetime Post Consumers,Lifetime Post Consumptions,Lifetime Negative feedback,Lifetime Negative Feedback from Users,Lifetime Post Impressions by people who have liked your Page,Lifetime Post reach by people who like your Page,Lifetime Post Paid Impressions by people who have liked your Page,Lifetime Paid reach of a post by people who like your Page,Lifetime People who have liked your Page and engaged with your post,Lifetime Average time video viewed,Lifetime Organic views to 95%,Lifetime Organic views to 95%,Lifetime Paid views to 95%,Lifetime Paid views to 95%,Lifetime Video length,Lifetime Organic Video Views,Lifetime Organic Video Views,Lifetime Paid Video Views,Lifetime Paid Video Views
,,,,,,,,Lifetime: The total number of people your Page post was served to. (Unique Users),"Lifetime: The number of people who saw your Page post in news feed or ticker, or on your Page's timeline. (Unique Users)",Lifetime: The number of people your advertised Page post was served to. (Unique Users),Lifetime: The number of impressions of your Page post. (Total Count),Lifetime: The number of impressions of your post in News Feed or ticker or on your Page's Timeline. (Total Count),Lifetime: The number of impressions of your Page post in an Ad or Sponsored Story. (Total Count),Lifetime: The number of people who clicked anywhere in your posts. (Unique Users),Lifetime: The number of people who clicked anywhere in your post. (Unique Users),Lifetime: The number of clicks anywhere in your post. (Total Count),Lifetime: The number of people who have given negative feedback to your post. (Unique Users),Lifetime: The number of times people have given negative feedback to your post. (Total Count),Lifetime: The number of impressions of your Page post to people who have liked your Page. (Total Count),Lifetime: The number of people who saw your Page post because they've liked your Page (Unique Users),Lifetime: The number of paid impressions of your Page post to people who have liked your Page. (Total Count),Lifetime: The number of people who like your Page and who saw your Page post in an ad or sponsored story. (Unique Users),Lifetime: The number of people who have liked your Page and clicked anywhere in your posts. (Unique Users),Lifetime: Average time video viewed (Total Count),Lifetime: Number of times your video was viewed to 95% of its length without any paid promotion. (Total Count),Lifetime: Number of times your video was viewed to 95% of its length without any paid promotion. (Unique Users),Lifetime: Number of times your video was viewed to 95% of its length after paid promotion. (Total Count),Lifetime: Number of times your video was viewed to 95% of its length after paid promotion. (Unique Users),Lifetime: Length of a video post (Total Count),Lifetime: Number of times your video was viewed for more than 3 seconds without any paid promotion. (Total Count),Lifetime: Number of times your video was viewed for more than 3 seconds without any paid promotion. (Unique Users),Lifetime: Number of times your video was viewed more than 3 seconds after paid promotion. (Total Count),Lifetime: Number of times your video was viewed more than 3 seconds after paid promotion. (Unique Users)
951745098223517_980422845355742,https://www.facebook.com/BoostedUSCTrials/posts/980422845355742:0,"This clinical research study for Chronic Inflammatory Demyelinating Polyneuropathy (#CIDP) at Keck Medicine of USC is now accepting participants http://bit.ly/1U2UA2a. We need your help. Without volunteers, clinical studies are not possible. Please share this post. Thank you!",Photo,,,10/1/2015 21:00, ,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,0,,,,,0,,,,
951745098223517_980216225376404,https://www.facebook.com/BoostedUSCTrials/posts/980216225376404:0,Clinical trials are crucial to develop new and better disease treatments. You can easily find clinical trial experts at Keck Medicine of USC. Try our public search tool: http://bit.ly/1UqiiE4. Let us know if you need help or have any questions.,Photo,,,10/1/2015 9:22, ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,,,,0,,,,
    CSV
    csv = CSV.new(facebook_metrics_csv_file_content)
    @facebook_metrics_csv = csv.read

    @messages = build_list(:message, 5)
    @messages[0].buffer_update = BufferUpdate.new(:buffer_id => "buffer1", :status => :sent, :service_update_id => '649293177409679360')
    @messages[0].save
    @messages[1].buffer_update = BufferUpdate.new(:buffer_id => "buffer2", :status => :sent, :service_update_id => '649064976133525504')
    @messages[1].save
    @messages[2].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => nil)
    @messages[2].save
    @messages[3].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => '649064976133525599')
    @messages[3].save
  end

  it "parses a line from a metrics file provided by twitter analytics into a metric" do
    # TODO: The metric file from twitter analytics has one header line, fix metric_file_parser to be aware of this
    metric = @metric_file_parser.to_metric(@twitter_metrics_csv[1], :twitter)

    expect(metric.source).to eq(:twitter)
    expect(metric.data[:impressions]).to eq("424.0")
    expect(metric.data[:engagements]).to eq("3.0")
    expect(metric.data[:engagement_rate]).to eq("0.007075471698113208")
    expect(metric.data[:retweets]).to eq("1.0")
    expect(metric.data[:replies]).to eq("2.0")
    expect(metric.data[:favorites]).to eq("3.0")
    expect(metric.data[:user_profile_clicks]).to eq("4.0")
    expect(metric.data[:url_clicks]).to eq("5.0")
    expect(metric.data[:hashtag_clicks]).to eq("6.0")
    expect(metric.data[:detail_expands]).to eq("7.0")
    expect(metric.data[:permalink_clicks]).to eq("8.0")
  end
  
  it "parses a line from a metrics file provided by facbook insights into a metric" do
    # TODO: The metric file from facebook insights has two header lines, fix metric_file_parser to be aware of this
    metric = @metric_file_parser.to_metric(@facebook_metrics_csv[2], :facebook)

    expect(metric.source).to eq(:facebook)
    expect(metric.data[:lifetime_post_total_reach]).to eq("8")
    expect(metric.data[:lifetime_post_organic_reach]).to eq("9")
    expect(metric.data[:lifetime_post_paid_reach]).to eq("10")
    expect(metric.data[:lifetime_post_total_impressions]).to eq("11")
    expect(metric.data[:lifetime_post_organic_impressions]).to eq("12")
    expect(metric.data[:lifetime_post_paid_impressions]).to eq("13")
    expect(metric.data[:lifetime_engaged_users]).to eq("14")
    expect(metric.data[:lifetime_post_consumers]).to eq("15")
    expect(metric.data[:lifetime_post_consumptions]).to eq("16")
    expect(metric.data[:lifetime_negative_feedback]).to eq("17")
    expect(metric.data[:lifetime_negative_feedback_from_users]).to eq("18")
    expect(metric.data[:lifetime_post_impressions_by_people_who_have_liked_your_page]).to eq("19")
    expect(metric.data[:lifetime_post_reach_by_people_who_like_your_page]).to eq("20")
    expect(metric.data[:lifetime_post_paid_impressions_by_people_who_have_liked_your_page]).to eq("21")
    expect(metric.data[:lifetime_paid_reach_of_a_post_by_people_who_like_your_page]).to eq("22")
    expect(metric.data[:lifetime_people_who_have_liked_your_page_and_engaged_with_your_post]).to eq("23")
  end
  
  it "parses a single line and adds the parsed metric to a specific message based on the service_update_id " do
    @metric_file_parser.parse_line(@twitter_metrics_csv[1], :twitter)
    
    expect(@messages[0].metrics.length).to eq(1)
    expect(@messages[0].metrics[0].source).to eq(:twitter)
    expect(@messages[0].metrics[0].data).not_to be_nil
    expect(@messages[0].persisted?).to be_truthy
  end

  it "parses all the lines from a CSV and adds all parsed metrics to specific messages based on the service_update_id " do
    allow(@metric_file_parser).to receive(:parse_line)
    @metric_file_parser.parse(@twitter_metrics_csv, :twitter)

    expect(@metric_file_parser).to have_received(:parse_line).with(@twitter_metrics_csv[1], :twitter)
    expect(@metric_file_parser).to have_received(:parse_line).with(@twitter_metrics_csv[2], :twitter)
  end
  
  it "reads a CSV file from a URL" do
    csv_content = ''
    
    VCR.use_cassette 'metric_file_parser/read_from_url' do
      csv_content = @metric_file_parser.read_from_url("http://sc-ctsi.org/trial-promoter/tweet_activity_metrics.csv")
    end
  
    expect(csv_content.length).to eq(4)
  end
  
  it "parses a CSV file from a URL" do
    csv_url = "http://sc-ctsi.org/trial-promoter/tweet_activity_metrics.csv"
    csv_content = 'Some content'
    allow(@metric_file_parser).to receive(:read_from_url).and_return(csv_content)
    allow(@metric_file_parser).to receive(:parse)
    
    VCR.use_cassette 'metric_file_parser/parse_from_url' do
      @metric_file_parser.parse_from_url(csv_url, :twitter)
    end
  
    expect(@metric_file_parser).to have_received(:read_from_url).with(csv_url)
    expect(@metric_file_parser).to have_received(:parse).with(csv_content, :twitter)
  end
end