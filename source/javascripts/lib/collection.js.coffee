class Stem.Collection
  @include Stem.Events

  constructor: (models...) ->
    @models = []
    @add models if models.length > 0

  model: (attributes) -> Stem.Model

  add: (models...) ->
    models = _.flatten models
    @_add model for model in models

  remove: (models...) ->
    models = _.flatten models
    @_remove model for model in models

  reset: (models...) ->
    @_unbindModel model for model in @models
    @models = []
    @add models
    @trigger "reset", this

  at: (index) ->
    @models[index]

  _modelEvents: (event, args...) =>
    @trigger.apply this, [event, this].concat(args)

  _add: (model) ->
    unless model instanceof Stem.Model
      # If the model attribute is a Model constructor, use it, else resolve at
      # runtime the constructor using the passed attributes
      ctor = if @model.prototype instanceof Stem.Model then @model else @model.call(this, model)
      model = new ctor model
    model.bind "*", @_modelEvents
    @models.push model
    @trigger "add", this, model

  _remove: (model) ->
    idx = _.indexOf @models, model
    return null if idx < -1
    @models.splice idx, 1
    @_unbindModel model
    @trigger "remove", this, model

  _unbindModel: (model) ->
    model.unbind "*", @_modelEvents

  methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
      'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
      'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
      'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy']

  for method in methods
    do (method) =>
      @::[method] = (args...) ->
        _[method](@models, args...)