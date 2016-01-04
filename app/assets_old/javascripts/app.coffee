# need to use this for splitdropbutton to work properly with font-awesome
$(window).on 'load page:load', ->
  $(document).foundation()

  # Change property
  $('#current_property_id').on 'change', ->
    $.getJSON $(this).find(":selected").data("url"), (data)->
      Turbolinks.visit(window.location.href)
      # location.reload true

  scrollbox_height = $(window).height() - $('.maincontent').offset().top - 100
  $('.scrollbox').css('max-height', scrollbox_height)

  # Split DropDown Button
  $('.split-btn').splitdropbutton
    toggleDivContent: '<i class="icon-reorder"></i>'

  # Close Alert Box
  $('.alert-box .close').on 'click', ->
    $(@).parent().fadeOut()

  # CheckableTableRows
  $('.checkablerows').checkedTableRow
    ignoreLinksSelector: '.split-btn'
    checkedClass: 'highlight'

  # Reveal
  $('.close').on 'click', ->
    $(@).closest('.reveal-modal').foundation 'reveal', 'close'

  # Select2
  window.SELECT2_OPTIONS = {
    width: '100%'
    formatSelection: (tag)->
      tag.text.trim()
    formatResult: (tag, container)->
      el = $(tag.element)
      $('<span/>', {
        class: 'select2-match',
        'data-parent-id': el.data('parent-id')
      }).get(0).outerHTML + tag.text
    }

  $('.select2').select2 window.SELECT2_OPTIONS

  leftheight = ($('.list').height() + $('.budget').height() + 10)
  $('.orders').height(leftheight)

  $(window).resize ->
    if $(window).width() > 752
      $('.nav').show()
    else
      $('.nav').hide()

  $("#nav li").on "mouseenter", (event) ->
    $(this).find(".subnav").show()  if @children.length > 1
    $(this).find(".subnav li").show()

  $("#nav .wrap").on "mouseleave", (event) ->
    $(this).find(".subnav").hide()
    $(this).find(".subnav li").hide()

  $("#nav h2").on "click", (event) ->
    if $(".nav").css("display") is "none"
      $(".nav").show()
    else
      $(".nav").hide()

  $('.wrap').on "click", (event) ->
    if $(this).find('.subnav').css('display') is 'none'
      $(this).find('.subnav').show()
    else
      $(this).find('.subnav').hide()

  current = $('#current_property_id option').length
  if current > 1
    $('#current_property_id').css('top', '0')

  $("p.title").click ->
    $("p.title").children("span.rightcontainer").children("span.showHide").text("+")
    $(this).children("span.rightcontainer").children("span.showHide").text("-")

  # Add and Remove Button show changes to list items.
  # This is a bit of a mess, will need to clean up later.

$(document).on 'click', '.add_btn', (event) ->
  $(@).removeClass 'add_btn'
  $(@).addClass 'remove_btn'
  $(@).text 'Remove'
  row = $(@).parent().parent()
  row.removeClass 'warning'
  row.addClass 'highlight'
  row.find('input[type=checkbox]').prop 'checked', true
  $('#included table tbody').append row

$(document).on 'click', '.remove_btn', (event) ->
  $(@).removeClass 'remove_btn'
  $(@).addClass 'add_btn'
  $(@).text 'Add'
  row = $(@).parent().parent()
  row.removeClass 'highlight'
  row.addClass 'warning'
  row.find('input[type=checkbox]').prop 'checked', false
  $('#excluded table tbody').append row

$(document).on "change", '#item_unit_id', (event) ->
  subSelect = $('#item_unit_id option:selected').text()
  if(subSelect is 'Enter a new Unit')
    $('.item_unit_subpack label').text('')
    $('#item_unit_attributes_name').on 'keyup', (event) ->
      $('.item_unit_subpack label').text($('#item_unit_attributes_name').val())
  else
    $('.item_unit_subpack label').text(subSelect)

$(document).on "change", '#item_subpack_id', (event) ->
  subpackSelect = $('#item_subpack_id option:selected').text()
  if(subpackSelect is 'Enter a new Unit')
    $('.item_subpack_pack label').text('')
    $('#item_subpack_attributes_name').on 'keyup', (event) ->
      $('.item_subpack_pack label').text($('#item_subpack_attributes_name').val())
  else
    $('.item_subpack_pack label').text(subpackSelect)
