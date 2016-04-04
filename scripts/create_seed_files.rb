require 'seed-fu'
require 'csv'

SeedFu::Writer.write('../db/fixtures/clinical_trials.rb', :class_name => 'ClinicalTrial', :constraints => [:nct_id]) do |writer|
  CSV.foreach("clinical_trials.csv", { :headers=>:first_row }) do |row|
    hashtags = row[21].split(",").collect{|x| x.strip}
    writer.add(:initial_database_id => row[0], :nct_id => row[1], :pi_name => "#{row[6]} #{row[7]}", :url => "http://clinicaltrials.keckmedicine.org/clinicaltrials/#{row[0]}", :title => row[9], :hashtags => hashtags, :disease => row[22])
  end
end

SeedFu::Writer.write('../db/fixtures/twitter_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("twitter_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[2].index('awareness') != nil
    message_type = 'recruiting' if row[2].index('recruiting') != nil

    content = row[4]
    content.gsub! "#disease", "<%= message[:disease_hashtag] %>"
    content.gsub! "http://bit.ly/1234567", "<%= message[:url] %>"
    content.gsub! "Principal Investigator", "<%= message[:pi] %>"

    writer.add(:initial_id => row[0], :platform => row[1].downcase, :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/facebook_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("facebook_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[0].to_i <= 30
    message_type = 'recruiting' if row[0].to_i > 30

    content = row[2]
    content.gsub! "#disease", "<%= message[:disease_hashtag] %>"
    content.gsub! "http://bit.ly/1234567", "<%= message[:url] %>"
    content.gsub! "Principal Investigator", "<%= message[:pi] %>"

    writer.add(:initial_id => row[0], :platform => row[1].downcase, :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/google_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("google_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[0].to_i <= 30
    message_type = 'recruiting' if row[0].to_i > 30

    content = [row[1], row[2], row[3]]
    content.each {|content_line| content_line.gsub! /disease/i, "<%= message[:disease] %>"}

    writer.add(:initial_id => row[0], :platform => 'google', :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/youtube_search_results_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("youtube_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[0].to_i <= 30
    message_type = 'recruiting' if row[0].to_i > 30

    content = [row[1], row[2], row[3], row[4]]
    content.each {|content_line| content_line.gsub! /disease/i, "<%= message[:disease] %>"}
    content.each {|content_line| content_line.gsub! /"/i, ""}

    writer.add(:initial_id => row[0], :platform => 'youtube_search_results', :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/twitter_uscprofiles_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("twitter_uscprofiles_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness'

    content = row[2]
    content.gsub! "http://bit.ly/1234567", "<%= message[:url] %>"
    content.gsub! "Principal Investigator", "<%= message[:pi] %>"
    content.gsub! "#disease", "<%= message[:disease_hashtag] %>"

    writer.add(:initial_id => row[0], :platform => 'twitter_uscprofiles', :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/facebook_uscprofiles_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("facebook_uscprofiles_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness'

    content = row[2]
    content.gsub! "http://bit.ly/1234567", "<%= message[:url] %>"
    content.gsub! "Principal Investigator", "<%= message[:pi] %>"
    content.gsub! "#disease", "<%= message[:disease_hashtag] %>"

    writer.add(:initial_id => row[0], :platform => 'facebook_uscprofiles', :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/google_uscprofiles_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("google_uscprofiles_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness'

    content = [row[1], row[2], row[3]]
    content.each {|content_line| content_line.gsub! /disease/i, "<%= message[:disease] %>"}

    writer.add(:initial_id => row[0], :platform => 'google_uscprofiles', :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/youtube_uscprofiles_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("youtube_uscprofiles_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness'

    content = [row[1], row[2], row[3], row[4]]
    content.each {|content_line| content_line.gsub! /disease/i, "<%= message[:disease] %>"}
    content.each {|content_line| content_line.gsub! /"/i, ""}

    writer.add(:initial_id => row[0], :platform => 'youtube_uscprofiles', :message_type => message_type, :content => content)
  end
end