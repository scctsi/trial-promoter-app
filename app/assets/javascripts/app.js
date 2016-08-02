/*global $*/
$(document).ready(function() {
  function setUpDatePickers() {
    $("[id$='_date']").daterangepicker({
      singleDatePicker: true,
      showDropdowns: true
    }); 
  }

  // Initialize
  setUpDatePickers();
});

