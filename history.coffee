class History
  constructor: (@historyData) ->
  add: (listOfIncorrect) ->
    @historyData.historyLength += 1
    for i in listOfIncorrect
      @historyData.history[i] += 1
    if @historyData.historyLength >= @historyData.maxHistoryLength
      @historyData.historyLength -= 1
    for i,j in @historyData.history
      @historyData.history[i] -= 1 if j > 0
  colors: () ->
    cssColor = {}
    if @historyData.historyLength > 0
      for i, wrong of @historyData.history
        cssColor[i] = "hsl(#{116*(1-(wrong/@historyData.historyLength))}, 100%, 45%)"
    else
      for i, wrong of @historyData.history
        cssColor[i] = "#eee"
    cssColor