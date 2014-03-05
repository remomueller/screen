# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document)
  .on('click', '.tag-checkbox', () ->
    if $(this).children().is(':checked')
      $(this).addClass('tag-selected')
    else
      $(this).removeClass('tag-selected')
  )
