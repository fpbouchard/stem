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