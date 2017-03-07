require 'aws-sdk'

class S3Client
  attr_accessor :s3_client

  def initialize
    credentials = Aws::Credentials.new(Setting[:aws_access_key_id, :secret_access_key])
    s3_client = Aws::S3::client.new(credentials: credentials, region: 'us-east-1')
  end

  def asset_exists_in_s3?(bucket, image)
    object = Aws::S3::Object.new(bucket, image.url)
    all_obj =  self.list_objects(bucket: bucket)
    return object.exists?
  end

#   def upload_object_to_s3
#     s3 = Aws::S3::Resource.new(
#       credentials: Aws::Credentials.new('akid', 'secret'),
#       region: 'us-west-1')
#     obj = s3.bucket('scctsi-tp-development').object('key')

#     # from a string
#     obj.put(body:'Hello World!')

#     # from an IO object
#     File.open('/assets/no-image.png', 'rb') do |file|
#       obj.put(body:file)
#     end
#   end

  # def show_items
    # s3 = Aws::S3::Resource.new(region: 'us-east-1')

    # bucket = s3.bucket('scctsi-tp-development')

    # # Show only the first 50 items
    # bucket.objects.limit(50).each do |item|
    #   puts "Name:  #{item.key}"
    #   puts "URL:   #{item.presigned_url(:get)}"
  # end
end