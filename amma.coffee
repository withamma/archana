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
    storage[id]["log"] = {}
  
  storage[id]["incorrect"] = []
  $scope.currentPosition = storage[id]["currentPosition"]
  log = storage[id]["log"]
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
      storage[id]["currentPosition"] = 0

  $scope.submitAnswer = (result) ->
    if (result is "correct")
      log[$scope.currentPosition] = {
        "correct": true 
      }
    else 
      log[$scope.currentPosition] = {
        "correct": false 
      }
      incorrect.push {
        "previous": $scope.linkPrevious()
        "next": $scope.linkTest()
      }
    nextState()

  $scope.linkPrevious = () ->
    if ($scope.state isnt "loading") then $sce.trustAsHtml($scope.listToLearn[$scope.currentPosition]) else $sce.trustAsHtml("Loading")

  $scope.linkTest = () ->
    if ($scope.state is "answer") then $sce.trustAsHtml($scope.listToLearn[$scope.currentPosition + 1]) else $sce.trustAsHtml("?")

  $scope.showResults = () ->
    $location.path "results/#{id}"

  $scope.restart = () ->
    storage[id] = {}
    storage[id]["currentPosition"] = 0
    storage[id]["log"] = {}
    storage[id]["incorrect"] = []
    $scope.currentPosition = storage[id]["currentPosition"]
    log = storage[id]["log"]
    incorrect = storage[id]["incorrect"]
    $scope.state = "show"

]


app.controller "ResultsCtrl", ["$scope", "$localStorage", '$routeParams', ($scope, $localStorage, $routeParams) ->
  id = "#{$routeParams.itemId}"
  $scope.incorrect = $localStorage[id]["incorrect"]

]


