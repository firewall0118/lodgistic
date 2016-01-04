$(document).ready ->
  alertClasses = {
    info: 'info'
    alert: 'danger'
    warning: 'warning'
    error: 'danger'
    notice: 'success'
  }

  for message in $('.alert-messages').data('messages')
    alertClass = message[0]
    alertMessage = message[1]

    $.gritter.add
      time: 5000
      text: alertMessage
      class_name: "alert alert-#{alertClasses[alertClass]}"
