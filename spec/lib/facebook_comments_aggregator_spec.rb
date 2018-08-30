# require 'rails_helper'

# RSpec.describe FacebookCommentsAggregator do
#   before do
#     experiment = build(:experiment)
#     secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
#     experiment.set_facebook_keys(secrets['facebook_access_token'], secrets['facebook_ads_access_token'], secrets['facebook_app_secret'])
#     @facebook_comments_aggregator = FacebookCommentsAggregator.new(experiment)


#     VCR.use_cassette 'facebook_comments_aggregator/test_setup' do
#       pages = @facebook_comments_aggregator.get_user_object
#       @page = pages.select{ |page| page["name"] == "B Free of Tobacco" }[0]
#     end
#   end

#   describe "(development only tests)", :development_only_tests => true do
#     it 'gets the page B Free Of Tobacco' do
#       expect(@page).not_to be_nil
#       expect(@page["name"]).to eq("B Free of Tobacco")
#     end

#     it 'gets all comments for a page' do
#       messages = []
#       messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/2t2KVBd"))
#       messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/7o3PALs"))
#       messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/6nBSWg"))

#       VCR.use_cassette 'facebook_comments_aggregator/get_comments' do
#         comments = @facebook_comments_aggregator.get_comments(@page["id"])

#         expect(messages[0].comments.map(&:comment_text)).to include("how gross is that!!!!!")
#       end
#     end

#     it 'gets 25 posts (pagination limit) for a facebook page' do
#       VCR.use_cassette 'facebook_comments_aggregator/get_paginated_posts' do
#         posts = @facebook_comments_aggregator.get_paginated_posts(@page["id"])
#         expect(posts[0]["message"]).to include("100 million+ US non-smokers are exposed to toxic secondhand smoke. Protect your loved ones by living #tobaccofree. http:\/\/bit.ly\/2trX166")
#         expect(posts.count).to eq(25)
#       end
#     end

#     it 'gets comments for an individual post' do
#       VCR.use_cassette 'facebook_comments_aggregator/get_post_comments' do
#         posts = @facebook_comments_aggregator.get_paginated_posts(@page["id"])

#         comments = @facebook_comments_aggregator.get_post_comments(posts[5]["id"])

#         expect(comments[0].count).to eq(3)
#       end
#     end

#     it 'does not add repeat comments' do
#       VCR.use_cassette 'facebook_comments_aggregator/get_double_post_comments' do
#         posts = @facebook_comments_aggregator.get_paginated_posts(@page["id"])

#         comments = @facebook_comments_aggregator.get_post_comments(posts[5]["id"])
#         post_comments = { posts[5]["message"] => comments.flatten }

#         @facebook_comments_aggregator.match_comments_to_message(post_comments)
#         @facebook_comments_aggregator.match_comments_to_message(post_comments)

#         expect(Comment.count).to eq(3)
#       end
#     end

#     it 'returns the parent(s) of comment ids' do
#       VCR.use_cassette 'facebook_comments_aggregator/get_parent_comments' do
#         post_conversations = []
#         posts = @facebook_comments_aggregator.get_all_posts(@page["id"])[0]
#         posts.each do |post_set|
#           post_set.each do |post|
#             if post[0].include?("id")
#               post_conversations << @facebook_comments_aggregator.get_parent_comments(post[1])
#             end
#           end
#         end
#         post_conversations.each{|post| post.select{|subpost| subpost.include?("id")}}
#       end
#     end

#     it 'returns the child comment id of the parent comment' do
#       VCR.use_cassette 'facebook_comments_aggregator/get_child_comment' do
#         comment_id = "1058532354276661_1059226270873936"

#         parent_comment = @facebook_comments_aggregator.get_child_comment(comment_id)

#         expect(parent_comment[0]["parent"]["message"]).to include("DON'T I KNOW THAT...")
#         expect(parent_comment[0]["id"]).to eq("1058532354276661_1059369720859591")
#       end
#     end
#   end
# end
