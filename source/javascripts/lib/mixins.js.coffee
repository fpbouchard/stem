# CoffeeScript Mixins, from https://github.com/jashkenas/coffee-script/wiki/Mixins
include = (classes...) ->
  for klass in classes
    # static properties
    for prop of klass
      @[prop] = klass[prop]
    # prototype properties
    for prop of klass.prototype
      getter = klass::__lookupGetter__?(prop)
      setter = klass::__lookupSetter__?(prop)

      if getter || setter
        @::__defineGetter__(prop, getter) if getter
        @::__defineSetter__(prop, setter) if setter
      else
        @::[prop] = klass::[prop]
  return this

defineProperty = Object.defineProperty
try
  Object.defineProperty({}, 'x', {}) if defineProperty?
catch error
  defineProperty = false

if defineProperty
  Object.defineProperty Function.prototype, "include", value: include
else
  Function::include = include