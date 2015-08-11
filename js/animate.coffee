app.directive 'animateOnChange', ($animate, $compile) ->
  watchers = {}
  {
    restrict: 'A'
    link: (scope, element, attrs) ->
      watchers[scope.$id] and watchers[scope.$id]()
      # deregister $watch er if one already exists 
      watchers[scope.$id] = scope.$watch(attrs.animateOnChange, (newValue, oldValue) ->
        if newValue != oldValue
          $animate.enter $compile(element.clone())(scope), element.parent(), element
          element.html oldValue
          $animate.leave element
      )
  }
