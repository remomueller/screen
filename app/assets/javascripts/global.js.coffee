@updateFields = (element) ->
  if window.choices[$(element).val()]?
    window.show_fields = window.choices[$(element).val()]
    diff = window.toggle_fields.filter( (x) -> return window.show_fields.indexOf(x) < 0 )
    for field in window.toggle_fields
      $(field).removeAttr('disabled')
      $(field).parent().show()
    for field in diff
      $(field).attr('disabled', 'disabled')
      $(field).parent().hide()
  else
    for field in window.toggle_fields
      $(field).attr('disabled', 'disabled')
      $(field).parent().hide()

jQuery ->

  $("#mrn")
    .autocomplete(
      source: root_url + "patients?autocomplete=true"
      html: true
      close: (event, ui) ->
        $(this).closest('form').submit()
    )

  $(document)
    .on('click', '[data-object~="screen-token-update"]', () ->
      $('#screen_token').val($('#task_tracker_screen_token').val())
      $.post($($(this).data('target')).attr('action'), $($(this).data('target')).serialize(), null, 'script')
      false
    )
    .on('click', '[data-object~="ignore"]', () ->
      false
    )
    .on('click', '[data-object~="export"]', () ->
      window.location = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
      false
    )
    .on('click', '[data-object~="form-reset-and-hide"]', () ->
      $($(this).data('target') + '_form_form')[0].reset();
      $($(this).data('target') + '_form').hide();
      $($(this).data('target') + '_show').show();
    )
