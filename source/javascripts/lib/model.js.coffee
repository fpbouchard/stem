#= require lib/notifications
#= require lib/tools

class CoffeeMVC.Model extends CoffeeMVC.Subject

  @property: (path, descriptor) ->
    @properties ||= []
    @properties.push path: path, descriptor: descriptor

  installDynamicProperty: (property) ->
    # Bind the getter and setter to the instance of the model
    descriptor = {}
    for own field, value of property.descriptor
      value = value.bind(@) if typeof value == "function"
      descriptor[field] = value

    [container, key] = $path.walk property.path, @data
    Object.defineProperty container, key, descriptor

  updateDynamicProperties: (path) ->
    # If any dynamic property path is contained in the changed path, resinstall it
    (@installDynamicProperty property) for property in @constructor.properties when ($path.contains path, property.path) if @constructor.properties?

  # Build a model using an initial tree
  constructor: (@data = {}) ->
    (@installDynamicProperty property) for property in @constructor.properties if @constructor.properties?

  get: (path) ->
    $path.read path, @data

  set: (path, value) ->
    $path.write path, @data, value
    @updateDynamicProperties path
    @notify "set", path, value
    this