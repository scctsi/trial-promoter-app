class Timeline
  attr_accessor :events
  
  def initialize
    self.events = []
  end
  
  def add_event(date, summary, description, important)
    event = OpenStruct.new
    event.date = date
    event.summary = summary
    event.description = description
    event.important = important

    events << event
  end
  
  def self.build_experiment_timeline(experiment)
    timeline = Timeline.new
    
    # Event 1: Setup for the experiment must be finalized 3 days before the experiment is scheduled to start distributing messages.
    event_hash = { date: experiment.message_distribution_start_date - 3.days, summary: 'Setup must be complete.', description: 'All experiment setup must be completed.', important: true }
    timeline.events << OpenStruct.new(event_hash)
    # Event 2: Trial Promoter locks message generation a day before message distribution starts. It also starts pushing messages to Buffer (upto a week in advance).
    event_hash = { date: experiment.message_distribution_start_date - 1.day, summary: 'Message generation is locked; Messages pushed up to Buffer (upto a week in advance).', description: 'Messages can no longer be regenerated. The set of messages for the experiment is now locked.', important: false }
    timeline.events << OpenStruct.new(event_hash)
    # Event 3: Buffer starts distributing messages on social media.
    event_hash = { date: experiment.message_distribution_start_date, summary: 'Buffer starts posting messages on social media.', description: nil, important: false }
    timeline.events << OpenStruct.new(event_hash)
    # Event 4: Message distribution is completed.
    event_hash = { date: experiment.end_date, summary: 'Message distrubution completed.', description: nil, important: false }
    timeline.events << OpenStruct.new(event_hash)
    # Event 5: Data collection stops
    event_hash = { date: experiment.end_date + 4.days, summary: 'Data collection stops.', description: nil, important: false }
    timeline.events << OpenStruct.new(event_hash)

    timeline
  end
end