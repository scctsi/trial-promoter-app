/*global $*/
/*global filepicker*/
$(document).ready(function() {
  function setUpDatePickers() {
    $("[id$='_date']").daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      format: 'DD-MM-YYYY',
      startDate: '08-01-2016'
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
    });
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
      title : 'Why can\'t I generate messages?',
      content : 'The date is within the scheduled 24-hour window for message generation.'
    })
  }

  // Initialize
  setupPopupInfo();
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpFilepicker();
  setUpMessageTemplateImports();
  setUpImageImports();
  $('.menu .item').tab();
});
