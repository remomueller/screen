# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '[data-object~="set-current-time"]', () ->
      currentTime = new Date()
      day = currentTime.getDate()
      month = currentTime.getMonth() + 1
      year = currentTime.getFullYear()
      hours = currentTime.getHours()
      minutes = currentTime.getMinutes()

      minutes = "0" + minutes if minutes < 10
      month = "0" + month if month < 10
      day = "0" + day if day < 10

      $("#call_time").val(hours+":"+minutes)
      $("#call_date").val(month + "/" + day + "/" + year)
      false
    )

  updateFields($('#call_call_type'))

  $('#call_call_type').change( () ->
    updateFields($(this))
  )

  updateFields($('#evaluation_administration_type'))

  $('#evaluation_administration_type').change( () ->
    updateFields($(this))
  );
