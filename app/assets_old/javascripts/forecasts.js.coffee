$(document).on "change", ".room_forecast", ->
  $.ajax
    dataType: "script"
    type: "PUT"
    url: $(@).data("url")
    data:
      occupancy: $(@).val()
