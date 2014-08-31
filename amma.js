// Generated by CoffeeScript 1.7.1
var app;

app = angular.module("linear-learning", ["ngRoute", "ui.bootstrap", 'ngStorage', 'ngTouch', 'cfp.hotkeys', 'ngAnimate']);

app.directive("fullCoverImage", function() {
  return function(scope, element, attrs) {
    element.css("background-image", "url(" + attrs.fullCoverImage + ")");
    return element.addClass("full-bg");
  };
});

app.config(function($routeProvider) {
  return $routeProvider.when("/", {
    controller: "ItemListerCtrl",
    templateUrl: "templates/item-lister.template.html"
  }).when("/memorize/:itemId", {
    controller: "MemorizeCtrl",
    templateUrl: "templates/test.template.html"
  }).when("/howto/:itemId", {
    controller: "HowtoCtrl",
    templateUrl: "templates/howto.template.html"
  }).when("/results/:itemId", {
    controller: "ResultsCtrl",
    templateUrl: "templates/results.template.html"
  }).otherwise({
    redirectTo: "/"
  });
});

app.controller("ItemListerCtrl", [
  "$scope", "$http", "$sessionStorage", function($scope, $http, sessionStorage) {
    $http.get("learning-items.json").success(function(data) {
      return $scope.items = data;
    });
    $scope.url = function(id) {
      if ((sessionStorage["howtoCompleted"] != null)) {
        return "#/memorize/" + id;
      } else {
        return "#/howto/" + id;
      }
    };
    return $http.get("http://amma-archana.herokuapp.com/page-does-not-exist");
  }
]);

app.controller("MemorizeCtrl", [
  "$scope", '$routeParams', '$http', "$location", '$localStorage', 'hotkeys', function($scope, $routeParams, $http, $location, storage, hotkeys) {
    var bindHotkeys, colors, createHistory, id, incorrect, nextInLink, nextState, previousInLink;
    id = "" + $routeParams.itemId;
    $scope.state = "loading";
    $scope.hint = false;
    bindHotkeys = function() {
      return hotkeys.bindTo($scope).add({
        combo: 'u',
        description: 'Undo',
        callback: function() {
          return $scope.undo();
        }
      }).add({
        combo: 'c',
        description: 'Correct answer',
        callback: function() {
          return $scope.submitAnswer("correct");
        }
      }).add({
        combo: 'x',
        description: 'Wrong answer',
        callback: function() {
          return $scope.submitAnswer("incorrect");
        }
      }).add({
        combo: 'r',
        description: 'Restart',
        callback: function() {
          return $scope.restart();
        }
      }).add({
        combo: 's',
        description: 'Show Answer',
        callback: function() {
          return $scope.showAnswer();
        }
      }).add({
        combo: 'space',
        description: 'Show Answer',
        callback: function() {
          return $scope.showAnswer();
        }
      }).add({
        combo: 'm',
        description: 'Show Meaning',
        callback: function() {
          return $scope.toggleMeaning();
        }
      }).add({
        combo: 'h',
        description: 'Show Hint',
        callback: function() {
          return $scope.showHint();
        }
      }).add({
        combo: 'e',
        description: 'Empty History',
        callback: function() {
          return $scope.emptyHistory();
        }
      });
    };
    bindHotkeys();
    $http.get("http://amma-archana.herokuapp.com/page-does-not-exist");
    if (storage[id] == null) {
      storage[id] = {};
      storage[id]["currentPosition"] = 0;
      storage[id]["displayMeaning"] = false;
      storage[id]["incorrect"] = [];
    }
    incorrect = storage[id]["incorrect"];
    $scope.currentPosition = storage[id]["currentPosition"];
    $scope.displayMeaning = storage[id]["displayMeaning"];
    colors = {};
    $scope.emptyHistory = function() {
      var history, i, _i, _ref;
      storage.historyReset = (new Date).getTime();
      storage[id].historyData = {
        historyLength: 0,
        maxHistoryLength: 15,
        history: {}
      };
      for (i = _i = 0, _ref = $scope.listToLearn.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        storage[id].historyData.history[i] = 0;
      }
      history = new History(storage[id].historyData);
      colors = history.colors();
      return $scope.$apply();
    };
    createHistory = function() {
      var history;
      if ((storage[id].historyData == null) || (storage.historyReset == null) || storage.historyReset < 1409511179962) {
        $scope.emptyHistory();
      }
      history = new History(storage[id].historyData);
      return colors = history.colors();
    };
    if ((storage[id].listToLearn != null) && (storage.lastUpdate != null) && storage.lastUpdate > 1408729273829) {
      $scope.listToLearn = storage[id].listToLearn;
      $scope.listOfMeaning = storage[id].listOfMeaning;
      $scope.title = storage[id].title;
      $scope.state = "show";
      createHistory();
    } else {
      $http.get("learn/" + $routeParams.itemId + ".json").success(function(data) {
        storage.lastUpdate = (new Date).getTime();
        storage[id].listToLearn = data.listToLearn;
        storage[id].listOfMeaning = data.listOfMeaning;
        storage[id].title = data.title;
        $scope.listToLearn = data.listToLearn;
        $scope.listOfMeaning = data.listOfMeaning;
        $scope.title = data.title;
        $scope.state = "show";
        return createHistory();
      });
    }
    $scope.getColor = function() {
      return {
        "color": colors[$scope.currentPosition]
      };
    };
    $scope.showAnswer = function() {
      console.log($scope.currentPosition + 2 < $scope.listToLearn.length);
      if ($scope.state === "end") {
        $location.path("results/" + id);
      }
      return $scope.state = "answer";
    };
    $scope.toggleMeaning = function() {
      return $scope.displayMeaning = !$scope.displayMeaning;
    };
    nextState = function() {
      $scope.hint = false;
      if ($scope.currentPosition + 2 < $scope.listToLearn.length) {
        $scope.currentPosition += 1;
        storage[id]["currentPosition"] = $scope.currentPosition;
        return $scope.state = "show";
      } else {
        return $scope.state = "end";
      }
    };
    $scope.showHint = function() {
      return $scope.hint = true;
    };
    $scope.getHint = function() {
      if ($scope.state === "show") {
        return nextInLink().slice(0, 15);
      } else {
        return "";
      }
    };
    $scope.submitAnswer = function(result) {
      if ($scope.state === "answer") {
        if (result !== "correct") {
          incorrect.push($scope.currentPosition);
        }
        return nextState();
      }
    };
    previousInLink = function(meaning) {
      if ((meaning != null)) {
        return $scope.listOfMeaning[$scope.currentPosition];
      } else {
        return $scope.listToLearn[$scope.currentPosition];
      }
    };
    nextInLink = function(meaning) {
      if ((meaning != null)) {
        return $scope.listOfMeaning[$scope.currentPosition + 1];
      } else {
        return $scope.listToLearn[$scope.currentPosition + 1];
      }
    };
    $scope.linkPrevious = function() {
      if ($scope.state !== "loading") {
        return previousInLink();
      } else {
        return "Loading";
      }
    };
    $scope.linkTest = function() {
      if ($scope.state === "loading") {
        return "Loading";
      } else if ($scope.state === "answer") {
        return nextInLink();
      } else {
        return previousInLink();
      }
    };
    $scope.meaning = function() {
      if ($scope.state === "loading") {
        return "Loading";
      } else if ($scope.state === "answer") {
        return nextInLink(true);
      } else {
        return previousInLink(true);
      }
    };
    $scope.showResults = function() {
      return $location.path("results/" + id);
    };
    $scope.restart = function() {
      storage[id]["currentPosition"] = 0;
      storage[id]["incorrect"] = [];
      $scope.currentPosition = storage[id]["currentPosition"];
      incorrect = storage[id]["incorrect"];
      return $scope.state = "show";
    };
    if (storage[id].restart === true) {
      $scope.restart();
      storage[id].restart = false;
    }
    return $scope.undo = function() {
      if ($scope.currentPosition > -1) {
        if (incorrect.length > 0 && incorrect[incorrect.length - 1] === $scope.currentPosition) {
          incorrect.pop();
        }
        $scope.currentPosition -= 1;
        return $scope.state = "answer";
      }
    };
  }
]);

