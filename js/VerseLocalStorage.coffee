app.service "VerseLocalStorage", ($localStorage, $stateParams) ->
	@getState = -> $localStorage[$stateParams.itemId]
	false