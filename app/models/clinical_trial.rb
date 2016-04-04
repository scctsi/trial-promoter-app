class ClinicalTrial < ActiveRecord::Base
  serialize :hashtags

  validates :initial_database_id, :presence => true
  validates :nct_id, :presence => true
  validates :pi_name, :presence => true
  validates :title, :presence => true
  validates :url, :presence => true

  has_many :messages

  def ==(other_trial)
    # TODO: Unit test
    self.nct_id == other_trial.nct_id
  end

  def self.select_for_randomization
    # TODO: Unit test
    random = Random.new

    clinical_trials = ClinicalTrial.all

    # Sample the 46 trials we need for randomization
    trials_for_randomization = ClinicalTrial.all.to_a.sample(46, random: random)
    trials_for_randomization.each do |clinical_trial|
      clinical_trial.randomization_status = 'Selected'
      clinical_trial.save(:validate => false)
    end

    # What's left?
    remaining_trials = clinical_trials - trials_for_randomization

    # Sample 46 trials from the remaining trials for the control group
    control_group_trials = remaining_trials.sample(46, random: random)
    control_group_trials.each do |clinical_trial|
      clinical_trial.randomization_status = 'Control'
      clinical_trial.save(:validate => false)
    end

    # What's left?
    unused_trials = remaining_trials - control_group_trials
    unused_trials.each do |clinical_trial|
      clinical_trial.randomization_status = 'Unused'
      clinical_trial.save(:validate => false)
    end
  end
end