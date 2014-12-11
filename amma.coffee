app.directive "fullCoverImage", ->
  (scope, element, attrs) ->
    element.css "background-image", "url(#{attrs.fullCoverImage})"
    element.addClass "full-bg"

app.controller "ItemListerCtrl", ["$scope", "$http", ($scope, $http) ->
  $http.get("learning-items.json").success (data) ->
    $scope.items = data
]

app.constant "historyExpiration", 1409511179962
app.constant "storageExpiration", 1416095403068
app.service "HistoryService", ["$localStorage", "$stateParams", "historyExpiration", History]

app.controller "TestCtrl", ["$scope", '$stateParams', '$http', "$location",
'$localStorage', 'hotkeys', 'HistoryService', 'storageExpiration', ($scope, $stateParams, $http,
$location, storage, hotkeys, history, storageExpiration) ->
  id = "#{$stateParams.itemId}"
  $scope.state = "loading"
  $scope.hint = false
  bindHotkeys = ->
    hotkeys.bindTo($scope)
      .add({
        combo: 'u'
        description: 'Undo'
        callback: () -> $scope.undo()
      })
      .add({
        combo: 'c'
        description: 'Correct answer'
        callback: () -> $scope.submitAnswer "correct"
      })
      .add({
        combo: 'x'
        description: 'Wrong answer'
        callback: () -> $scope.submitAnswer "incorrect"
      })
      .add({
        combo: 'r'
        description: 'Restart'
        callback: () -> $scope.restart()
      })
      .add({
        combo: 's'
        description: 'Show Answer'
        callback: () -> $scope.showAnswer()
      })
      .add({
        combo: 'space'
        description: 'Show Answer'
        callback: () -> $scope.showAnswer()
      })
      .add({
        combo: 'm'
        description: 'Show Meaning'
        callback: () -> $scope.toggleMeaning()
      })
      .add({
        combo: 'h'
        description: 'Show Hint'
        callback: () -> $scope.showHint()
      })
      .add({
        combo: 'e'
        description: 'Empty History'
        callback: () -> $scope.emptyHistory()
      })

  bindHotkeys()
  defaults =
    "currentPosition": 0
    "displayMeaning": false
    "incorrect": []
  for k,v of defaults
    storage[id][k] = v if not storage[id][k]?

  incorrect = storage[id]["incorrect"]
  $scope.currentPosition = if storage[id]["currentPosition"]? then  storage[id]["currentPosition"] else 0
  $scope.displayMeaning = storage[id]["displayMeaning"]
  colors = {}
  $scope.emptyHistory = ->
    history.clear()
    colors = history.colors()

  $scope.home = ->
    $location.path "/"

  if storage[id].listToLearn? and storage.lastUpdate? and storage.lastUpdate > storageExpiration
    $scope.listToLearn = storage[id].listToLearn
    $scope.listOfMeaning = storage[id].listOfMeaning
    $scope.title = storage[id].title
    $scope.state = "show"
    colors = history.colors()

  else
    $http.get("learn/#{$stateParams.itemId}.json").success (data) ->
      storage.lastUpdate = (new Date).getTime()
      storage[id].listToLearn = data.listToLearn
      storage[id].listOfMeaning = data.listOfMeaning
      storage[id].title = data.title
      $scope.listToLearn = data.listToLearn
      $scope.listOfMeaning = data.listOfMeaning
      $scope.title = data.title
      $scope.state = "show"
      colors = history.colors()


  $scope.getColor = ->
    {
      "background-color": if $scope.state is "show" then colors[$scope.currentPosition]    }


  $scope.showAnswer = () ->
    if $scope.state is "end"
      $location.path "results/#{id}"
    $scope.state = "answer"

  $scope.toggleMeaning = () ->
    $scope.displayMeaning = !$scope.displayMeaning

  nextState = () ->
    $scope.hint = false
    if $scope.currentPosition + 2 < $scope.listToLearn.length
      $scope.currentPosition += 1
      storage[id]["currentPosition"] = $scope.currentPosition
      $scope.state = "show"
    else
      $scope.state = "end"

  $scope.showHint = () ->
    $scope.hint = true

  $scope.getHint = () ->
    if $scope.state is "show" then nextInLink().slice(0,15) else ""

  $scope.submitAnswer = (result) ->
    if ($scope.state is "answer")
      if (result isnt "correct")
        incorrect.push $scope.currentPosition
      nextState()

  previousInLink = (meaning) ->
    if (meaning?) then $scope.listOfMeaning[$scope.currentPosition] else $scope.listToLearn[$scope.currentPosition]

  nextInLink = (meaning) ->
    if (meaning?) then $scope.listOfMeaning[$scope.currentPosition + 1] else $scope.listToLearn[$scope.currentPosition + 1]

  $scope.linkPrevious = () ->
    if ($scope.state isnt "loading") then previousInLink() else "Loading"

  $scope.linkTest = () ->
    if ($scope.state is "loading")
      return "Loading"
    else if ($scope.state is "answer")
      return nextInLink()
    else
      return previousInLink()

  $scope.meaning = () ->
    if ($scope.state is "loading")
      return "Loading"
    else if ($scope.state is "answer")
      return nextInLink(true)
    else
      return previousInLink(true)

  $scope.showResults = () ->
    $location.path "results/#{id}"

  $scope.restart = () ->
    storage[id]["currentPosition"] = 0
    storage[id]["incorrect"] = []
    $scope.currentPosition = storage[id]["currentPosition"]
    incorrect = storage[id]["incorrect"]
    $scope.state = "show"

  if storage[id].restart is true
    $scope.restart()
    storage[id].restart = false

  $scope.undo = () ->
    if ($scope.currentPosition > -1)
      if (incorrect.length > 0 and incorrect[incorrect.length-1] is $scope.currentPosition)
        incorrect.pop()
      $scope.currentPosition -= 1
      $scope.state = "answer"
]

