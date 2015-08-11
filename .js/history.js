app.constant("historyExpiration", 1409511179962);

app.factory("History", function($localStorage, $stateParams, historyExpiration) {
  var History;
  return new (History = (function() {
    function History() {
      var id;
      id = $stateParams.itemId;
      this.getHistoryData = function() {
        return $localStorage[$stateParams.itemId].historyData;
      };
      this.clear = function() {
        $localStorage.historyReset = (new Date).getTime();
        if ($localStorage[id] == null) {
          $localStorage[id] = {};
        }
        return $localStorage[id].historyData = {
          historyLength: 0,
          maxHistoryLength: 15,
          history: {}
        };
      };
      if (($localStorage[id] == null) || ($localStorage[id].historyData == null) || ($localStorage.historyReset == null) || $localStorage.historyReset < this.historyExpiration) {
        this.clear();
      }
    }

    History.prototype.add = function(listOfIncorrect) {
      var historyData, i, j, k, l, len, len1, ref, results;
      historyData = this.getHistoryData();
      historyData.historyLength += 1;
      for (k = 0, len = listOfIncorrect.length; k < len; k++) {
        i = listOfIncorrect[k];
        if (historyData.history[i] == null) {
          historyData.history[i] = 0;
        }
        historyData.history[i] += 1;
      }
      if (historyData.historyLength >= historyData.maxHistoryLength) {
        historyData.historyLength -= 1;
      }
      ref = historyData.history;
      results = [];
      for (j = l = 0, len1 = ref.length; l < len1; j = ++l) {
        i = ref[j];
        if (j > 0) {
          results.push(historyData.history[i] -= 1);
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    History.prototype.colors = function() {
      var cssColor, historyData, i, ref, wrong;
      historyData = this.getHistoryData();
      cssColor = {};
      if (historyData.historyLength > 0) {
        ref = historyData.history;
        for (i in ref) {
          wrong = ref[i];
          cssColor[i] = "hsla(" + (116 * (1 - (wrong / historyData.historyLength))) + ", 100%, 45%, .4)";
        }
      }
      return cssColor;
    };

    return History;

  })());
});
