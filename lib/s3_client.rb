require 'aws-sdk'

class S3Client
  attr_accessor :s3_client

  def initialize
    credentials = Aws::Credentials.new(Setting[:aws_access_key_id], Setting[:secret_access_key])

    Aws.config.update({
      region: 'us-west-1',
      credentials: credentials,
      endpoint:'http://localhost:3000'
    })
    s3_client = Aws::S3::Client.new(credentials: credentials, region: 'us-west-1', endpoint: 'http://localhost:3000')
  end

  def asset_exists_in_s3?(image)
    p image.s3_key
    p image.s3_bucket
    credentials = Aws::Credentials.new(Setting[:aws_access_key_id], Setting[:secret_access_key])
    object = Aws::S3::Object.new('scctsi-tp-development', '13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg', region: 'us-west-1', credentials: credentials)
    return object.exists?
  end
end