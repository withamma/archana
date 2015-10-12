app.directive "fullCoverImage", ->
  (scope, element, attrs) ->
    element.css "background-image", "url(#{attrs.fullCoverImage})"
    element.addClass "full-bg"

app.controller "ItemListerCtrl", ["$scope", "$http", ($scope, $http) ->
  $http.get("./learn/index.json").success (data) ->
    $scope.items = data
]

app.controller "LearnCtrl", ($scope, VerseHandler, VerseLocalStorage, mobile, hotkeys, History, $location, $rootScope)->
  defaults = 
    audioPlaybackRate: 1
    layoutSide: "Right"
    autoplay: "Off"
    meaning: "Off"
    audio: "On"
    hasAudio: true

  audio = $("#audioPlayer")[0]
  audioTimeout = undefined

  storage = VerseLocalStorage.getState()
  $scope.storage = VerseLocalStorage.getState()
  for k,v of defaults
    storage[k] = storage[k] ? v
    # $scope.settings[k] = storage[k]

  VerseHandler.reload()
  $scope.VerseHandler = VerseHandler
  VerseHandler.hasAudio().then (hasAudio)->
    storage.hasAudio = hasAudio
    storage.audio = if hasAudio then "On" else "Off"
    # $scope.settings.hasAudio = hasAudio
    # $scope.settings.audio = if hasAudio then "On" else "Off"
    audio.load() if hasAudio

  History.restore()
  colors = History.colors()

  $scope.bg = "img/feet.jpg"
  $scope.mobile = mobile
  audio.defaultPlaybackRate = $scope.storage.audioPlaybackRate
  $scope.updateAudioSettings = ->
    console.log "called"
    audio.defaultPlaybackRate = $scope.storage.audioPlaybackRate
    audio.playbackRate = $scope.storage.audioPlaybackRate

  resetAudio = ->
    if !audio.paused
      clearTimeout(audioTimeout)
      audio.pause()
    return

  $scope.playAudio = ($event)->
    $event.stopPropagation()
    resetAudio()
    [start, stop] = VerseHandler.getAudioSegmentTimes()
    [start, stop] = [parseFloat(start), parseFloat(stop)]
    audio.currentTime = start
    audio.play()
    audioTimeout = setTimeout(-> 
        audio.pause()
        return
      ,(stop-start) / audio.defaultPlaybackRate * 1000)
    false

  $scope.home = ->
    $location.path "/"

  $scope.fixSlider = ->
    # this timeout is to make sure that the menu is opened
    setTimeout ->
        $rootScope.$broadcast("rzSliderForceRender")
      , 200
    true

  $scope.getColor = ->
    "background-color": colors[VerseHandler.state.currentPosition]
  $scope.title = ->
    VerseHandler.getTitle()
  $scope.verse = ->
    VerseHandler.getVerse()
  $scope.meaning = ->
    VerseHandler.getMeaning()

  $scope.next = ($event)->
    $event.stopPropagation()
    resetAudio()
    VerseHandler.next()
    $scope.playAudio($event) if $scope.storage.autoplay is "On"
    false

  $scope.prev = ($event)->
    $event.stopPropagation()
    resetAudio()
    VerseHandler.prev()
    $scope.playAudio($event) if $scope.storage.autoplay is "On"
    false

  $scope.getAudioSegmentSrc = ()->
    VerseHandler.getAudioSegmentSrc()

  hotkeys.bindTo($scope)
    .add({
      combo: 'space'
      description: 'Next'
      callback: () -> $scope.next()
    })