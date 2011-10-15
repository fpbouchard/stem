#= require_self
#= require lib/mixins
#= require lib/dom
#= require lib/ajax
#= require lib/event
#= require lib/model
#= require lib/collection
#= require lib/view

window.Stem ?= {}

# Deep/shallow clones an object
Stem.clone = (obj, deep = true) ->
  if deep then JSON.parse(JSON.stringify obj) else _.clone(obj)
