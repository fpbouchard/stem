class Stem.Collection
  @implements Stem.Events

  constructor: (models...) ->
    @models = []
    @add models if models.length > 0

  model: (attributes) -> Stem.Model

  add: (models...) ->
    models = _.flatten models
    @_add model for model in models

  reset: (models...) ->
    @models = []
    @add models

  at: (index) ->
    @models[index]

  _modelEvents: (event, args...) =>
    @trigger.apply this, [event, this].concat(args)

  _add: (model) ->
    unless model instanceof Stem.Model
      model = new (@model(model))(model)
    model.bind "*", @_modelEvents
    @models.push model

  methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
      'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
      'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
      'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy']

  for method in methods
    do (method) =>
      @::[method] = ->
        _[method].apply _, [@models].concat(_.toArray(arguments))
