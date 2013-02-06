@updateFields = (element) ->
  if window.$choices? and window.$toggle_fields?
    if window.$choices[$(element).val()]?
      window.$show_fields = window.$choices[$(element).val()]
      diff = window.$toggle_fields.filter( (x) -> return window.$show_fields.indexOf(x) < 0 )
      for field in window.$toggle_fields
        $(field).removeAttr('disabled')
        $(field).parent().show()
      for field in diff
        $(field).attr('disabled', 'disabled')
        $(field).parent().hide()
    else
      for field in window.$toggle_fields
        $(field).attr('disabled', 'disabled')
        $(field).parent().hide()

jQuery ->

  $("#mrn").select2(
    placeholder: "Enter Code(s) or one MRN"
    allowClear: true,
    width: 'resolve'
    minimumInputLength: 1
    tags: []
    tokenSeparators: [",", " "]
    initSelection: (element, callback) ->
      callback([])
    ajax:
      url: root_url + "patients"
      dataType: 'json'
      data: (term, page) -> { term: term, autocomplete: 'true' }
      results: (data, page) -> # parse the results into the format expected by Select2.
          return results: data
  ).on("change", (e) ->
    $(this).closest('form').submit()
  )


  # $("#mrn")
  #   .autocomplete(
  #     source: root_url + "patients?autocomplete=true"
  #     html: true
  #     close: (event, ui) ->
  #       $(this).closest('form').submit()
  #   )

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

  $('[data-object~="color-selector"]').each( () ->
    $this = $(this)
    $this.ColorPicker(
      color: $this.data('color')
      onShow: (colpkr) ->
        $(colpkr).fadeIn(500)
        return false
      onHide: (colpkr) ->
        $(colpkr).fadeOut(500)
        return false
      onChange: (hsb, hex, rgb) ->
        $($this.data('target')).val('#' + hex)
        $($this.data('target')+"_display").css('backgroundColor', '#' + hex)
      onSubmit: (hsb, hex, rgb, el) ->
        $(el).ColorPickerHide();
    )
  )
