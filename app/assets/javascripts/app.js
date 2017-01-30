/*global $*/
/*global filepicker*/
/*global Pusher*/
$(document).ready(function() {
  function setUpDatePickers() {
    $("[id$='_date']").daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      format: 'MMM DD, YYYY',
      startDate: '01 01, 2017'
    });
  }

  function setUpChosenDropdowns() {
    $('#clinical_trial_hashtags').chosen({
      no_results_text: 'Oops, no hashtags were found! Sometimes hashtags do not contain the full name of the disease, please try an acronym instead.',
      search_contains: true
    });

    $('#campaign_clinical_trial_ids').chosen({
      search_contains: true
    });

    $('#experiment_clinical_trial_ids').chosen({
      search_contains: true
    });
  }

  function setUpTagListInputs() {
    $('.selectize').selectize({
      plugins: ['restore_on_backspace', 'remove_button'],
      delimiter: ',',
      persist: false,
      create: function(input) {
        return {
          value: input,
          text: input
        };
      }
    });
  }

  function setUpFilepicker() {
    filepicker.setKey("At8mEYziyTc6axVbB4njtz");
  }

  function s3BucketContainer() {
    return 'scctsi-tp-' + $('body').data('environment');
  }

  function setUpMessageTemplateImports() {
    $('#message-templates-file-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');

      filepicker.pick({
          mimetypes: ['text/csv', 'application/vnd.ms-excel'],
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        function(Blob){
          $.ajax({
            url : '/message_templates/import',
            type: 'GET',
            data: {url: Blob.url, experiment_id: experimentId.toString()},
            dataType: 'json',
            success: function(retdata) {
              url = window.location.href;
              if (url.indexOf("?") === -1){
                window.location.href = url + "?selected_tab=message_templates";
              } else {
                window.location.href = url.split("=")[0] + "=message_templates";
              }
            }
          });
        }
      );
    });
  }

  function createS3Url(bucket, key) {
    return 'https://s3-us-west-1.amazonaws.com/' + bucket + '/' + key;
  }

  function setUpImageImports() {
    $('#images-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');
      var experimentParam = $(this).data('experiment-param');

      filepicker.pickAndStore({
          mimetype: 'image/*',
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        {
          location: 'S3',
          path: '/' + experimentParam + '/images/',
          container: s3BucketContainer(),
          access: 'public'
        },
        function(Blobs) {
          var imageUrls = [];
          var bucketName = '';
          for (var i = 0; i < Blobs.length; i++) {
            bucketName = Blobs[0].container;
            imageUrls.push(createS3Url(bucketName, Blobs[i].key));
            $.ajax({
              url : '/images/import',
              type: 'POST',
              data: {image_urls: imageUrls, experiment_id: experimentId.toString()},
              dataType: 'json',
              success: function(retdata) {

              }
            });
          }
        },
        function(error){
        },
        function(progress){
        }
      );
    })
  }

  function setUpAnalyticsFileImports() {
    $('.analytics-file-upload-button').click(function() {
      $(this).addClass('loading');
      $(this).removeClass('primary');
      var analyticsFileId = $(this).data('analytics-file-id');

      filepicker.pick({
          mimetypes: ['text/csv', 'application/vnd.ms-excel'],
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        function(Blob) {
          $.ajax({
            url : '/analytics_files/' + analyticsFileId.toString() + '/update',
            type: 'PATCH',
            data: {url: Blob.url},
            dataType: 'json',
            success: function(retdata) {
            }
          });
        }
      );
    })
  }

  function setupPopupInfo() {
    $('.ui.fluid.huge.teal.labeled.icon.button.start-experiment-button').popup({
      title   : 'What is an experiment?',
      content : 'An experiment applies scientific study design techniques and allows you to set up a project to test a hypothesis.'
    });

    $('.ui.fluid.huge.teal.labeled.icon.button.start-campaign-button').popup({
      title   : 'What is a campaign?',
      content : 'A campaign allows you to promote one or multiple types of contents (news, research studies, research findings, award announcements, etc.) without applying scientific study design techniques.'
    });

    $('.ui.labeled.icon.button.disable-message-generation-button').popup({
      title : "Why can't I generate messages?",
      content : 'This experiment has already started distributing messages. You can no longer generate messages for this experiment.'
    })
  }

  String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
  }

  function calculateMessageCount(socialNetworkChoicesCount, mediumChoicesCount, periodInDays, numberOfMessagesPerSocialNetwork) {
    var messageCountHtml;
    $.ajax({
      type: 'GET',
      url: '/experiments/calculate_message_count',
      data: { social_network_choices_count: socialNetworkChoicesCount, medium_choices_count: mediumChoicesCount, period_in_days: periodInDays, number_of_messages_per_social_network: numberOfMessagesPerSocialNetwork},
      dataType: 'json',
      success: function (data) {
        messageCountHtml = '<li>The total message count is ' + data['message_count'];
        if (parseInt(data['message_count'], 10) > 0) {
          $('.experiment-details-real-time').append(messageCountHtml);
        }
      }
    });
  }

  function changeExperimentDetails() {
    var listHtml = '';
    var mediumCount;
    var periodInDays = $("#experiment_message_generation_parameter_set_attributes_period_in_days").val();
    var numberOfMessagesPerSocialNetwork = $("#experiment_message_generation_parameter_set_attributes_number_of_messages_per_social_network").val();
    var checkedValues = $.map($("input:checked"), function (elem) { return elem.value.capitalizeFirstLetter()  || ""; }).join( ", " );
    var socialNetworkChoices = [];

    ['Facebook', 'Instagram', 'Twitter'].forEach(function(socialNetwork) {
      if (checkedValues.includes(socialNetwork)) {
        socialNetworkChoices.push(socialNetwork);
      }
    });

    if (socialNetworkChoices.length === 1) {
      listHtml += '<li>All messages will be generated for distribution on ' + socialNetworkChoices[0];
    } else {
      listHtml += '<li>Equal number of messages will be generated per platform: ' + socialNetworkChoices.join(", ");
    }

    if ((checkedValues).includes('Ad, Organic')) {
      mediumCount = 2;
      listHtml += '<li>Half of the generated messages for each platform will be organic (unpaid) and half will be ads (paid).'
    } else if ((checkedValues).includes('Ad')) {
      listHtml += '<li>All messages will be ads (paid).'
      mediumCount = 1;
    } else if ((checkedValues).includes('Organic')) {
      listHtml += '<li>All messages will be organic (unpaid).'
      mediumCount = 1;
    }

    if ((checkedValues).includes('Without')) {
      listHtml += '<li>All messages will be without images.'
      $('#experiment_message_generation_parameter_set_attributes_image_present_choices_with').prop('checked', false);
    } else if ((checkedValues).includes('With')) {
      listHtml += '<li>Half of the generated messages will have an attached image and half will have no attached image.'
      $('#experiment_message_generation_parameter_set_attributes_image_present_choices_without').prop('checked', false);
    }

    $('.list.experiment-details-real-time').html(listHtml);

    calculateMessageCount(socialNetworkChoices.length, mediumCount, periodInDays, numberOfMessagesPerSocialNetwork);
  }

  function setupExperimentRealTime() {
    $('.ui.new_experiment_form').change(function(e){
      changeExperimentDetails();
    });
  }
  
  function setUpPusherChannels() {
    var pusher = new Pusher('645d88fef1ee61febc2d'); // uses your APP KEY
    var channel = pusher.subscribe('progress');
    channel.bind('progress', function(data) {
      $('.ui.progress').progress('increment');
      
      // if($('.ui.progress').progress('is complete')) {
      //   console.log('All done');
      // }
    });
  }
  
  function setUpAsyncMessageGeneration() {
    // Set up progress bar
    $('.ui.progress').progress({
      duration : 200,
      text     : {
        active: '{value} of {total} done'
      }
    });
    
    // Set up AJAX call to create messages on experiment instance
    $('#generate-messages-button').click(function() {
      $(this).addClass('loading');
      $('.hidden-content').show();
      var experimentId = $(this).data('experiment-id');
      
      $.ajax({
        type: 'GET',
        url: '/experiments/' + experimentId + '/create_messages.json',
        data: { id: experimentId },
        dataType: 'json',
        success: function(data) {
        }
      });
      
      return false;
    });    
  }

  // Initialize
  setupExperimentRealTime();
  setupPopupInfo();
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpFilepicker();
  setUpMessageTemplateImports();
  setUpImageImports();
  setUpAnalyticsFileImports();
  setUpPusherChannels();
  setUpAsyncMessageGeneration();
  
  // Set up Semantic UI
  $('.menu .item').tab();
  $('.table').tablesort();
});
