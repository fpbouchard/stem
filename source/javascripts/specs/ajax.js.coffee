describe "ajax calls", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "should allow to call a remote service that updates models", ->

    response = [
      {
        action: "updateModel"
        directives:
          modelPath: "Sample.model"
          attributes:
            name: "John"
      }]

    @server.respondWith "POST", "/url", [200, {"Content-Type": "application/json"}, JSON.stringify(response)]

    window.Sample = {}
    Sample.model = new Stem.Model
      name: "Peter"
    Stem.Ajax.request "/url"
    @server.respond()
    expect(Sample.model.get "name").toEqual "John"

  it "should allow to call a remote service that updates collections", ->

    response = [
      {
        action: "updateCollection"
        directives:
          collectionPath: "Sample.collection"
          models: [
            {name: "John"}
            {name: "Peter"}
          ]
      }]

    @server.respondWith "POST", "/url", [200, {"Content-Type": "application/json"}, JSON.stringify(response)]

    window.Sample = {}
    Sample.collection = new Stem.Collection
    Stem.Ajax.request "/url"
    @server.respond()
    expect(Sample.collection.size()).toEqual 2
    expect(Sample.collection.at(0).get "name").toEqual "John"
    expect(Sample.collection.at(1).get "name").toEqual "Peter"