app = angular.module("linear-learning", [
  "ngRoute"
  "ui.bootstrap"
  'ngStorage'
  'ngTouch'
  'cfp.hotkeys'
  'ngAnimate'
  'ngSanitize'
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


app.controller "ItemListerCtrl", ["$scope", "$http", ($scope, $http) ->
  $http.get("learning-items.json").success (data) ->
    $scope.items = data

  $scope.url = (id) ->
    "#/howto/#{id}"
]

app.constant "historyExpiration", 1409511179962
app.value "mobile", /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test((navigator.userAgent or navigator.vendor or window.opera)) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test((navigator.userAgent or navigator.vendor or window.opera).substr(0, 4))
app.service "HistoryService", ["$localStorage", "$routeParams", "historyExpiration", History]

app.controller "MemorizeCtrl", ["$scope", '$routeParams', '$http', "$location",
'$localStorage', 'hotkeys', 'HistoryService', ($scope, $routeParams, $http,
$location, storage, hotkeys, history) ->
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
    history.clear()
    colors = history.colors()
    $scope.$apply()

  createHistory = ->
    colors = history.colors()

  $scope.home = ->
    $location.path "/"

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

app.controller "HowtoCtrl", ["$scope", "$sessionStorage", '$routeParams', '$location', ($scope, storage, $routeParams, $location) ->
  $scope.learn = () ->
    $location.path "/learn/#{$routeParams.itemId}"
  $scope.memorize = () ->
    $location.path "/memorize/#{$routeParams.itemId}"
]

app.controller "LearnCtrl", ["$scope", "$localStorage", "$routeParams", "$http",
"hotkeys", "HistoryService", "mobile", "$location", ($scope, storage, $routeParams, $http, hotkeys, history, mobile, $location)->
  $scope.mobile = mobile
  $scope.currentPosition = 0
  $scope.state = "show"
  colors = {}
  id = "#{$routeParams.itemId}"
  if not storage[id]?
    storage[id] = {}
    storage[id]["currentPosition"] = 0
    storage[id]["displayMeaning"] = false
  $scope.home = ->
    $location.path "/"

  createHistory = ->
    colors = history.colors()

  if storage[id].listToLearn? and storage.lastUpdate? and storage.lastUpdate > 1408729273829
    $scope.listToLearn = storage[id].listToLearn
    $scope.listOfMeaning = storage[id].listOfMeaning
    $scope.title = storage[id].title
    $scope.state = "show"
    createHistory()
  else
    $http.get("learn/#{$routeParams.itemId}.json").success (data) ->
      $scope.listToLearn = data.listToLearn
      $scope.listOfMeaning = data.listOfMeaning
      $scope.title = data.title
      $scope.state = "show"
      createHistory()

  $scope.getColor = ->
    {
      "background-color": if $scope.state is "show" then colors[$scope.currentPosition] else "#eee"
    }

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


app.controller "ResultsCtrl", ["$scope", "$localStorage", '$routeParams',
'$http','dateFilter',"$window", "HistoryService", ($scope, storage, $routeParams, $http,
dateFilter, $window, history) ->
  $scope.id = "#{$routeParams.itemId}"
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

