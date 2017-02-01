[1mdiff --git a/app/views/shared/_images.html.haml b/app/views/shared/_images.html.haml[m
[1mindex 5b6c8c4..5f60146 100644[m
[1m--- a/app/views/shared/_images.html.haml[m
[1m+++ b/app/views/shared/_images.html.haml[m
[36m@@ -29,5 +29,5 @@[m
               %label{ :for => "image-#{image.id}-selected" }[m
           %td[m
             %img{ :src => "#{image.url}", :width => 150, :height => 150 }[m
[31m-          %td.image-tag[m
[32m+[m[32m          %td.image-tag.collapsing[m
             = render partial: 'shared/tag_list', locals: { tags: image.tag_list }[m
[1mdiff --git a/app/views/shared/forms/_experiment.html.haml b/app/views/shared/forms/_experiment.html.haml[m
[1mindex 3d98fd3..823d8d0 100644[m
[1m--- a/app/views/shared/forms/_experiment.html.haml[m
[1m+++ b/app/views/shared/forms/_experiment.html.haml[m
[36m@@ -11,7 +11,7 @@[m
     = f.input :start_date, as: :string[m
     = f.input :end_date, as: :string[m
     = f.input :message_distribution_start_date, as: :string[m
[31m-    = f.association :social_media_profiles, as: :check_boxes, label_method: :service_username, value_method: :id, wrapper_class: 'grouped fields', item_wrapper_class: 'ui field checkbox', label: 'What social media accounts(s) do you want to use?'[m
[32m+[m[32m    = f.association :social_media_profiles, as: :check_boxes, label_method: :service_username value_method: :id, wrapper_class: 'grouped fields', item_wrapper_class: 'ui field checkbox', label: 'What social media accounts(s) do you want to use?'[m
     = f.simple_fields_for :message_generation_parameter_set do |m|[m
       = m.input :social_network_choices, as: :check_boxes, wrapper_class: 'inline fields', item_wrapper_class: 'ui field checkbox', collection: { 'Facebook' => :facebook, 'Instagram' => :instagram, 'Twitter' => :twitter }, label: 'Which social media social media type(s) do you want to use?'[m
       = m.input :medium_choices, as: :check_boxes, wrapper_class: 'inline fields', item_wrapper_class: 'ui field checkbox', collection: { 'Ad' => :ad, 'Organic/Unpaid' => :organic }, label: 'What type(s) of message do you want to use?'[m
[36m@@ -22,4 +22,6 @@[m
       .header[m
         Experiment details[m
       %ul.list.experiment-details-real-time[m
[31m-    = f.button :submit[m
\ No newline at end of file[m
[32m+[m[32m    = f.button :submit[m
[41m+    [m
[41m+    [m
