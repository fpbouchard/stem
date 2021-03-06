describe "Collection", ->

  describe "a simple collectcion", ->
    collection = null
    model = null

    beforeEach ->
      collection = new Stem.Collection
      model = new Stem.Model
        name: "John"
      collection.add model

    it "should allow fetching its models by index", ->
      expect(collection.at(0)).toBe model

    it "should trigger its models events", ->
      changeCallback = sinon.spy()
      starCallback = sinon.spy()

      collection.bind "change:name", changeCallback
      collection.bind "*", starCallback

      model.set name: "Peter"

      expect(changeCallback).toHaveBeenCalledWith collection, model, "name", "Peter"
      expect(starCallback).toHaveBeenCalledWith "change:name", collection, model, "name", "Peter"

    it "should allow to reset its model array with a new array", ->
      models = [
        new Stem.Model
          name: "Robert"
        new Stem.Model
          name: "Georges"
      ]
      collection.reset models
      expect(collection.size()).toEqual 2
      expect(collection.at(0).get "name").toEqual "Robert"
      expect(collection.at(1).get "name").toEqual "Georges"

    it "should squash all arguments passed to add and reset", ->
      models = [
        new Stem.Model
          name: "Robert"
        new Stem.Model
          name: "Georges"
      ]

      collection.reset()
      collection.add models
      expect(collection.size()).toEqual 2

      collection.reset()
      collection.add.apply collection, models
      expect(collection.size()).toEqual 2

      collection.reset models
      expect(collection.size()).toEqual 2

      collection.reset.apply collection, models
      expect(collection.size()).toEqual 2

    it "should implement underscore.js's collection helpers", ->
      expect(collection['map']).toBeDefined()
      expect(collection['select']).toBeDefined()

  describe "events", ->
    it "should trigger an event when a model is added", ->
      callback = sinon.spy()
      collection = new Stem.Collection
      collection.bind "add", callback

      model = new Stem.Model {name: "John"}
      collection.add model

      expect(callback).toHaveBeenCalledWith collection, model

    it "should trigger an event when it is reset", ->
      callback = sinon.spy()
      collection = new Stem.Collection
      collection.bind "reset", callback

      collection.reset()

      expect(callback).toHaveBeenCalledWith collection

    it "should trigger add events and a reset event when it is reset with new models", ->
      addCallback = sinon.spy()
      resetCallback = sinon.spy()

      collection = new Stem.Collection
      collection.bind "add", addCallback
      collection.bind "reset", resetCallback
      collection.reset {name: "John"}, {name: "Peter"}

      expect(addCallback).toHaveBeenCalledTwice()
      expect(resetCallback).toHaveBeenCalledOnce()

  describe "adding and removing", ->

    it "should allow to create a new Stem.Model subclass from attributes when adding (wrapped constructor)", ->
      class SampleModel extends Stem.Model
      class SampleCollection extends Stem.Collection
        model: -> SampleModel
      collection = new SampleCollection
        name: "Peter"
      expect(collection.size()).toEqual 1
      expect(collection.at(0) instanceof SampleModel).toBeTruthy()
      expect(collection.at(0).get "name").toEqual "Peter"

    it "should allow to create a new Stem.Model subclass from attributes when adding (direct constructor)", ->
      class SampleModel extends Stem.Model
      class SampleCollection extends Stem.Collection
        model: SampleModel
      collection = new SampleCollection
        name: "Peter"
      expect(collection.size()).toEqual 1
      expect(collection.at(0) instanceof SampleModel).toBeTruthy()
      expect(collection.at(0).get "name").toEqual "Peter"

    it "should allow removing", ->
      collection = new Stem.Collection
      model = new Stem.Model {name: "John"}

      collection.add model
      expect(collection.indexOf(model)).toEqual 0

      collection.remove model
      expect(collection.indexOf(model)).toEqual -1

    it "should allow polymorphism", ->
      class ModelA extends Stem.Model
      class ModelB extends Stem.Model

      class PolymorphicCollection extends Stem.Collection
        model: (attributes) ->
          if attributes["model"] == "ModelA" then ModelA else ModelB

      collection = new PolymorphicCollection [
        {model: "ModelA", name: "Peter"},
        {model: "ModelB", name: "John"}
      ]
      expect(collection.size()).toEqual 2
      expect(collection.at(0) instanceof ModelA).toBeTruthy()
      expect(collection.at(1) instanceof ModelB).toBeTruthy()
      expect(collection.at(0).get "name").toEqual "Peter"
      expect(collection.at(1).get "name").toEqual "John"