"use strict"

module.exports = (document) ->
	return {
		reload: ->
			document.location.reload()
		getHash: ->
			return document.location.hash
		setHash: (newHash) ->
			document.location.hash = newHash
		changeHref: (newLocation) ->
			document.location.href = newLocation
	}