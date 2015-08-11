app = angular.module("linear-learning", [
  "ui.router"
  "ui.bootstrap"
  'ngStorage'
  'ngTouch'
  'cfp.hotkeys'
  # 'ngAnimate'
  'ngSanitize'
  'angulartics'
  'angulartics.google.analytics'
])

app.config ["$stateProvider", "$urlRouterProvider", ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'
  $stateProvider.state("contentIndex",
    url: "/",
    controller: "ItemListerCtrl"
    templateUrl: "templates/item-lister.template.html"
  ).state("test",
    url: "/test/:itemId",
    controller: "TestCtrl"
    templateUrl: "templates/test.template.html"
    resolve: 
      # this should be anotated - minifying will be a disaster
      verses: ($http, $stateParams) -> 
        $http.get("learn/#{$stateParams.itemId}.json")   
  ).state("learn",
    url: "/learn/:itemId",
    controller: "LearnCtrl"
    templateUrl: "templates/learn.template.html"
    resolve: 
      # this should be anotated - minifying will be a disaster
      verses: ($http, $stateParams) -> 
        $http.get("learn/#{$stateParams.itemId}.json")
  ).state("howto",
    url: "/howto/:itemId",
    controller: "HowtoCtrl"
    templateUrl: "templates/howto.template.html"
  ).state("results",
    url: "/results/:itemId",
    controller: "ResultsCtrl"
    templateUrl: "templates/results.template.html"
  )
]