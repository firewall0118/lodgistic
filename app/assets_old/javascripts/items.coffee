# Index
# syncronized checkbox swimming
$(document).on 'change', '#check_all', ->
  $checkBoxes = $('[name=selected_item_ids]')
  if @checked
    $checkBoxes.prop 'checked', true
  else
    $checkBoxes.prop 'checked', false

$(document).ready ->
  $('input[name="selected_item_ids"]').change (e)->
    if !e.target.checked
      $('#check_all').attr 'checked', false

$(document).on 'click', '#btn-order', (e)->
  e.preventDefault()
  selected_ids = $('input[name=selected_item_ids]:checked').map ->
    $(@).val()
  .get()
  
  Turbolinks.visit $(@).attr('href') + '?' + $.param(q: {id_in: selected_ids})

# multiple edit
$(document).on 'click', '.bulk_action', (e)->
  $checkBoxes = $('[name=selected_item_ids]')
  e.preventDefault()

  $modal = $('.reveal-modal')
  selected_item_ids = $checkBoxes.filter(':checked').map(-> $(@).val()).get()

  $modal.foundation 'reveal', 'open',
    url: $(@).attr('href')
    data:
      selected_item_ids: selected_item_ids

  $modal.foundation 'reveal', 'close'

# Edit
options = []

addSelectedOption = (field)->
  $select = $("#{field}_id")
  id = $select.val()
  $name = $("#{field}_attributes_name")
  name = $name.val()
  if id isnt '' and $.grep(options, (element)-> element.val is id).length is 0
    options.push
      val: id
      text: $select.find("option[value=#{$select.val()}]").text()
  else if name and name isnt '' and $.grep(options, (element)-> element.val is name).length is 0
    options.push
      val: name
      text: name

rebuildSelect = (selector)->
  $select = $(selector)
  value = $select.val()
  $select.html ''
  $(options).each ->
   $select.append $('<option>').attr('value', @val).text(@text)
  $select.val value

buildSelect = ->
  options = [
    val: ''
    text: 'Select a unit'
  ]
  addSelectedOption field for field in ['#item_unit', '#item_subpack', '#item_pack']
  rebuildSelect selector for selector in ['#item_inventory_unit_id', '#item_purchase_unit_id', '#item_price_unit_id']

toggleFieldset = (field, fieldset)->
  $fieldset = $(fieldset)
  if $(field).val() is ''
    $fieldset.show()
    $fieldset.find('input, textarea').val ''
  else
    $fieldset.hide()
    $fieldset.find('input, textarea').val ''
  buildSelect()

$(document).on 'ready page:load', ->
  $('.items select').change()

$(document).on 'change', '#item_unit_attributes_name, #item_subpack_attributes_name, #item_pack_attributes_name', ->
  buildSelect()

$(document).on 'change', '#item_unit_id', ->
  toggleFieldset @, '#add_unit'

$(document).on 'change', '#item_subpack_id', ->
  toggleFieldset @, '#add_subpack'

$(document).on 'change', '#item_pack_id', ->
  toggleFieldset @, '#add_pack'
