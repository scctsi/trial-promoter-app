/*global $*/
/*global filepicker*/
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
    filepicker.setKey("AU0m7oO6OSQW5bqqVk0HTz");
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
            async: false,
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

  function setUpImageImports() {
    $('#images-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');

      filepicker.pickMultiple({
          mimetype: 'image/*',
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        function(Blobs) {
          var imageUrls = [];

          for (var i = 0; i < Blobs.length; i++) {
            imageUrls.push(Blobs[i].url);
            $.ajax({
              url : '/images/import',
              type: 'POST',
              data: {image_urls: imageUrls, experiment_id: experimentId.toString()},
              dataType: 'json',
              async: false,
              success: function(retdata) {

              }
            });
          }
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
        if (parseInt(data['message_count']) > 0) {
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
    } else if ((checkedValues).includes('With')) {
      listHtml += '<li>Half of the generated messages will have an attached image and half will have no attached image.'
    }

    $('.list.experiment-details-real-time').html(listHtml);

    calculateMessageCount(socialNetworkChoices.length, mediumCount, periodInDays, numberOfMessagesPerSocialNetwork);
  }

  function setupExperimentRealTime() {
    $('.ui.new_experiment_form').change(function(e){
      changeExperimentDetails();
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
  $('.menu .item').tab();
});
