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
  
  function setUpMessageTemplateImporting() {
    $('#csv-file-upload-button').click(function() {
      filepicker.pick({
          mimetype: '*/*',
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        function(Blob){
        }
      );      
    });
  }

  // Initialize
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpFilepicker();
  setUpMessageTemplateImporting();
  $('.menu .item').tab();
});

