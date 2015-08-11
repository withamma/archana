app.service("LocalVerseData", function($http, $stateParams, $q) {
  var audioDeffered, deffered;
  deffered = $q.defer();
  audioDeffered = $q.defer();
  $http.get("learn/" + $stateParams.itemId + ".json").success(function(data) {
    return deffered.resolve(data);
  });
  this.verses = deffered.promise;
  return true;
});
