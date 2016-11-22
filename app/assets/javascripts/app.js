/*global $*/
/*global filepicker*/
$(document).ready(function() {
  function setUpDatePickers() {
    $("[id$='_date']").daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      format: 'MM-DD-YYYY',
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
    $('#csv-file-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');
      
      filepicker.pick({
          mimetype: '*/*',
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
            }
          });
        }
      );      
    });
  }

  function setUpImageImports() {
    $('#image-files-upload-button').click(function() {
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

  // Initialize
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpFilepicker();
  setUpMessageTemplateImports();
  setUpImageImports();
  $('.menu .item').tab();
});

