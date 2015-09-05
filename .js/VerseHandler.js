app.factory("VerseHandler", function(LocalVerseData, VerseLocalStorage) {
  var VerseHandler;
  return new (VerseHandler = (function() {
    function VerseHandler() {}

    VerseHandler.prototype.reload = function() {
      LocalVerseData.verses.then((function(_this) {
        return function(data) {
          _this.verses = data.listToLearn;
          _this.meanings = data.listOfMeaning;
          _this.title = data.title;
          _this.length = Object.keys(_this.verses).length;
          _this.audioURL = data.audioURL ? data.audioURL + "#t=" : void 0;
          return _this.audioTimes = data.audioTimes;
        };
      })(this));
      this.state = VerseLocalStorage.getState();
      if (this.state.currentPosition == null) {
        this.state.currentPosition = 0;
      }
      this.hasNext = function() {
        if (this.state.currentPosition + 2 <= this.length) {
          return true;
        } else {
          return false;
        }
      };
      this.getTitle = function() {
        return this.title;
      };
      this.hasPrev = function() {
        if (this.state.currentPosition > -1) {
          return true;
        } else {
          return false;
        }
      };
      this.next = function() {
        if (this.hasNext()) {
          return this.state.currentPosition += 1;
        }
      };
      this.prev = function() {
        if (this.hasPrev()) {
          return this.state.currentPosition -= 1;
        }
      };
      this.getVerse = function() {
        return this.verses[this.state.currentPosition];
      };
      this.getMeaning = function() {
        return this.meanings[this.state.currentPosition];
      };
      this.getAudioSegmentSrc = function() {
        var time;
        if (this.audioURL) {
          time = this.audioTimes[this.state.currentPosition];
          return this.audioURL + time;
        }
      };
      this.peekNextVerse = function() {
        if (this.hasNext()) {
          return this.verses[this.state.currentPosition + 1];
        }
      };
      this.peekNextMeaning = function() {
        if (this.hasNext()) {
          return this.meanings[this.state.currentPosition + 1];
        }
      };
      return this.setPosition = function(location) {
        if (location != null) {
          location = parseInt(location);
        }
        if (angular.isNumber(location && location < this.length && location > -1)) {
          return this.state.currentPosition = location;
        }
      };
    };

    return VerseHandler;

  })());
});
