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

@loadColorSelectors = () ->
  $('[data-object~="color-selector"]').each( () ->
    $this = $(this)
    $this.ColorPicker(
      color: $this.data('color')
      onShow: (colpkr) ->
        $(colpkr).fadeIn(500)
        return false
      onHide: (colpkr) ->
        $(colpkr).fadeOut(500)
        $($this.data('form')).submit()
        return false
      onChange: (hsb, hex, rgb) ->
        $($this.data('target')).val('#' + hex)
        $($this.data('target')+"_display").css('backgroundColor', '#' + hex)
      onSubmit: (hsb, hex, rgb, el) ->
        $(el).ColorPickerHide();
    )
  )

@initializeTypeahead = () ->
  $('#mrn').each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + 'patients' + "?mrn=%QUERY" + "&autocomplete=true"
      template: '<p>{{text}}</p>'
      engine: Hogan
    )
  )
  $('[data-object~="typeahead"]').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@ready = () ->
  contourReady()
  initializeTypeahead()
  loadColorSelectors()
  updateFields($('#call_call_type'))
  $('#call_call_type').change( () -> updateFields($(this)) )
  updateFields($('#evaluation_administration_type'))
  $('#evaluation_administration_type').change( () -> updateFields($(this)) )
  setFocusToField("#search, #mrn")

$(document).ready(ready)
$(document).on('page:load', ready)
$(document)
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
