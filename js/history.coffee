class History
  constructor: (@storage, @state, @historyExpiration) ->
    id = @state.itemId
    @getHistoryData = ->
      @storage[@state.itemId].historyData
    @clear = ->
      storage.historyReset = (new Date).getTime()
      storage[id] = {} if not storage[id]?
      storage[id].historyData = {
        historyLength: 0
        maxHistoryLength: 15
        history: {}
      }
    if not storage[id]? or not storage[id].historyData? or not storage.historyReset? or storage.historyReset < @historyExpiration
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
