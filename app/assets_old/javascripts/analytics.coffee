$(document).on 'ready page:load', ->
  window.$placeholder = $placeholder = $('#placeholder')

  window.data = data = [
    data: $placeholder.data 'points'
    label: 'Inventory'
  ]

  window.options = options =
    series:
      lines:
        show: true
      points:
        show: true
    grid:
      hoverable: true
      clickable: true
    yaxis:
      min: parseInt($placeholder.data 'min') - 1
      max: parseInt($placeholder.data 'max') + 1
    xaxis:
      mode: 'time'
    selection:
      mode: 'x'

  # Add the Flot version string to the footer
  $('#footer').prepend "Flot #{$.plot.version} &ndash; "

  # Reset the graph for the first time
  $('#reset').click()

$(document).on 'change', '#items', ->
  Turbolinks.visit $(@).data('url') + '?' + $.param(item_id: @value)

$(document).on 'click', '#reset', ->
  window.plot = $.plot window.$placeholder, window.data, window.options

$(document).on 'plotselected', window.$placeholder, (event, ranges)->
  window.plot = $.plot window.$placeholder, window.data, $.extend(true, {}, options,
    xaxis:
      min: ranges.xaxis.from
      max: ranges.xaxis.to
  )
  # setSelection didn't work
  # https://github.com/flot/flot/blob/0.8.1/jquery.flot.selection.js#L53
  # window.plot.setSelection
  #   xaxis:
  #     from: ranges.xaxis.from
  #     to: ranges.xaxis.to
  # , true

showTooltip = (x, y, contents)->
  $("<div id=\"tooltip\">#{contents}</div>").css
    position: 'absolute'
    display: 'none'
    top: y + 5
    left: x + 5
    border: '1px solid #fdd'
    padding: '2px'
    'background-color': '#fee'
    opacity: 0.80
  .appendTo('body').fadeIn 200

previousPoint = null
$(document).on 'plothover', window.$placeholder, (event, pos, item)->
  if item
    if previousPoint != item.dataIndex
      previousPoint = item.dataIndex
      $('#tooltip').remove()
      x = item.datapoint[0]
      y = item.datapoint[1].toFixed 2

      showTooltip item.pageX, item.pageY, "#{item.series.label} for #{$.plot.formatDate(new Date(x), '%b %d')} = #{y}"
  else
    $('#tooltip').remove()
    previousPoint = null

$(document).on 'plotclick', window.$placeholder, (event, pos, item)->
  if item
    $('#clickdata').text " - click point #{item.dataIndex} in #{item.series.label}"
    window.plot.highlight item.series, item.datapoint