require 'vcr'

VCR.configure do |c|
  c.ignore_hosts 'codeclimate.com'
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end