app = angular.module("linear-learning", [
  "ngRoute"
  "ui.bootstrap"
  'ngStorage'
  'ngTouch'
  'cfp.hotkeys'
  'ngAnimate'
])

app.directive "fullCoverImage", ->
  (scope, element, attrs) ->
    element.css "background-image", "url(#{attrs.fullCoverImage})"
    element.addClass "full-bg"


app.config(($routeProvider) ->
  $routeProvider.when("/",
    controller: "ItemListerCtrl"
    templateUrl: "templates/item-lister.template.html"
  ).when("/memorize/:itemId",
    controller: "MemorizeCtrl"
    templateUrl: "templates/test.template.html"
  ).when("/learn/:itemId",
    controller: "LearnCtrl"
    templateUrl: "templates/learn.template.html"
  ).when("/howto/:itemId",
    controller: "HowtoCtrl"
    templateUrl: "templates/howto.template.html"
  ).when("/results/:itemId",
    controller: "ResultsCtrl"
    templateUrl: "templates/results.template.html"
  ).otherwise redirectTo: "/")


app.controller "ItemListerCtrl", ["$scope", "$http", "$sessionStorage", ($scope, $http, sessionStorage) ->
  $http.get("learning-items.json").success (data) ->
    $scope.items = data

  $scope.url = (id) ->
    if (sessionStorage["howtoCompleted"]?) then "#/memorize/#{id}" else "#/howto/#{id}"
  # wakeup sleeing heroku
  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")
]

app.controller "MemorizeCtrl", ["$scope", '$routeParams', '$http', "$location", '$localStorage', 'hotkeys', ($scope, $routeParams, $http, $location, storage, hotkeys) ->
  id = "#{$routeParams.itemId}"
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
  # wakeup sleeing heroku
  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")

  if not storage[id]?
    storage[id] = {}
    storage[id]["currentPosition"] = 0
    storage[id]["displayMeaning"] = false
    storage[id]["incorrect"] = []

  incorrect = storage[id]["incorrect"]
  $scope.currentPosition = storage[id]["currentPosition"]
  $scope.displayMeaning = storage[id]["displayMeaning"]
  colors = {}
  $scope.emptyHistory = ->
    storage.historyReset = (new Date).getTime()
    storage[id].historyData = {
      historyLength: 0
      maxHistoryLength: 15
      history: {}
    }
    for i in [0...$scope.listToLearn.length]
      storage[id].historyData.history[i] = 0
    history = new History(storage[id].historyData)
    colors = history.colors()
    $scope.$apply()

  createHistory = ->
    if not storage[id].historyData? or not storage.historyReset? or storage.historyReset < 1409511179962
      $scope.emptyHistory()
    history = new History(storage[id].historyData)
    colors = history.colors()

  if storage[id].listToLearn? and storage.lastUpdate? and storage.lastUpdate > 1408729273829
    $scope.listToLearn = storage[id].listToLearn
    $scope.listOfMeaning = storage[id].listOfMeaning
    $scope.title = storage[id].title
    $scope.state = "show"
    createHistory()

  else
    $http.get("learn/#{$routeParams.itemId}.json").success (data) ->
      storage.lastUpdate = (new Date).getTime()
      storage[id].listToLearn = data.listToLearn
      storage[id].listOfMeaning = data.listOfMeaning
      storage[id].title = data.title
      $scope.listToLearn = data.listToLearn
      $scope.listOfMeaning = data.listOfMeaning
      $scope.title = data.title
      $scope.state = "show"
      createHistory()


  $scope.getColor = ->
    {
      "color": if $scope.state is "show" then colors[$scope.currentPosition] else "#eee"
    }


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

app.controller "HowtoCtrl", ["$scope", "$sessionStorage", '$routeParams', '$location', ($scope, storage, $routeParams, $location) ->
  $scope.continue = () ->
    storage["howtoCompleted"] = true
    $location.path "/memorize/#{$routeParams.itemId}"
]

app.controller "LearnCtrl", ["$scope", "$localStorage", "$routeParams", "$http", "hotkeys", ($scope, storage, $routeParams, $http, hotkeys)->
  $scope.currentPosition = 0
  $scope.state = "show"
  $http.get("learn/#{$routeParams.itemId}.json").success (data) ->
    $scope.listToLearn = data.listToLearn
    $scope.listOfMeaning = data.listOfMeaning
    $scope.title = data.title
  $scope.verse = -> 
    $scope.listToLearn[$scope.currentPosition]
  $scope.meaning = -> 
    $scope.listOfMeaning[$scope.currentPosition]
  $scope.next = () ->
    $scope.currentPosition += 1
  hotkeys.bindTo($scope)
    .add({
      combo: 'space'
      description: 'Next'
      callback: () -> $scope.next()
    })

]


app.controller "ResultsCtrl", ["$scope", "$localStorage", '$routeParams', '$http','dateFilter',"$window", ($scope, storage, $routeParams, $http, dateFilter, $window) ->
  $scope.id = "#{$routeParams.itemId}"
  state = storage[$scope.id]
  $scope.buttonColor = "btn-primary"
  $scope.incorrect = state.incorrect.map (id) -> {
    next: state.listToLearn[id+1]
    previous: state.listToLearn[id]
  }
  $scope.quizletText = "Export to Quizlet"
  state.restart = true
  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")
  now = new Date()
  history = new History(state.historyData)
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

