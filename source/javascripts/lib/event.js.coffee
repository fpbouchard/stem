# Events
# ======
#
# *Stem.Events* is a *mixin* that allows objects to trigger events and allow other object to bind and unbind from them.
#
# As is defined in [base.js.coffee](base.js.html), the `@implements` class method should be used to implement the mixin:
#
#     class MyEventableClass
#       @implements Stem.Events
#
# Event Descriptors
# =================
#
# The event descriptors used in `bind` and `unbind` are, simply put, comma-separated event names that are a shortcut to binding multiple events to the same callback.
# For example, given this callback:
#
#     callback = (context, newValue) -> console.log newValue
#
# Calling this:
#
#     context.bind "change:mode, change:state", callback
#
# Is the same as calling this:
#
#     context.bind "change:mode", callback
#     context.bind "change:state", callback

# Regexp to split event descriptors
eventDescriptorSplitter = ///
  ,    # Comma
  \s*  # then zero or more spaces
///

# Event class
class Stem.Events
  # Bind a callback to events triggered by this object. Registering the same
  # event/callback twice will not fail, but will be silently ignored.
  bind: (eventDescriptor, callback) ->
    # Lazy init the `@bindings` instance variable
    @bindings ||= {}
    events = eventDescriptor.split eventDescriptorSplitter
    # Bind every event in the descriptor individually
    for event in events
      # Lazy init the callback array for this event
      callbacks = @bindings[event] ||= []
      # Do not register the same event/callback combination twice, just ignore
      callbacks.push callback if callbacks.indexOf(callback) < 0
    this

  # Unbinds a specific event/callback combination.
  unbind: (eventDescriptor, callback) ->
    # Bail out if nothing was ever bound
    return this unless @bindings?
    events = eventDescriptor.split eventDescriptorSplitter
    # Unbind every event in the descriptor individually
    for event in events
      callbacks = @bindings[event]
      callbacks.splice index, 1 if callbacks? and (index = callbacks.indexOf callback) >= 0
    this

  # Trigger an event with an optional number of arguments
  trigger: (event, args...) ->
    # Bail out if nothing is bound to this event
    return this unless @bindings? && (callbacks = @bindings[event])?
    (callback.apply this, args) for callback in callbacks
    this