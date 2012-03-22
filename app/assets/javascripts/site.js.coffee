jQuery ->
  $(".datepicker").datepicker
    showOtherMonths: true
    selectOtherMonths: true
    changeMonth: true
    changeYear: true

  $("#ui-datepicker-div").hide()

  $(document).on('click', ".pagination a, .page a, .next a, .prev a", () ->
    $.get(this.href, null, null, "script")
    false
  )

  $(document).on("click", ".per_page a", () ->
    object_class = $(this).data('object')
    $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script")
    false
  )

  $("#set_current_time").on("click", () ->
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

  $("#mrn")
    .autocomplete(
      source: root_url + "patients?autocomplete=true"
      html: true
      close: (event, ui) ->
        $(this).closest('form').submit()
    )
