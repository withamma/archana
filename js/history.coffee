app.constant "historyExpiration", 1409511179962
app.factory "History", ($localStorage, $stateParams, historyExpiration) ->
  new class History
    constructor: () ->
      id = $stateParams.itemId
      @getHistoryData = ->
        $localStorage[$stateParams.itemId].historyData
      @clear = ->
        $localStorage.historyReset = (new Date).getTime()
        $localStorage[id] = {} if not $localStorage[id]?
        $localStorage[id].historyData = {
          historyLength: 0
          maxHistoryLength: 15
          history: {}
        }
      if not $localStorage[id]? or not $localStorage[id].historyData? or not $localStorage.historyReset? or $localStorage.historyReset < @historyExpiration
        @clear()

    add: (listOfIncorrect) ->
      historyData = @getHistoryData()
      historyData.historyLength += 1
      for i in listOfIncorrect
        historyData.history[i] = 0 if not historyData.history[i]?
        historyData.history[i] += 1
      if historyData.historyLength >= historyData.maxHistoryLength
        historyData.historyLength -= 1
      for i,j in historyData.history
        historyData.history[i] -= 1 if j > 0

    colors: () ->
      historyData = @getHistoryData()
      cssColor = {}
      if historyData.historyLength > 0
        for i, wrong of historyData.history
          cssColor[i] = "hsla(#{116*(1-(wrong/historyData.historyLength))}, 100%,
          45%, .4)"
      cssColor
