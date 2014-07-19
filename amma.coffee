app = angular.module("linear-learning", [
  "ngRoute"
  "ui.bootstrap"
  'ngStorage'
  'ngTouch'
])

app.config(($routeProvider) ->
  $routeProvider.when("/",
    controller: "ItemListerCtrl"
    templateUrl: "templates/item-lister.template.html"
  ).when("/memorize/:itemId",
    controller: "MemorizeCtrl"
    templateUrl: "templates/test.template.html"
  ).when("/howto/:itemId",
    controller: "HowtoCtrl"
    templateUrl: "templates/howto.template.html"
  ).when("/results/:itemId",
    controller: "ResultsCtrl"
    templateUrl: "templates/results.template.html"
  ).otherwise redirectTo: "/")


app.controller "NavBarCtrl", ["$scope", ($scope) -> 
  $scope.isCollapsed = true
]

app.controller "ItemListerCtrl", ["$scope", "$http", "$sessionStorage", ($scope, $http, sessionStorage) ->
  $http.get("learning-items.json").success (data) ->
    $scope.items = data
  $scope.url = (id) ->
    if (sessionStorage["howtoCompleted"]?) then "#/memorize/#{id}" else "#/howto/#{id}"
  # wakeup sleeing heroku
  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")
]
 
app.controller "MemorizeCtrl", ["$scope", '$routeParams', '$http', "$location", '$localStorage', ($scope, $routeParams, $http, $location, storage) ->
  id = "#{$routeParams.itemId}"
  $scope.state = "loading"

  # wakeup sleeing heroku
  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")

  if not storage[id]?
    storage[id] = {}
    storage[id]["currentPosition"] = 0
  
  storage[id]["incorrect"] = []
  $scope.currentPosition = storage[id]["currentPosition"]
  incorrect = storage[id]["incorrect"]

  $http.get("learn/#{$routeParams.itemId}.json").success (data) ->
    $scope.listToLearn = data.list
    $scope.title = data.title
    $scope.state = "show"
  
  $scope.showAnswer = () ->
    $scope.state = "answer"

  nextState = () ->
    if $scope.currentPosition + 2 < $scope.listToLearn.length
      $scope.currentPosition += 1
      storage[id]["currentPosition"] = $scope.currentPosition
      $scope.state = "show"
    else
      $scope.state = "end"
      new Audio("sounds/3oms.mp3").play()
      storage[id]["currentPosition"] = 0

  $scope.submitAnswer = (result) ->
    if (result isnt "correct")
      incorrect.push {
        "previous": previousInLink()
        "next": nextInLink()
        "id": $scope.currentPosition
      }
    nextState()

  previousInLink = () ->
    $scope.listToLearn[$scope.currentPosition]

  nextInLink = () ->
    $scope.listToLearn[$scope.currentPosition + 1]

  $scope.linkPrevious = () ->
    if ($scope.state isnt "loading") then previousInLink() else "Loading"

  $scope.linkTest = () ->
    if ($scope.state is "answer") then nextInLink() else "?"

  $scope.showResults = () ->
    $location.path "results/#{id}"

  $scope.restart = () ->
    storage[id] = {}
    storage[id]["currentPosition"] = 0
    storage[id]["incorrect"] = []
    $scope.currentPosition = storage[id]["currentPosition"]
    incorrect = storage[id]["incorrect"]
    $scope.state = "show"

  $scope.undo = () ->
    if ($scope.currentPosition isnt 0)
      if (incorrect.length > 0 and incorrect[incorrect.length-1].id is $scope.currentPosition)
        incorrect.pop()
      $scope.currentPosition -= 1
]

app.controller "HowtoCtrl", ["$scope", "$sessionStorage", '$routeParams', '$location', ($scope, storage, $routeParams, $location) ->
  $scope.continue = () ->
    storage["howtoCompleted"] = true
    $location.path "/memorize/#{$routeParams.itemId}"
]

app.controller "ResultsCtrl", ["$scope", "$localStorage", '$routeParams', '$http','dateFilter',"$window", ($scope, storage, $routeParams, $http, dateFilter, $window) ->
  $scope.id = "#{$routeParams.itemId}"
  $scope.buttonColor = "btn-primary"
  $scope.incorrect = storage[$scope.id]["incorrect"]
  $scope.quizletText = "Export to Quizlet"

  $http.get("http://amma-archana.herokuapp.com/page-does-not-exist")
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
          console.log data
          $scope.buttonColor = "btn-success"
          $scope.quizletUrl = data["url"]
          $scope.quizletText = "Checkout your deck!"
          console.log data["url"]
        .error () ->
          $scope.buttonColor = "btn-danger"
          $scope.quizletUrl = ""
          $scope.quizletText = "Could not create deck. Please copy result and learn on your own."
    else
      $window.open($scope.quizletUrl)

  today = () ->
    dateFilter new Date(), "MMM dd yyyy"
]


