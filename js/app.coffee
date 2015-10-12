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
  'rzModule'
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
  ).state("learn",
    url: "/learn/:itemId",
    controller: "LearnCtrl"
    templateUrl: "templates/learn.template.html"
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
