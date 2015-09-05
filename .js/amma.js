app.directive("fullCoverImage", function() {
  return function(scope, element, attrs) {
    element.css("background-image", "url(" + attrs.fullCoverImage + ")");
    return element.addClass("full-bg");
  };
});

app.controller("ItemListerCtrl", [
  "$scope", "$http", function($scope, $http) {
    return $http.get("./learn/index.json").success(function(data) {
      return $scope.items = data;
    });
  }
]);

app.constant("storageExpiration", 1416095403068);

app.controller("TestCtrl", [
  "$scope", '$stateParams', "$location", '$localStorage', 'hotkeys', 'History', 'storageExpiration', "verses", function($scope, $stateParams, $location, storage, hotkeys, history, storageExpiration, verses) {
    var bindHotkeys, colors, defaults, id, incorrect, k, nextInLink, nextState, previousInLink, v;
    id = "" + $stateParams.itemId;
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
    defaults = {
      "currentPosition": 0,
      "displayMeaning": false,
      "incorrect": [],
      "listToLearn": verses.data.listToLearn,
      "listOfMeaning": verses.data.listOfMeaning
    };
    if (storage[id] == null) {
      storage[id] = {};
    }
    for (k in defaults) {
      v = defaults[k];
      if (storage[id][k] == null) {
        storage[id][k] = v;
      }
    }
    console.log(storage[id]);
    incorrect = storage[id]["incorrect"];
    $scope.currentPosition = storage[id]["currentPosition"] != null ? storage[id]["currentPosition"] : 0;
    $scope.displayMeaning = storage[id]["displayMeaning"];
    colors = {};
    $scope.emptyHistory = function() {
      history.clear();
      return colors = history.colors();
    };
    $scope.home = function() {
      return $location.path("/");
    };
    $scope.listToLearn = verses.data.listToLearn;
    $scope.listOfMeaning = verses.data.listOfMeaning;
    $scope.title = verses.data.title;
    $scope.state = "show";
    colors = history.colors();
    $scope.getColor = function() {
      return {
        "background-color": $scope.state === "show" ? colors[$scope.currentPosition] : void 0
      };
    };
    $scope.showAnswer = function() {
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
  "$scope", '$stateParams', function($scope, $stateParams) {
    return $scope.itemId = $stateParams.itemId;
  }
]);

app.controller("LearnCtrl", function($scope, VerseHandler, VerseLocalStorage, mobile, hotkeys, History) {
  var colors, storage;
  $scope.bg = "img/feet.jpg";
  $scope.mobile = mobile;
  $scope.displayMeaning = false;
  $scope.left = false;
  $scope.state = "show";
  $scope.toggleRightyMode = function() {
    return $scope.left = !$scope.left;
  };
  storage = VerseLocalStorage.getState();
  VerseHandler.reload();
  colors = History.colors();
  $scope.home = function() {
    return $location.path("/");
  };
  $scope.jumpTo = function(location) {
    location = parseInt(location);
    VerseHandler.setPosition(location);
    return $scope.isCollapsed = true;
  };
  $scope.getColor = function() {
    return {
      "background-color": $scope.state === "show" ? colors[VerseHandler.currentPosition] : "#eee"
    };
  };
  $scope.toggleMeaning = function() {
    return $scope.displayMeaning = !$scope.displayMeaning;
  };
  $scope.title = function() {
    return VerseHandler.getTitle();
  };
  $scope.verse = function() {
    return VerseHandler.getVerse();
  };
  $scope.meaning = function() {
    return VerseHandler.getMeaning();
  };
  $scope.next = function($event) {
    $event.stopPropagation();
    VerseHandler.next();
    return false;
  };
  $scope.prev = function($event) {
    $event.stopPropagation();
    VerseHandler.prev();
    return false;
  };
  $scope.getAudioSegmentSrc = function() {
    return VerseHandler.getAudioSegmentSrc();
  };
  return hotkeys.bindTo($scope).add({
    combo: 'space',
    description: 'Next',
    callback: function() {
      return $scope.next();
    }
  });
});

app.controller("ResultsCtrl", [
  "$scope", "$localStorage", '$stateParams', '$http', 'dateFilter', "$window", "History", function($scope, storage, $stateParams, $http, dateFilter, $window, history) {
    var now, state, today;
    $scope.id = $stateParams.itemId;
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
    now = new Date();
    history.add(state.incorrect);
    $scope.exportQuizlet = function() {
      if ($scope.quizletUrl == null) {
        return $http.post("http://amma-archana.herokuapp.com/quizlet.php", {
          "title": $scope.id + " - " + (today()),
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
