eventDescriptorPattern = ///
  ^
  (\S+) # Non-whitespace for the event name
  \s*   # Whitespace that splits the event name from the event selector
  (.*)  # event selector
  $
///

class Stem.View
  @include Stem.Events

  @bindings = (bindings) ->
    _.extend @_bindings ?= {}, bindings

  @events = (events) ->
    _.extend @_events ?= {}, events

  constructor: (attributes = {}) ->
    # Views can be initialized with attributes
    @[attribute] = value for attribute, value of attributes
    throw "Cannot bind to both a model and a collection" if @model? && @collection?
    @bindable = @model ? @collection
    @_installBindings()
    @_resolveElement()
    @_installEvents()
    # Render newly instanciated view
    @render()

  _resolveElement: ->
    return unless @el
    @el = Stem.DOM.select(@el)[0] if _.isString(@el)

  _installEvents: ->
    return unless @constructor._events? and @el?
    for eventDescriptor, handler of @constructor._events
      matches = eventDescriptor.match eventDescriptorPattern
      throw "Invalid event descriptor: \"#{eventDescriptor}\"" unless matches?
      [match, eventName, selector] = matches
      if _.isString(handler)
        throw "Undefined event callback: \"#{handler}\"" unless handler = @[handler]
      Stem.DOM.delegate @el, selector, eventName, handler

  _installBindings: ->
    return unless @constructor._bindings? && @bindable
    for eventDescriptor, handler of @constructor._bindings
      if _.isString(handler)
        throw "Undefined binding callback: \"#{handler}\"" unless handler = @[handler]
      @bindable.bind eventDescriptor, handler

  # Internal call tied to the invalidate system
  _bindableChange: =>
    # Invalidating binds only to the next model change event, unbind immediately
    @bindable.unbind "change", @_bindableChange
    # Then render the view
    @render()

  # A view can optionally bind model changes to the invalidate method. If so,
  # the view will automatically call render when all the individual model or
  # collection changes will be done. This way, one can listen to multiple
  # single-attribute changes and still re-render the view only once per call to
  # model#set.
  invalidate: =>
    # Render once all bindable updates are done
    @bindable.bind "change", @_bindableChange

  # Render is where the actual markup generation should take place. Any kind of
  # generation technique (DOM building, templating) can be used. Render should
  # return the view itself. Build on `@el`.
  render: -> this