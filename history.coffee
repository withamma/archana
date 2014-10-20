class History
  constructor: ($localStorage, $routeParams, historyExpiration) ->
    id = $routeParams.itemId
    @clear = ->
      $localStorage.historyReset = (new Date).getTime()
      $localStorage[id] = {} if not $localStorage[id]?
      $localStorage[id].historyData = {
        historyLength: 0
        maxHistoryLength: 15
        history: {}
      }
    if not $localStorage[id]? or not $localStorage[id].historyData? or not $localStorage.historyReset? or $localStorage.historyReset < historyExpiration
      @clear()
    @historyData = $localStorage[id].historyData
    console.log @historyData

  add: (listOfIncorrect) ->
    console.log listOfIncorrect
    @historyData.historyLength += 1
    for i in listOfIncorrect
      @historyData.history[i] = 0 if not @historyData.history[i]?
      @historyData.history[i] += 1
    if @historyData.historyLength >= @historyData.maxHistoryLength
      @historyData.historyLength -= 1
    for i,j in @historyData.history
      @historyData.history[i] -= 1 if j > 0

  colors: () ->
    cssColor = {}
    if @historyData.historyLength > 0
      for i, wrong of @historyData.history
        cssColor[i] = "hsla(#{116*(1-(wrong/@historyData.historyLength))}, 100%,
        45%, .4)"
    cssColor
