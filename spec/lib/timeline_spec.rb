require 'rails_helper'

RSpec.describe Timeline do
  before do
    @timeline = Timeline.new
  end
  
  it 'can be initialized' do
    timeline = Timeline.new
    
    expect(timeline.events).to eq([])
  end
  
  it 'adds events correctly' do
    @timeline.add_event(Time.new(2017, 01, 01, 0, 0, 0), 'Setup must be complete.', 'All experiment setup must be completed.', true)
    
    expect(@timeline.events.count).to eq(1)
    event = @timeline.events[0]
    expect(event.date).to eq(Time.new(2017, 01, 01, 0, 0, 0))
    expect(event.summary).to eq("Setup must be complete.")
    expect(event.description).to eq('All experiment setup must be completed.')
    expect(event.important).to eq(true)
  end
  
  it 'constructs a default timeline for an experiment' do
    experiment = build(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 0), end_date: Time.new(2017, 07, 01, 0, 0, 0))
    
    timeline_for_experiment = Timeline.build_experiment_timeline(experiment)
    
    expect(timeline_for_experiment.events.count).to eq(5)
    expect(timeline_for_experiment.events[0].date).to eq(experiment.message_distribution_start_date - 3.days)
    expect(timeline_for_experiment.events[0].summary).to eq("Setup must be complete.")
    expect(timeline_for_experiment.events[0].description).to eq("All experiment setup must be completed.")
    expect(timeline_for_experiment.events[0].important).to be true
    expect(timeline_for_experiment.events[1].date).to eq(experiment.message_distribution_start_date - 1.day)
    expect(timeline_for_experiment.events[1].summary).to eq("Message generation is locked; Messages pushed up to Buffer (upto a week in advance).")
    expect(timeline_for_experiment.events[1].description).to eq("Messages can no longer be regenerated. The set of messages for the experiment is now locked.")
    expect(timeline_for_experiment.events[1].important).to be false
    expect(timeline_for_experiment.events[2].date).to eq(experiment.message_distribution_start_date)
    expect(timeline_for_experiment.events[2].summary).to eq("Buffer starts posting messages on social media.")
    expect(timeline_for_experiment.events[2].description).to be nil
    expect(timeline_for_experiment.events[2].important).to be false
    expect(timeline_for_experiment.events[3].date).to eq(experiment.end_date)
    expect(timeline_for_experiment.events[3].summary).to eq("Message distrubution completed.")
    expect(timeline_for_experiment.events[3].description).to be nil
    expect(timeline_for_experiment.events[3].important).to be false
    expect(timeline_for_experiment.events[4].date).to eq(experiment.end_date + 4.days)
    expect(timeline_for_experiment.events[4].summary).to eq("Data collection stops.")
    expect(timeline_for_experiment.events[4].description).to be nil
    expect(timeline_for_experiment.events[4].important).to be false
  end
end