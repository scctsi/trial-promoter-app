/*global $*/
/*global filepicker*/
/*global Pusher*/
$(document).ready(function() {
  var $select_time;

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
              $('.ui.success.message.hidden.ask-refresh-page').removeClass('hidden');
            }
          });
        }
      );
    });
  }

  function createS3Url(bucket, key) {
    return 'https://s3-us-west-1.amazonaws.com/' + bucket + '/' + key;
  }

  function createS3BucketUrls(Blobs) {
    var namedUrls = [];
    var bucketName = '';
    
    for (var i = 0; i < Blobs.length; i++) {
      bucketName = Blobs[0].container;
      namedUrls.push(createS3Url(bucketName, Blobs[i].key));
    }
    
    return namedUrls;
  }

  function setUpImageImports() {
    $('#images-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');
      var experimentParam = $(this).data('experiment-param');

      filepicker.pickAndStore({
          mimetype: 'image/*',
          multiple: true,
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
          console.log(Blobs);
          var imageUrls = createS3BucketUrls(Blobs);
          var filenames = [];
          for (var i = 0; i < Blobs.length; i++) {
            filenames.push(Blobs[i].filename);
          }

          $.ajax({
            url : '/images/import',
            type: 'POST',
            data: {image_urls: imageUrls, original_filenames: filenames, experiment_id: experimentId.toString()},
            dataType: 'json',
            success: function(retdata) {
              $('.ui.success.message.hidden.ask-refresh-page').removeClass('hidden');
            }
          });
        },
        function(error){
        },
        function(progress){
        }
      );
    });
  }

  function setUpAnalyticsFileImports() {
    $('.analytics-file-upload-button').click(function() {
      $(this).addClass('loading');
      $(this).removeClass('primary');
      var analyticsFileId = $(this).data('analytics-file-id');
      var experimentId = $(this).data('experiment-id');
      var experimentParam = $(this).data('experiment-param');

      filepicker.pickAndStore({
          mimetypes: ['text/csv', 'application/vnd.ms-excel'],
          multiple: true,
          container: 'modal',
          services: ['COMPUTER', 'GOOGLE_DRIVE', 'DROPBOX']
        },
        {
          location: 'S3',
          path: '/' + experimentParam + '/analytics_files/',
          container: s3BucketContainer(),
          access: 'public'
        },
        function(Blobs) {
          var analyticsFileUrls = createS3BucketUrls(Blobs);

          $.ajax({
            url : '/analytics_files/' + analyticsFileId.toString() + '/update',
            type: 'POST',
            data: {analytics_file_urls: analyticsFileUrls, experiment_id: experimentId.toString()},
            dataType: 'json',
            success: function(retdata) {
              $('.ui.success.message.hidden.ask-refresh-page').removeClass('hidden');
            }
          });
        },
        function(error){
        },
        function(progress){
        }
      );
    })
  }

  function setUpPopupInfo() {
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
    var checkedValues = getCheckedValues();
    var socialNetworkChoices = getRequiredPlatformsAndMediums().socialNetworkChoices;
    var mediumChoices = getRequiredPlatformsAndMediums().mediumChoices;

    if (socialNetworkChoices.length === 1) {
      listHtml += '<li>All messages will be generated for distribution on ' + socialNetworkChoices[0];
    } else {
      listHtml += '<li>Equal number of messages will be generated per social media platform: ' + socialNetworkChoices.join(", ");
    }

    if ((mediumChoices).includes('Ad, Organic')) {
      listHtml += '<li>Half of the generated messages for each platform will be organic (unpaid) and half will be ads (paid).'
    } else if ((mediumChoices).includes('Ad')) {
      listHtml += '<li>All messages will be ads (paid).'
    } else if ((mediumChoices).includes('Organic')) {
      listHtml += '<li>All messages will be organic (unpaid).'
    }

    if ((checkedValues).includes('Without')) {
      listHtml += '<li>All messages will be without images.'
      $('#experiment_message_generation_parameter_set_attributes_image_present_choices_with').prop('checked', false);
    } else if ((checkedValues).includes('With')) {
      listHtml += '<li>Half of the generated messages will have an attached image and half will have no attached image.'
      $('#experiment_message_generation_parameter_set_attributes_image_present_choices_without').prop('checked', false);
    }

    $('.list.experiment-details-real-time').html(listHtml);

    calculateMessageCount(socialNetworkChoices.length, mediumChoices.length, periodInDays, numberOfMessagesPerSocialNetwork);
    showSocialMediaProfiles();
  }

  function getCheckedValues() {
    return $.map($("input:checked"), function (elem) { return elem.value.capitalizeFirstLetter()  || ""; }).join( ", " );
  }

  function getRequiredPlatformsAndMediums() {
    var checkedValues = getCheckedValues();
    var socialNetworkChoices = [];
    var mediumChoices = [];

    ['Facebook', 'Instagram', 'Twitter'].forEach(function(socialNetwork) {
      if (checkedValues.includes(socialNetwork)) {
        socialNetworkChoices.push(socialNetwork);
      }
    });

    ['Ad', 'Organic'].forEach(function(medium) {
      if (checkedValues.includes(medium)) {
        mediumChoices.push(medium);
      }
    });

    return {socialNetworkChoices: socialNetworkChoices, mediumChoices: mediumChoices};
  }

  function setUpExperimentRealTime() {
    $('.ui.experiment_form').change(function(e){
      changeExperimentDetails();
    });
  }

  function setUpPusherChannels() {
    var pusher = new Pusher('645d88fef1ee61febc2d'); // uses your APP KEY
    var channel = pusher.subscribe('progress');
    channel.bind('progress', function(data) {
      $('.ui.progress').progress('increment');

      if(data.value === data.total) {
        $('.ui.progress').progress('set success');
        $('.ui.modal .approve.button').show();
      }
    });
  }

  function setUpAsyncMessageGeneration() {
    $('#generate-messages-button').click(function() {
      var experimentId = $(this).data('experiment-id');
      var total = $('.ui.modal').data('total');

      $('.ui.modal').modal('setting', 'transition', 'Vertical Flip').modal({ blurring: true }).modal('show');
      $('.ui.modal .approve.button').hide();

      // Set up progress bar
      $('.ui.progress').progress({
        duration : 200,
        total    : total,
        text     : {
          active: '{value} of {total} done',
          success: 'All the messages for this experiment were successfully generated!',
          error: 'Something went wrong during message generation!'
        }
      });

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

  function setUpImageTagging() {
    var $imageSelectors = $('.image-selector');
    var allowedTags = $('#image-tags').data('allowed-tags');

    // Selectize requires options to be of the form [{'value': 'val', 'item', 'val'}]
    if (typeof allowedTags === "undefined") {
      allowedTags = [];
    }
    allowedTags = allowedTags.map(function(x) { return { item: x } });

    // Set up tag editor
    $('#image-tags').selectize({
      delimiter: ',',
      persist: false,
      create: false,
      valueField: 'item',
      labelField: 'item',
      searchField: 'item',
      options: allowedTags
    });

    // Set up all checkboxes
    $imageSelectors.checkbox();
    $imageSelectors.checkbox('attach events', '#select-all-images-button', 'check');
    $imageSelectors.checkbox('attach events', '#deselect-all-images-button', 'uncheck');

    // Set up AJAX call to replace tags on selected images with contents of tag editor
    var selectedImageIds = [];
    var tags = '';
    $("#add-image-tags-button").on('click', function() {
      selectedImageIds = [];

      $imageSelectors.each(function() {
        if ($(this).find('input').is(':checked')) {
          selectedImageIds.push($(this).data('image-id'));
          tags = $('#image-tags').val();
        };
      })

      $.ajax({
        url : '/images/tag_images',
        type: 'POST',
        data: {image_ids: selectedImageIds, tags: tags},
        dataType: 'json',
        success: function(retdata) {
          var imageTagCells = [];

          $imageSelectors.each(function() {
            if ($(this).find('input').is(':checked')) {
              imageTagCells.push($(this).parent().parent().find('td.image-tag'));
            };
          })

          imageTagCells.forEach(function(imageTagCell) {
            var tagHtml = '';
            var splitTags = tags.split(',');

            splitTags.forEach(function(tag) {
              tagHtml += '<a class="ui small tag label">' + tag + '</a>';
            });
            imageTagCell.html(tagHtml);
          })
        }
      });

      return false;
    });
  }

  function setUpPostingTimeInputs() {
    var allowedTimes = $('#experiment_posting_times').data('allowed-times');

    // Selectize requires options to be of the form [{'value': 'val', 'item', 'val'}]
    if (typeof allowedTimes === "undefined") {
      allowedTimes = [];
    }
    allowedTimes = allowedTimes.map(function(x) { return { item: x } });

    // Setup the posting times input
    $select_time = $('#experiment_posting_times').selectize({
      plugins: ['restore_on_backspace', 'remove_button'],
      valueField: 'item',
      labelField: 'item',
      searchField: 'item',
      delimiter: ',',
      options: allowedTimes,
      create: false,
      persist: false
    });
  }

  function showSocialMediaProfiles(){
    var socialMediaProfiles = $('.experiment_social_media_profiles');
    var socialMediaProfileFields = $('.experiment_social_media_profiles span.checkbox.ui');
    var pickPlatformAndMediumMessage = $('.social-media-profile-details');
    var socialMediaAccountQuestionText = $('.experiment_social_media_profiles .check_boxes.required');
    var requiredPlatforms = getRequiredPlatformsAndMediums().socialNetworkChoices;
    var requiredMediums = getRequiredPlatformsAndMediums().mediumChoices;

    socialMediaProfileFields.hide();
    pickPlatformAndMediumMessage.hide();

    if ((requiredPlatforms.length === 0 ) || (requiredMediums.length === 0)) {
      pickPlatformAndMediumMessage.show();
      socialMediaAccountQuestionText.hide();
      return;
    }

    // Show suitable social media profiles choices
    socialMediaAccountQuestionText.show();
    socialMediaProfileFields.each(function(index, socialMediaProfileField) {
      requiredPlatforms.forEach(function(requiredPlatform) {
        requiredMediums.forEach(function(requiredMedium) {
          var searchString = requiredPlatform + ' [' + requiredMedium + ']';
          if (socialMediaProfileField.textContent.includes(searchString)) {
            $(socialMediaProfileField).transition('pulse');
          }
        });
      });
    });
  }

  function getFilenames(selectedImages) {
    var filenames = [];

    selectedImages.forEach(function(selectedImage) {
      filenames.push(selectedImage.original_filename);
    });
    
    return filenames.join(',');
  }
  
  function getImageCardsHtml(images, buttonType) {
    var html = '';
  
    html += '<div class="ui cards">';
    images.forEach(function (image) {
      html += '<div class="card">';
      html += '<div class="content">';
      html += '<div class="ui image">';
      html += '<img src="' + image.url + '"></img>';
      html += '<div class="description">' + image.original_filename + '</div>';
      html += '</div>';
      html += '</div>';
      if (buttonType == 'add') {
        html += '<div class="extra content"><div class="ui labeled icon fluid tiny button add-image-to-image-pool-button" data-image-id="' + image.id + '"><i class="checkmark icon"></i>Add</div></div>';
      }
      if (buttonType == 'remove') {
        html += '<div class="extra content"><div class="ui labeled icon fluid tiny button remove-image-from-image-pool-button" data-image-id="' + image.id + '"><i class="remove icon"></i>Remove</div></div>';
      }
      html += '</div>';
    });
    html += '</div>';

    return html;
  }
  
  function getImagePoolInterfaceHtml(selectedImages, unselectedImages, messageContent) {
    var html = '<div class="ui segment">' + messageContent + '</div>';
    html += '<div class="ui segment filenames-list">Filenames: ';
    html += getFilenames(selectedImages) + '</div>';

    html += '<h3 class="ui block header">Selected images</h3>';
    html += getImageCardsHtml(selectedImages, 'remove');

    html += '<h3 class="ui block header">Unselected images</h3>';
    html += getImageCardsHtml(unselectedImages, 'add');

    return html;
  }
  
  function addEventForButton(messageTemplateId, imageId, $button) {
    var action = '';
    var confirmationText = '';

    if ($button.hasClass('add-image-to-image-pool-button')) {
      action = 'add_image_to_image_pool';
      confirmationText = 'Added';
    }
    if ($button.hasClass('remove-image-from-image-pool-button')) {
      action = 'remove_image_from_image_pool';
      confirmationText = 'Removed';
    }
     
    $button.addClass('loading');
    $('.filenames-list').html('Selected images have been changed. Please close and reopen this window to see correct list of filenames.');

    $.ajax({
      url : '/message_templates/' + messageTemplateId + '/' + action,
      type: 'POST',
      data: {image_id: imageId},
      dataType: 'json',
      success: function(retdata) {
        $button.removeClass('loading');
        $button.addClass('positive');
        $button.html('<i class="checkmark icon"></i>' + confirmationText);
      }
    });
  }
  
  function addEventsForAddRemoveButtons(messageTemplateId) {
    $('#lightbox .add-image-to-image-pool-button').on('click', function() {
      addEventForButton(messageTemplateId, $(this).data('image-id'), $(this));
    });

    $('#lightbox .remove-image-from-image-pool-button').on('click', function() {
      addEventForButton(messageTemplateId, $(this).data('image-id'), $(this));
    });
  }
  
  function setUpImagePoolViewing() {
    // Modal for image labeling
    $('.choose-images-button').click(function(){
      var experimentId = $(this).data('experiment-id');
      var messageTemplateId = $(this).data('message-template-id');
      var messageContent = $(this).parent().siblings(':first').text();
      console.log(messageContent);
      var $loadingButton = $(this);

      $loadingButton.addClass('loading');
      $.ajax({
        url : '/message_templates/' + messageTemplateId + '/get_image_selections',
        type: 'POST',
        data: {experiment_id: experimentId},
        dataType: 'json',
        success: function(retdata) {
          var html = '';
          var selectedImages = retdata.selected_images;
          var unselectedImages = retdata.unselected_images;

          html = getImagePoolInterfaceHtml(selectedImages, unselectedImages, messageContent);

          $loadingButton.removeClass('loading');
          $('#lightbox .image-list').html(html);
          $('#lightbox').modal('setting', 'transition', 'Vertical Flip').modal({ blurring: true }).modal('show');
          addEventsForAddRemoveButtons(messageTemplateId);
        }
      });
    });
  }
  
  // Initialize
  setUpPostingTimeInputs();
  showSocialMediaProfiles();
  setUpExperimentRealTime();
  setUpPopupInfo();
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpFilepicker();
  setUpMessageTemplateImports();
  setUpImageImports();
  setUpAnalyticsFileImports();
  setUpPusherChannels();
  setUpAsyncMessageGeneration();
  setUpImageTagging();
  setUpImagePoolViewing();

  // Set up Semantic UI
  $('.menu .item').tab({
    history: true,
    historyType: 'hash',
    context: 'parent'
  });
  $('.table').tablesort();

  // Lazyload for images
  $("img").lazyload({
    threshold : 500,
    effect : "fadeIn"
  });
});