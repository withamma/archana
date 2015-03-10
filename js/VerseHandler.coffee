class VerseHandler
  constructor: (@verses, @meanings, @length, @_storage, @_state) ->
    @length = Object.keys(@verses).length
    @storedState = ->
      @_storage[@_state.itemId]

    @storedState.currentPosition = 0 if not @storedState.currentPosition?
    @currentPosition = @storedState.currentPosition

    @hasNext = ->
      if @currentPosition + 2 < @length then true else false

    @hasPrev = ->
      if @currentPosition > -1 then true else false

    @next = ->
      @currentPosition += 1 if @hasNext()

    @prev = ->
      @currentPosition -= 1 if @hasPrev()

    @getVerse = ->
      @verses[@currentPosition]

    @getMeaning = ->
      @meanings[@currentPosition]

    @peekNextVerse = ->
      @verses[@currentPosition+1] if @hasNext()

    @peekNextMeaning = ->
      @meanings[@currentPosition+1] if @hasNext()

    @setPosition = (location) ->
      location = parseInt(location) if location?
      if angular.isNumber location and location < @length  and location > -1
        @currentPosition = location
        
