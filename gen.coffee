if document.location.hostname is "archana.dev"
  css = [
    "<link rel='stylesheet' href='//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>"
    "<link href='//fonts.googleapis.com/css?family=Source+Code+Pro&subset=latin,latin-ext' rel='stylesheet' type='text/css'>"
    "<link rel='stylesheet' href='./listlearner.css'>"
    "<link rel='stylesheet' href='./bower_components/angular-hotkeys/src/hotkeys.css'>"
  ]
  document.appendChild(css.join(""))
else 
  css = [
    "<link rel='stylesheet' href='//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>"
    "<link href='//fonts.googleapis.com/css?family=Source+Code+Pro&subset=latin,latin-ext' rel='stylesheet' type='text/css'>"
    "<link rel='stylesheet' href='./listlearner.css'>"
    "<link rel='stylesheet' href='./bower_components/angular-hotkeys/src/hotkeys.css'>"
  ]
  document.appendChild(css.join(""))