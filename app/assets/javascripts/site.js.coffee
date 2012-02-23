jQuery ->
  $(".datepicker").datepicker
    showOtherMonths: true
    selectOtherMonths: true
    changeMonth: true
    changeYear: true

  $("#ui-datepicker-div").hide()

  $(".pagination a, .page a, .next a, .prev a").live("click", () ->
    $.get(this.href, null, null, "script")
    false
  )

  $(".per_page a").live("click", () ->
    object_class = $(this).data('object')
    $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script")
    false
  )
