# Models
# ======
#
# **Models** hold data and binds **events** to change in data.
#
# **Model** subclasses can define their default attributes in their class definition by setting the `defaults` property.
#
# Ex.:
#
#     class Context extends Model
#       defaults
#         mode: "standard"
#
#     context = new Context
#     expect(context.get "mode").toEqual "standard"
#
class Stem.Model
  @include Stem.Events

  # The **Model** constructor also allows to set initial attributes in the model by passing the hash directly:
  #
  #     context = new Context
  #       mode: "extended"
  #
  #     expect(context.get "mode").toEqual "extended"
  #
  # Note that attributes passed at instanciation win over default, class-level values.
  #
  constructor: (@attributes = {}) ->
    _.defaults(@attributes, Stem.clone(@defaults)) if @defaults

  # Get an attribute's value, by its key.
  get: (attribute) ->
    @attributes[attribute]

  # Set attributes.
  set: (attributes) ->
    # Prevent the frequent API error of trying to call set with an array of parameters like `set "key", "value"`
    throw "Illegal attributes argument, expecting object" if _.isString(attributes)

    changes = []

    # Prevent reentrancy of the global change event (see below)
    wasChanging = @_changing
    @_changing = true

    # Allow hooks to sanitize/handle changes before they are committed
    @beforeSet attributes if @beforeSet?

    for key, value of attributes
      # Only *changed* attributes set in the `attributes` hash will be actually changed. The comparison is done using [underscore.js](http://documentcloud.github.com/underscore/)'s `isEqual` method.
      unless _.isEqual @attributes[key], value
        # Remember that this attribute changed
        changes.push key
        # Change it in the model
        @attributes[key] = value
        # Trigger a *specific* change event
        @trigger "change:#{key}", this, key, value

    # Avoid triggering multiple global "change" events. This way, if an event
    # handler further changes the model, this ensures that only one global
    # "change" event will be fired at the end of the scope of the first change.
    if !wasChanging
      # Trigger the *global* change event. Only trigger change if any passed attribute actually changed
      @trigger "change", this, changes if changes.length > 0
      # Leave the global _changing flag on until the scope of the first change
      # wraps up (hence this line's enclosing in the `!wasChanging` condition)
      @_changing = false

    this

  snapshot: () ->
    @currentSnapshot = Stem.clone(@attributes)

  restore: (attrs...) ->
    attrs = _.flatten attrs
    restoreValues = {}
    restoreValues[attr] = @currentSnapshot[attr] for attr in attrs
    @set restoreValues