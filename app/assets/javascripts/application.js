//= require pusher.min
//= require array-find-index-polyfill
//= require adminre_theme_v120/library/jquery/js/jquery.min
//= require adminre_theme_v120/plugins/jqueryui/js/jquery-ui.min
//= require adminre_theme_v120/library/jquery/js/jquery-migrate.min
//= require jquery_ujs
//= require adminre_theme_v120/library/bootstrap/js/bootstrap
//= require adminre_theme_v120/library/core/js/core
//= require adminre_theme_v120/plugins/sparkline/js/jquery.sparkline
//= require adminre_theme_v120/javascript/app.js
//= require adminre_theme_v120/plugins/bootbox/js/bootbox
//= require adminre_theme_v120/plugins/flot/jquery.flot
//= require adminre_theme_v120/plugins/flot/jquery.flot.categories
//= require adminre_theme_v120/plugins/flot/jquery.flot.tooltip
//= require adminre_theme_v120/plugins/flot/jquery.flot.resize
//= require adminre_theme_v120/plugins/flot/jquery.flot.spline
//= require adminre_theme_v120/plugins/flot/jquery.flot.pie
//= require jquery.flot.orderBars
//= require adminre_theme_v120/plugins/selectize/js/selectize
//= require adminre_theme_v120/plugins/gritter/js/jquery.gritter
//= require adminre_theme_v120/plugins/selectize/js/selectize.min
//
//= require adminre_theme_v120/plugins/datatables/js/jquery.datatables
//= require adminre_theme_v120/plugins/datatables/tabletools/js/tabletools
//= require adminre_theme_v120/plugins/datatables/tabletools/js/zeroclipboard
//= require adminre_theme_v120/plugins/datatables/js/jquery.datatables-custom

//= require datatable
//= require jquery.numeric
//= require date
//= require jquery.ba-throttle-debounce
//= require highchart-4.0.4/highcharts
//
//= require adminre_theme_v120/plugins/shuffle/js/jquery.shuffle.min
//= require bootstrap-confirmation
//= require format
//= require js-routes
//= require tags
//= require departments
//= require adminre_theme_v120/plugins/parsley/js/parsley
//= require jsvalidate-forms
//= require forms
//= require users
//= require alerts
//= require grid-search
//= require datatable-search
//= require items
//= require item_form
//= require items_import
//= require sparkline-graphs
//= require reports
//= require fax
//= require pusher
//= require notifications
//= require dashboard
//= require messaging
//= require budgets
//= require vendors

//= require reports/date-range


// adjust main section padding for mobile devices dynamically:
$(function(){
  $main = $('#main'), $header = $('#header');
  function updatePadding(){
    $.debounce(1000, function(){
      $main.css({ 'padding-top': $header.innerHeight() })
    })() 
  }
  window.onresize = updatePadding;
  updatePadding()
})