app.controller("HowtoCtrl", [
  "$scope", "$sessionStorage", '$routeParams', '$location', function($scope, storage, $routeParams, $location) {
    return $scope["continue"] = function() {
      storage["howtoCompleted"] = true;
      return $location.path("/memorize/" + $routeParams.itemId);
    };
  }
]);

app.controller("ResultsCtrl", [
  "$scope", "$localStorage", '$routeParams', '$http', 'dateFilter', "$window", function($scope, storage, $routeParams, $http, dateFilter, $window) {
    var history, now, state, today;
    $scope.id = "" + $routeParams.itemId;
    state = storage[$scope.id];
    $scope.buttonColor = "btn-primary";
    $scope.incorrect = state.incorrect.map(function(id) {
      return {
        next: state.listToLearn[id + 1],
        previous: state.listToLearn[id]
      };
    });
    $scope.quizletText = "Export to Quizlet";
    state.restart = true;
    $http.get("http://amma-archana.herokuapp.com/page-does-not-exist");
    now = new Date();
    history = new History(state.historyData);
    history.add(state.incorrect);
    $scope.exportQuizlet = function() {
      if ($scope.quizletUrl == null) {
        return $http.post("http://amma-archana.herokuapp.com/quizlet.php", {
          "title": "" + $scope.id + " - " + (today()),
          "terms": $scope.incorrect.map(function(term) {
            return term.previous;
          }),
          "definitions": $scope.incorrect.map(function(term) {
            return term.next;
          }),
          "lang_terms": "en",
          "lang_definitions": "en",
          "allow_discussion": 0,
          "visibility": "public"
        }).success(function(data) {
          $scope.buttonColor = "btn-success";
          $scope.quizletUrl = data["url"];
          return $scope.quizletText = "Checkout your deck!";
        }).error(function() {
          $scope.buttonColor = "btn-danger";
          $scope.quizletUrl = "";
          return $scope.quizletText = "Could not create deck. Mistakes will be colored in next run.";
        });
      } else {
        return $window.open($scope.quizletUrl);
      }
    };
    return today = function() {
      return dateFilter(new Date(), "MMM dd yyyy");
    };
  }
]);
