app.service "LocalVerseData", ($http, $stateParams, $q) ->
	@reload = =>
		deffered = $q.defer()
		@verses = deffered.promise
		audioDeffered = $q.defer()
		$http.get("learn/#{$stateParams.itemId}.json").success (data) ->
			deffered.resolve(data)
	true
