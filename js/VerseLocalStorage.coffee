app.service "VerseLocalStorage", ($localStorage, $stateParams) ->
	@getState = ->
		if not $localStorage[$stateParams.itemId]
			$localStorage[$stateParams.itemId] = {}
		$localStorage[$stateParams.itemId]

	false
