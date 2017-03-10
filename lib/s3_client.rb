require 'aws-sdk'

class S3Client
  def initialize
    credentials = Aws::Credentials.new(Setting[:aws_access_key_id], Setting[:aws_secret_access_key])

    Aws.config.update({
      region: 'us-west-1',
      credentials: credentials
    })
  end

  def bucket(url)
    url.split('/')[3]
  end

  def key(url)
    url.split('/')[4..6].join("/")
  end

  def region(url)
    url.split('/')[2].split('-')[1..3].join('-').split('.')[0]
  end

  def object_exists?(bucket, key)
    object = Aws::S3::Object.new(bucket, key)
    return object.exists?
  end

  def put(bucket, key, body)
    object = Aws::S3::Object.new(bucket, key)
    object.put(body: body)
  end

  def delete(bucket, key)
    object = Aws::S3::Object.new(bucket, key)
    object.delete
  end
end