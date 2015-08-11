app.service "LocalVerseData", ($http, $stateParams, $q) ->
	deffered = $q.defer()
	audioDeffered = $q.defer()
	$http.get("learn/#{$stateParams.itemId}.json").success (data) ->
		deffered.resolve(data)
	@verses = deffered.promise
	true
