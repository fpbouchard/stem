# Events
# ======
#
# *Stem.Events* is a *mixin* that allows objects to trigger events and allow other object to bind and unbind from them.
#
# As is defined in [mixins.js.coffee](mixins.js.html), the `@include` class method should be used to implement the mixin:
#
#     class MyEventableClass
#       @include Stem.Events
#
# Event Descriptors
# =================
#
# The event descriptors used in `bind` and `unbind` are, simply put, comma-separated event names that are a shortcut to binding multiple events to the same handler.
# For example, given this handler:
#
#     handler = (context, newValue) -> console.log newValue
#
# Calling this:
#
#     context.bind "change:mode, change:state", handler
#
# Is the same as calling this:
#
#     context.bind "change:mode", handler
#     context.bind "change:state", handler

# Regexp to split event descriptors
eventDescriptorSplitter = ///
  ,    # Comma
  \s*  # then zero or more spaces
///

# Event class
class Stem.Events
  # Bind a handler to events triggered by this object. Registering the same
  # event/handler twice will not fail, but will be silently ignored.
  bind: (eventDescriptor, handler) ->
    # Lazy init the `@bindings` instance variable
    @bindings ?= {}
    events = eventDescriptor.split eventDescriptorSplitter
    # Bind every event in the descriptor individually
    for event in events
      # Lazy init the handler array for this event
      handlers = @bindings[event] ?= []
      # Do not register the same event/handler combination twice, just ignore
      handlers.push handler unless handler in handlers
    this

  # Unbinds a specific event/handler combination.
  unbind: (eventDescriptor, handler) ->
    # Bail out if nothing was ever bound
    return this unless @bindings?
    events = eventDescriptor.split eventDescriptorSplitter
    # Unbind every event in the descriptor individually
    for event in events
      handlers = @bindings[event]
      handlers.splice index, 1 if handlers? and (index = _.indexOf(handlers, handler)) >= 0
    this

  # Trigger an event with an optional number of arguments
  trigger: (event, args...) ->
    # Bail out if nothing has ever bound to this object
    return this unless @bindings?
    # Handlers for all events
    if (handlers = @bindings["*"])?
      # Call with full argument list so the "*" handlers can get the actual event
      (handler.apply this, arguments) for handler in handlers
    # Handlers for this specific event
    if (handlers = @bindings[event])?
      (handler.apply this, args) for handler in handlers
    this