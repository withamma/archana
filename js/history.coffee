app.constant "historyExpiration", 1409511179962
app.factory "History", ($localStorage, $stateParams, historyExpiration) ->
  history = {}
  data = undefined
  current_storage = undefined
  history.restore = ->
    current_storage = $localStorage[$stateParams.itemId]
    if not current_storage? or not current_storage.data? or not $localStorage.historyReset? or $localStorage.historyReset < history.historyExpiration
      history.clear()
    data = current_storage.data
    
  history.clear = ->
    $localStorage.historyReset = (new Date).getTime()
    current_storage = {} if not current_storage?
    current_storage.data = {
      historyLength: 0
      maxHistoryLength: 15
      history: {}
    }
  
  history.add = (listOfIncorrect) ->
    data.historyLength += 1
    for i in listOfIncorrect
      data.history[i] = 0 if not data.history[i]?
      data.history[i] += 1
    if data.historyLength >= data.maxHistoryLength
      data.historyLength -= 1
    for i,j in data.history
      data.history[i] -= 1 if j > 0

  history.colors = ->
    cssColor = {}
    if data.historyLength > 0
      for i, wrong of data.history
        cssColor[i] = "hsla(#{116*(1-(wrong/data.historyLength))}, 100%,
        45%, .4)"
    cssColor

  history
