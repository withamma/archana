app.service("VerseLocalStorage", function($localStorage, $stateParams) {
  this.getState = function() {
    return $localStorage[$stateParams.itemId];
  };
  return false;
});
