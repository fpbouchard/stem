#= require lib/base

Event = class CoffeeMVC.Event
  constructor: (@name) ->

Observer = class CoffeeMVC.Observer
  constructor: (@events = {}) ->

  notify: (eventAndArgs...) ->
    event = eventAndArgs[0]
    @events[event.name]?.apply @, eventAndArgs

Subject = class CoffeeMVC.Subject
  observers: []

  attach: (observer) ->
    unless observer in @observers
      @observers.push observer
      observer.notify (new Event "attached")

  notify: (event, args...) ->
    # Allow strings to be passed as events, upgrade to Event class
    event = (new Event event) if typeof event == "string"
    event.subject = @
    args.unshift event
    for observer in @observers
      observer.notify.apply observer, args
    # Return the event
    event