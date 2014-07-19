app = angular.module("linear-learning", [
  "ngRoute"
  "ngFitText"
  "ui.bootstrap"
  'ngStorage'
])

app.config(($routeProvider) ->
  $routeProvider.when("/",
    controller: "ItemListerCtrl"
    templateUrl: "item-lister.template"
  ).when("/memorize/:itemId",
    controller: "MemorizeCtrl"
    templateUrl: "test.template"
  ).when("/results/:itemId",
    controller: "ResultsCtrl"
    templateUrl: "results.template"
  ).otherwise redirectTo: "/")


app.controller "NavBarCtrl", ["$scope", ($scope) -> 
  $scope.isCollapsed = true
]

app.controller "ItemListerCtrl", ["$scope", "$http", ($scope, $http) ->
  $http.get("learning-items.json").success (data) ->
    $scope.items = data
]
 
app.controller "MemorizeCtrl", ["$scope", '$routeParams', '$http', "$location", '$localStorage', '$sce', ($scope, $routeParams, $http, $location, storage, $sce) ->
  id = "#{$routeParams.itemId}"
  $scope.state = "loading"

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
      new Audio("sounds/victory_fanfare.mp3").play()
      storage[id]["currentPosition"] = 0

  $scope.submitAnswer = (result) ->
    if (result isnt "correct")
      incorrect.push {
        "previous": previousInLink()
        "next": nextInLink()
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
]

app.controller "ResultsCtrl", ["$scope", "$localStorage", '$routeParams', '$http','dateFilter',"$window", ($scope, storage, $routeParams, $http, dateFilter, $window) ->
  $scope.id = "#{$routeParams.itemId}"
  $scope.buttonColor = "btn-primary"
  $scope.incorrect = storage[$scope.id]["incorrect"]
  $scope.quizletText = "Export to Quizlet"
  $scope.exportQuizlet = () ->
    if (not $scope.quizletUrl?)
      $http.post("quizlet.php?", {
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


