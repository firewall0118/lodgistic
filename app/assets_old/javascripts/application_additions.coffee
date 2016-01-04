$(document).on 'ready page:load', ->
  $('#current_property_id').on 'change', ->
    $.getJSON "/properties/#{$(this).val()}.json", (data)->
      location.reload true
