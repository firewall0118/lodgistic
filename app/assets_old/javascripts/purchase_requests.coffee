filterItems = ->
  $pills = $('.right.pills')
  activeIdsSelector = $.map $pills.find('a.active').get(), (location)->
    "span.location[data-id=#{$(location).data 'id' }]"
  .join(',')

  all = $('tbody > tr').hide().length
  shown = $(activeIdsSelector).closest('tr').show().length

  $filter = $('#filter') 
  if shown is all
    $filter.text 'Showing all Locations'
  else
    $filter.text "Showing #{shown} items out of #{all}. "
    $('<a/>').attr('href', '#').text('Remove filter').appendTo($filter).click (e)->
      e.preventDefault()
      $pills.find('a').addClass('active')

      filterItems()

$(document).on 'change', 'input[id^=purchase_request_item_requests_attributes_][id$=_skip_inventory]', ->
  $(@).closest('tr').find('input[type=number]').val '' if $(@).prop 'checked'

$(document).on 'change', 'input[id^=purchase_request_item_requests_attributes_][id$=_count]', ->
  if @value isnt '' 
    $(@).closest('tr').find('input[type=checkbox]').prop 'checked', false
  else
    $(@).closest('tr').find('input[type=checkbox]').prop 'checked', true

$(document).on 'click', '.menubar > .right > a.btn:not(a.print)', ->
  $(@).parent().find('#commit').val $(@).data('action')
  $(@).closest('form.purchase_request').submit()

$(document).on 'ready page:load', ->
  locations = {}
  $.map $('span.location').get(), (location)->
    locations[$(location).data('id')] = $(location).text()

  $pills = $('.right.pills')
  $.each locations, (id, name)->
    $('<a/>').attr('data-id', id).text(name).addClass('pill active').appendTo($pills).click (e)->
      e.preventDefault()
      $(@).toggleClass 'active'

      filterItems()