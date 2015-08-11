app.directive('animateOnChange', function($animate, $compile) {
  var watchers;
  watchers = {};
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      watchers[scope.$id] && watchers[scope.$id]();
      return watchers[scope.$id] = scope.$watch(attrs.animateOnChange, function(newValue, oldValue) {
        if (newValue !== oldValue) {
          $animate.enter($compile(element.clone())(scope), element.parent(), element);
          element.html(oldValue);
          return $animate.leave(element);
        }
      });
    }
  };
});
