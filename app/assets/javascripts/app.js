/*global $*/
/*global filepicker*/
/*global Pusher*/
$(document).ready(function() {
  if (typeof filepicker != 'undefined') {
    filepicker.setKey("At8mEYziyTc6axVbB4njtz");
  }

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

  function s3BucketContainer() {
    return $('body').data('s3-bucket');
  }

  function setUpMessageTemplateImports() {
    $('#message-templates-file-upload-button').click(function() {
      var experimentId = $(this).data('experiment-id');

      filepicker.pick({
          extensions: ['.xls', '.xlsx'],
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
        },
        function(FPError){
          console.log(FPError.toString());
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

    $('#images-add-button').click(function() {
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
          var imageUrls = createS3BucketUrls(Blobs);
          var filenames = [];
          for (var i = 0; i < Blobs.length; i++) {
            filenames.push(Blobs[i].filename);
          }

          $.ajax({
            url : '/images/add',
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
    $('.analytics-file-upload-button').on('click', function() {
      var $fileUploadButton = $(this);
      $fileUploadButton.addClass('loading');
      var analyticsFileId = $(this).data('analytics-file-id');
      var experimentParam = $(this).data('experiment-param');

      filepicker.pickAndStore({
          mimetypes: ['text/csv', 'application/vnd.ms-excel'],
          multiple: false,
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
          var analyticsFileUrl = createS3BucketUrls(Blobs)[0];

          $.ajax({
            url : '/analytics_files/' + analyticsFileId.toString() + '/update',
            type: 'PATCH',
            data: {url: Blobs[0].url},
            dataType: 'json',
            success: function(retdata) {
              $fileUploadButton.removeClass('loading');
              $fileUploadButton.removeClass('analytics-file-upload-button');
              $fileUploadButton.attr('href', analyticsFileUrl);
              $fileUploadButton.html('<i class="download icon"></i>Download');
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

  function setUpPopupInfo() {
    $('.ui.fluid.huge.teal.labeled.icon.button.start-experiment-button').popup({
      title   : 'What is an experiment?',
      content : 'An experiment applies scientific study design techniques and allows you to set up a project to test a hypothesis.'
    });

    $('.ui.fluid.huge.teal.labeled.icon.button.start-campaign-button').popup({
      title   : 'What is a campaign?',
      content : 'A campaign allows you to promote one or multiple types of contents (news, research studies, research findings, award announcements, etc.) without applying scientific study design techniques.'
    });

    $('.url.label').popup();
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
    var pusherKey = $('body').data('pusher-key');
    var pusher = new Pusher(pusherKey); // uses your APP KEY
    var channel = pusher.subscribe('progress');
    channel.bind('progress', function(data) {
      $('.ui.progress').progress('increment');

      if(data.value === data.total) {
        $('.ui.progress').progress('set success');
        $('#message-generation-progress .approve.button').show();
      }
    });
  }

  function generateMessages(experimentId, totalMessageCount) {
    $('#message-generation-progress').modal('setting', 'transition', 'Vertical Flip').modal({ blurring: true }).modal('show');
    $('#message-generation-progress .approve.button').hide();

    // Set up progress bar
    $('.ui.progress').progress({
      duration : 200,
      total    : totalMessageCount,
      text     : {
        active: '{value} of {total} done',
        success: 'All the messages for this experiment were successfully generated!',
        error: 'Something went wrong during message generation!'
      }
    });

    $.ajax({
      type: 'GET',
      url: '/experiments/' + experimentId + '/create_messages',
      data: { },
      dataType: 'json',
      success: function(data) {
      }
    });

    return false;
  }

  function setUpAsyncMessageGeneration() {
    $('#generate-messages-button').click(function() {
      $('#message-generation-confirmation').modal('setting', 'transition', 'Vertical Flip').modal({
          blurring: true,
          onApprove: function() { generateMessages($(this).data('experiment-id'), $(this).data('total')) }
        }).modal('show');
    });
  }

  function setUpPostingTimeInputs() {
    var allowedTimes = $('#experiment_twitter_posting_times').data('allowed-times');

    // Selectize requires options to be of the form [{'value': 'val', 'item', 'val'}]
    if (typeof allowedTimes === "undefined") {
      allowedTimes = [];
    }
    allowedTimes = allowedTimes.map(function(x) { return { item: x } });

    // Setup the posting times input
    $('#experiment_twitter_posting_times, #experiment_facebook_posting_times, #experiment_instagram_posting_times').selectize({
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
            $(socialMediaProfileField).show();
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

  function getImageCardsHtml(images, buttonType, filenameStartswithRestriction, readonly) {
    var html = '';
    if (readonly) {
      buttonType = 'readonly';
    }
    filenameStartswithRestriction = filenameStartswithRestriction || '';

    html += '<div class="ui cards">';
    images.forEach(function (image) {
      if (filenameStartswithRestriction != '' && !(image.original_filename.startsWith(filenameStartswithRestriction))) {
        return;
      }
      html += '<div class="card">';
      html += '<div class="content">';
      html += '<div class="ui image">';
      html += '<img src="' + image.url + '"></img>';
      html += '<div class="description">' + image.original_filename + '</div>';
      html += '</div>';
      html += '</div>';
      console.log(image);
      if (buttonType == 'add' && image.meets_instagram_ad_requirements) {
        html += '<div class="extra content"><div class="ui labeled icon fluid tiny button add-image-to-image-pool-button" data-image-id="' + image.id + '"><i class="checkmark icon"></i>Add</div></div>';
      }
      if (buttonType == 'add' && !image.meets_instagram_ad_requirements) {
        html += '<div class="extra content"><div class="ui disabled fluid tiny negative button add-image-to-image-pool-button" data-image-id="' + image.id + '">Invalid (for Instagram)</div></div>';
      }
      if (buttonType == 'remove' && image.meets_instagram_ad_requirements) {
        html += '<div class="extra content"><div class="ui labeled icon fluid tiny button remove-image-from-image-pool-button" data-image-id="' + image.id + '"><i class="remove icon"></i>Remove</div></div>';
      }
      if (buttonType == 'remove' && !image.meets_instagram_ad_requirements) {
        html += '<div class="extra content"><div class="ui labeled icon fluid tiny negative button remove-image-from-image-pool-button" data-image-id="' + image.id + '"><i class="remove icon"></i>Remove</div></div>';
      }
      html += '</div>';
    });
    html += '</div>';

    return html;
  }

  function getImagePoolInterfaceHtml(selectedImages, unselectedImages, messageContent, filenameStartswithRestriction, readonly) {
    var html = '<div class="ui segment">' + messageContent + '</div>';
    html += '<div class="ui segment filenames-list">Filenames: ';
    html += getFilenames(selectedImages) + '</div>';

    html += '<h3 class="ui block header">Selected images from this campaign</h3>';

    html += getImageCardsHtml(selectedImages, 'remove', filenameStartswithRestriction, readonly);
    html += getImageCardsHtml(unselectedImages, 'add', filenameStartswithRestriction, readonly);

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

  function setUpImagePoolViewing() {
    // Modal for image labeling
    $('.choose-images-button').click(function(){
      var experimentId = $(this).data('experiment-id');
      var messageTemplateId = $(this).data('message-template-id');
      var messageContent = $(this).parent().siblings(':first').text();
      var $loadingButton = $(this);
      var filenameStartswithRestriction = $(this).data('filename-startswith-restriction');
      var readonly = $(this).data('role') == 'read_only';

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

          html = getImagePoolInterfaceHtml(selectedImages, unselectedImages, messageContent, filenameStartswithRestriction.toLowerCase(), readonly);

          $loadingButton.removeClass('loading');
          $('#lightbox .image-list').html(html);
          $('#lightbox').modal('setting', 'transition', 'Vertical Flip').modal({ blurring: true }).modal('show');
          $('#lightbox .add-image-to-image-pool-button, #lightbox .remove-image-from-image-pool-button').on('click', function() {
            addEventForButton(messageTemplateId, $(this).data('image-id'), $(this));
          });
        }
      });
    });
  }

  function setUpSaveCampaignIdFormEvents() {
    //Add campaign id to fb and instagram ads
    $('.button.save-id').click(function(event){
      var $inputForm = $(this).parent();
      var campaignId = $(this).parent().find('input').val();
      var messageId = $(this).data('message-id');
      editCampaignId(messageId, campaignId, $inputForm);
      event.preventDefault();
    });
  }

  function setUpEditCampaignIdLabelEvents() {
    //Edit campaign id for fb and instagram ads
    $('.edit-id i').click(function(event){
      var messageId = $(this).parent().data('message-id');
      var $inputForm = $(this).parent();
      getCampaignIdInputForm(messageId, $inputForm);
      event.preventDefault();
    });
  }

  function editCampaignId(messageId, campaignId, $inputForm) {
    $.ajax({
      url:  '/messages/' + messageId + '/edit_campaign_id',
      type: 'POST',
      data: { campaign_id: campaignId },
      success: function(campaignIdLabelHtml) {
        $inputForm.replaceWith(campaignIdLabelHtml);
        setUpEditCampaignIdLabelEvents();
      }
    });
  }

  function getCampaignIdInputForm(messageId, $inputForm) {
    $.ajax({
      url: '/messages/' + messageId + '/new_campaign_id',
      type: 'GET',
      data: {},
      success: function(campaignIdFormHtml) {
        $inputForm.replaceWith(campaignIdFormHtml);
        setUpSaveCampaignIdFormEvents();
      }
    });
  }
  
  function setUpEditImageCodesFormEvents() {
    $('.button.save-image-codes').click(function(event){
      var $inputForm = $(this).find('.dropdown.edit-image-codes');
      var imageCodes = $(this).parent().find('.dropdown.edit-image-codes').dropdown("get value");
      var imageId = $(this).data('image-id');
      var $saveButton = $(this).parent().find('.button.save-image-codes');
      if (imageCodes != null) {
        imageCodes.join(",");
      }
      saveCodes('image', imageId, imageCodes, $inputForm, $saveButton);
      event.preventDefault();
    })
  }

  function setUpEditCommentCodesFormEvents() {
    $('.button.save-comment-codes').click(function(event){
      var $inputForm = $(this).find('.dropdown.edit-comment-codes');
      var commentCodes = $(this).parent().find('.dropdown.edit-comment-codes').dropdown("get value");
      var commentId = $(this).data('comment-id');
      var $saveButton = $(this).parent().find('.button.save-comment-codes');
      if (commentCodes != null) {
        commentCodes.join(",");
      }
      saveCodes('comment', commentId, commentCodes, $inputForm, $saveButton);
      event.preventDefault();
    })
  }

  function saveCodes(model, modelId, modelCodes, $inputForm, $saveButton) {
    $.ajax({
      url:  '/' + model + 's/' + modelId + '/edit_codes',
      type: 'POST',
      data: { codes: modelCodes  },
      success: function(modelCodes) {
        $saveButton.addClass('disabled');
      }
    });
  }
  
  function setUpSaveNoteFormEvents() {
    $('.button.save-note').click(function(event){
      var $inputForm = $(this).parent();
      var note = $(this).parent().find('input').val();
      var messageId = $(this).data('message-id');
      editNote(messageId, note, $inputForm);
      event.preventDefault();
    });
  }

  function setUpEditNoteEvents() {
    $('.edit-note i').click(function(event){
      var messageId = $(this).parent().data('message-id');
      var $inputForm = $(this).parent();
      getNoteInputForm(messageId, $inputForm);
      event.preventDefault();
    });
  }

  function editNote(messageId, note, $inputForm) {
    $.ajax({
      url:  '/messages/' + messageId + '/edit_note',
      type: 'POST',
      data: { note: note },
      success: function(noteLabelHtml) {
        $inputForm.replaceWith(noteLabelHtml);
        setUpEditNoteEvents();
      }
    });
  }

  function getNoteInputForm(messageId, $inputForm) {
    $.ajax({
      url: '/messages/' + messageId + '/new_note',
      type: 'GET',
      data: {},
      success: function(noteFormHtml) {
        $inputForm.replaceWith(noteFormHtml);
        setUpSaveNoteFormEvents();
      }
    });
  }

  function setUpAjaxPagination() {
    $('.ui .pagination a').click(function(e){
      e.preventDefault();
      var targetUrl = $(this).attr('href');
      var experimentId = $('.paginated-content').data('experiment-id');
      var model = $('.paginated-content#model').data('model');
      var page = '';
      if (targetUrl.includes("page=")){
        page = targetUrl.match(/page=(\d+)/)[1];
      }
      if (model == 'comment'){
        $.ajax({
          url: '/experiments/' + experimentId + '/comments_page.html',
          data: { page: page },
          success: function(res){
            $('.paginated-content').html(res);
            setUpAjaxPagination();
            $('.ui.dropdown').dropdown({
              onChange: function() {
                var commentId = $(this).data("comment-id");
                $("#edit-comment-codes-" + commentId).find('.save-comment-codes').first().removeClass('disabled');
              }
            });
            setUpEditCommentCodesFormEvents();
          }
        });
      } else {
        $.ajax({
          url: '/experiments/' + experimentId + '/messages_page.html',
          data: { page: page },
          success: function(res){
            $('.paginated-content').html(res);
            setUpAjaxPagination();
            setUpSaveCampaignIdFormEvents();
            setUpEditCampaignIdLabelEvents();
            setUpSaveNoteFormEvents();
            setUpEditNoteEvents();
          }
        });
      }
    });
  }

  // Initialize
  setUpSaveCampaignIdFormEvents();
  setUpEditCampaignIdLabelEvents();
  setUpEditImageCodesFormEvents();
  setUpEditCommentCodesFormEvents();
  setUpSaveNoteFormEvents();
  setUpEditNoteEvents();
  setUpAjaxPagination();
  setUpPostingTimeInputs();
  showSocialMediaProfiles();
  setUpExperimentRealTime();
  setUpPopupInfo();
  setUpDatePickers();
  setUpChosenDropdowns();
  setUpTagListInputs();
  setUpMessageTemplateImports();
  setUpImageImports();
  setUpAnalyticsFileImports();
  setUpPusherChannels();
  setUpAsyncMessageGeneration();
  setUpImagePoolViewing();

  // Set up Semantic UI
  $('.menu .item').tab({
    history: true,
    historyType: 'hash',
    context: 'parent'
  });
  $('.table.sortable').tablesort();
  $('.ui.dropdown').dropdown({
    onChange: function() {
      var imageId = $(this).data("image-id");
      $("#edit-image-codes-" + imageId).find('.save-image-codes').first().removeClass('disabled');
      
      var commentId = $(this).data("comment-id");
      $("#edit-comment-codes-" + commentId).find('.save-comment-codes').first().removeClass('disabled');
    }
  });

  // Lazyload for images
  $("img").lazyload({
    threshold : 500,
    effect : "fadeIn"
  });
});