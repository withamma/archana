app.service "VerseHandler", (LocalVerseData, VerseLocalStorage, $q) ->
  # localStorage used to store the position
  audioDefered = undefined
  @reload = ->
    audioDefered = $q.defer()
    LocalVerseData.reload()
    @state = VerseLocalStorage.getState()
    @state.currentPosition = 0 if not @state.currentPosition?
    LocalVerseData.verses.then (data) =>
      @verses = data.listToLearn
      @meanings = data.listOfMeaning
      @title = data.title
      @max = Object.keys(@verses).length - 1
      @audioURL = data.audioURL
      # @audioURL = if data.audioURL then data.audioURL + "#t=" else null
      audioDefered.resolve( data.audioURL isnt undefined )
      @audioTimes = data.audioTimes
      @state.currentPosition = 0 if @state.currentPosition == @max
      return

  @hasAudio = ->
    audioDefered.promise

  @hasNext = ->
    if @state.currentPosition < @max then true else false

  @getTitle = ->
    @title

  @hasPrev = ->
    if @state.currentPosition > 0 then true else false

  @next = ->
    @state.currentPosition += 1 if @hasNext()

  @prev = ->
    @state.currentPosition -= 1 if @hasPrev()

  @getVerse = ->
    @verses?[@state.currentPosition]

  @getMeaning = ->
    @meanings?[@state.currentPosition]

  @getAudioSegmentSrc = ->
    if @audioURL
      time = @audioTimes[@state.currentPosition]
      @audioURL + time

  @getAudioSegmentTimes = ->
    @audioTimes[@state.currentPosition].split(",")

  @peekNextVerse = ->
    @verses[@state.currentPosition+1] if @hasNext()

  @peekNextMeaning = ->
    @meanings[@state.currentPosition+1] if @hasNext()

  @setPosition = (location) ->
    location = parseInt(location) if location?
    if angular.isNumber location and location < @length  and location > -1
      @state.currentPosition = location

  @getPosition = ->
    @state.currentPosition

  return