// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  $('.tabular .item').tab();

  var $imageTableCell;

  $('a.choose-from-dropbox').click(function() {
    $imageTableCell = $(this).parent();

    // Dropbox Chooser Drop-in
    options = {
      // Required. Called when a user selects an item in the Chooser.
      success: function(files) {
        var selectedFiles = files;
        var messageId = $imageTableCell.attr('id');
        console.log($imageTableCell);
        messageId = messageId.substring(8, messageId.length);

        $.ajax({
          url: "/organic_messages/set_image_urls",
          type: 'POST',
          data: {message_id: messageId, image_url: selectedFiles[0].link, thumbnail_url: selectedFiles[0].thumbnailLink},
          dataType: 'json',
          async: false,
          success: function(retdata) {
            $imageTableCell.prepend('<img src="' + selectedFiles[0].thumbnailLink + '"/>');
          }
        });

      },

      // Optional. Called when the user closes the dialog without selecting a file
      // and does not include any parameters.
      cancel: function() {
      },

      // Optional. "preview" (default) is a preview link to the document for sharing,
      // "direct" is an expiring link to download the contents of the file. For more
      // information about link types, see Link types below.
      linkType: "preview", // or "direct"

      // Optional. A value of false (default) limits selection to a single file, while
      // true enables multiple file selection.
      multiselect: false, // or true

      // Optional. This is a list of file extensions. If specified, the user will
      // only be able to select files with these extensions. You may also specify
      // file types, such as "video" or "images" in the list. For more information,
      // see File types below. By default, all extensions are allowed.
      extensions: ['.png']
    };

    Dropbox.choose(options);

    return false;
  });
});

