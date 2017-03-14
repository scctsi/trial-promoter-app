require 'rails_helper'

RSpec.describe Timeline do
  before do
    @experiment = build(:experiment)
  end
  
  it 'can be initialized' do
    timeline = Timeline.new
    
    expect(timeline.events).to eq([])
  end
  
  it 'adds events correctly' do
    timeline = Timeline.new

    timeline.add_event(DateTime.new(2000, 1, 1, 12, 30, 0), 'Summary', 'Description')
    
    expect(timeline.events.count).to eq(1)
    expect(timeline.events[0].date).to eq(DateTime.new(2000, 1, 1, 12, 30, 0))
    expect(timeline.events[0].summary).to eq('Summary')
    expect(timeline.events[0].description).to eq('Description')
  end
  
  xit 'builds a default timeline for an experiment' do
    timeline = Timeline.build_default_timeline(@experiment)
    
    expect(timeline.events.count).to eq(4)
    expect(timeline.events[0].date).to eq(@experiment.message_distribution_start_date - 3.days)
    expect(timeline.events[0].summary).to eq('Finish experiment setup; Message generation will be locked')
    expect(timeline.events[0].description).to eq('Trial Promoter will no longer allow messages to be generated. Trial Promoter will send messages to Buffer (upto a week in advance) for distribution to social networks.')
    expect(timeline.events[1].date).to eq(@experiment.message_distribution_start_date)
    expect(timeline.events[1].summary).to eq('Buffer starts distributing messages to social networks.')
    expect(timeline.events[1].description).to eq('')
    expect(timeline.events[2].date).to eq(@experiment.end_date)
    expect(timeline.events[2].summary).to eq('Buffer distributes the last set of messages to social networks.')
    expect(timeline.events[2].description).to eq('')
    expect(timeline.events[3].date).to eq(@experiment.end_date + 3.days)
    expect(timeline.events[3].summary).to eq('Trial Promoter stops collecting data.')
    expect(timeline.events[3].description).to eq('')
  end
end