class Timeline
  attr_accessor :events

  def initialize
    self.events = []
  end

  def add_event(date, summary, description)
    events << OpenStruct.new(:date => date, :summary => summary, :description => description)
  end

  def self.build_default_timeline(experiment)
    timeline = Timeline.new

    timeline.add_event(experiment.message_distribution_start_date - 3.days, 'Finish experiment setup; Message generation will be locked', 'Trial Promoter will no longer allow messages to be generated. Trial Promoter will send messages to Buffer (up to a week in advance) for distribution to social networks.')
    timeline.add_event(experiment.message_distribution_start_date, 'Buffer starts distributing messages to social networks.', '')
    timeline.add_event(experiment.end_date, 'Buffer distributes the last set of messages to social networks.', '')
    timeline.add_event(experiment.end_date + 3.days, 'Trial Promoter stops collecting data.', '')

    timeline
  end
end