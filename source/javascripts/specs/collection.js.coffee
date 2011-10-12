describe "Collection", ->
  collection = null
  model = null

  beforeEach ->
    collection = new Stem.Collection
    model = new Stem.Model
      name: "John"
    collection.add model

  it "should allow fetching its models by index", ->
    expect(collection.at(0)).toBe model

  it "should trigger it's models events", ->
    callback = sinon.spy()

    collection.bind "change:name", callback

    model.set name: "Peter"

    expect(callback).toHaveBeenCalledWith collection, model, "name", "Peter"

  it "should allow to reset its model array with a new array", ->
    model = new Stem.Model
      name: "Robert"
    collection.reset model
    expect(collection.size()).toEqual 1
    expect(collection.at(0)).toBe model

  it "should allow to create a new model from attributes when adding", ->
    collection.add
      name: "Peter"
    expect(collection.size()).toEqual 2
    expect(collection.at(1) instanceof Stem.Model).toBeTruthy()

  it "should allow polymorphic collections", ->
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