app.controller "HowtoCtrl", ["$scope", '$stateParams', ($scope, $stateParams) ->
  $scope.itemId = $stateParams.itemId
]

app.controller "LearnCtrl", ["$scope", "$localStorage", "$stateParams", "$http",
"hotkeys", "HistoryService", "mobile", "$location", "storageExpiration", ($scope, storage, $stateParams, $http, hotkeys, history, mobile, $location, storageExpiration)->
  $scope.mobile = mobile
  $scope.currentPosition = 0
  $scope.state = "show"
  $scope.displayMeaning = false
  createHistory = ->
    colors = history.colors()
  colors = {}
  id = "#{$stateParams.itemId}"
  if not storage[id]?
    storage[id] = {}
    storage[id]["currentPosition"] = 0
    storage[id]["displayMeaning"] = false
  $scope.home = ->
    $location.path "/"

  $scope.jumpTo = (location) ->
    location= parseInt(location)
    if location? and location < Object.keys($scope.listToLearn).length and location > 0
      $scope.currentPosition = location - 1
      $scope.isCollapsed=true
      $scope.$apply()


  if storage[id].listToLearn? and storage.lastUpdate? and storage.lastUpdate > storageExpiration
    $scope.listToLearn = storage[id].listToLearn
    $scope.listOfMeaning = storage[id].listOfMeaning
    $scope.title = storage[id].title
    $scope.state = "show"
    colors = history.colors()
  else
    $http.get("learn/#{$stateParams.itemId}.json").success (data) ->
      $scope.listToLearn = data.listToLearn
      $scope.listOfMeaning = data.listOfMeaning
      $scope.title = data.title
      $scope.state = "show"
      colors = history.colors()

  $scope.getColor = ->
    {
      "background-color": if $scope.state is "show" then colors[$scope.currentPosition] else "#eee"
    }

  $scope.toggleMeaning = () ->
    $scope.displayMeaning = !$scope.displayMeaning

  $scope.verse = -> 
    $scope.listToLearn[$scope.currentPosition]
  $scope.meaning = -> 
    $scope.listOfMeaning[$scope.currentPosition]
  $scope.next = ->
    $scope.currentPosition += 1
  $scope.prev = ->
    $scope.currentPosition -= 1
  hotkeys.bindTo($scope)
    .add({
      combo: 'space'
      description: 'Next'
      callback: () -> $scope.next()
    })
]


app.controller "ResultsCtrl", ["$scope", "$localStorage", '$stateParams',
'$http','dateFilter',"$window", "HistoryService", ($scope, storage, $stateParams, $http,
dateFilter, $window, history) ->
  $scope.id = $stateParams.itemId
  state = storage[$scope.id]
  $scope.buttonColor = "btn-primary"
  $scope.incorrect = state.incorrect.map (id) -> {
    next: state.listToLearn[id+1]
    previous: state.listToLearn[id]
  }
  $scope.quizletText = "Export to Quizlet"
  state.restart = true
  now = new Date()
  history.add(state.incorrect)

  $scope.exportQuizlet = () ->
    if (not $scope.quizletUrl?)
      $http.post("http://amma-archana.herokuapp.com/quizlet.php", {
          "title": "#{$scope.id} - #{today()}"
          "terms": $scope.incorrect.map (term) -> term.previous
          "definitions": $scope.incorrect.map (term) -> term.next
          "lang_terms": "en"
          "lang_definitions": "en"
          "allow_discussion": 0
          "visibility": "public"
        }).success (data) ->
          $scope.buttonColor = "btn-success"
          $scope.quizletUrl = data["url"]
          $scope.quizletText = "Checkout your deck!"
        .error () ->
          $scope.buttonColor = "btn-danger"
          $scope.quizletUrl = ""
          $scope.quizletText = "Could not create deck. Mistakes will be colored in next run."
    else
      $window.open($scope.quizletUrl)

  today = () ->
    dateFilter new Date(), "MMM dd yyyy"
]

