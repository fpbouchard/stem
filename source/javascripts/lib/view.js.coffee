delegateDescriptorPattern = ///
  (\S+) # Non-whitespace for the event name
  \s+   # Whitespace that splits the event name from the delegate selector
  (.+)  # Delegate selector
///

class CoffeeMVC.View
  @implements CoffeeMVC.Events

  constructor: (attributes = {}) ->
    # Views can be initialized with attributes
    @[attribute] = value for attribute, value of attributes
    @_resolveElement()
    @_installDelegates()

  _resolveElement: ->
    return unless @el
    @el = CoffeeMVC.DOM.select(@el)[0] if _.isString(@el)

  _installDelegates: ->
    return unless @delegates
    for delegateDescriptor, handler of @delegates
      matches = delegateDescriptor.match delegateDescriptorPattern
      throw "Invalid delegate descriptor: \"#{delegateDescriptor}\"" unless matches?
      [match, eventName, selector] = matches
      CoffeeMVC.DOM.delegate @el, selector, eventName, _.bind(handler, this)

  # Internal call tied to the invalidate system
  _modelChange: =>
    # Invalidating binds only to the next model change event, unbind immediately
    @model.unbind "change", @_modelChange
    # Then render the view
    @render()

  # A view can optionally bind model changes to the invalidate method. If so,
  # the view will automatically call render when all the individual model
  # changes will be done. This way, one can listen to multiple single-attribute
  # changes and still re-render the view only once per call to model#set.
  invalidate: =>
    # Render once all model updates are done
    @model.bind "change", @_modelChange

  # Render is where the actual markup generation should take place. Any kind of
  # generation technique (DOM building, templating) can be used. Render should
  # return the view itself.
  render: -> this