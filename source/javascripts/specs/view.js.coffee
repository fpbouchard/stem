describe "View", ->

  it "should implement Events", ->
    view = new Stem.View
    (expect view["bind"]).toBeDefined()
    (expect view["trigger"]).toBeDefined()

  it "should implement a render function", ->
    view = new Stem.View
    (expect view["render"]).toBeDefined()

  it "should accept attributes", ->
    attributes = a: 1, b: 2
    view = new Stem.View attributes
    (expect view["a"]).toEqual 1
    (expect view["b"]).toEqual 2

  describe "elements", ->
    it "should try to resolve this.el (set at prototype-level) to an actual DOM element through the Stem.DOM facade", ->
      class ViewWithElement extends Stem.View
        el: "#some-el"

      domSpy = sinon.spy Stem.DOM, "select"
      new ViewWithElement
      (expect domSpy).toHaveBeenCalledWith "#some-el"

      domSpy.restore()

    it "should try to resolve this.el (set at instance-level) to an actual DOM element through the Stem.DOM facade", ->
      domSpy = sinon.spy Stem.DOM, "select"
      new Stem.View el: "#some-el"
      (expect domSpy).toHaveBeenCalledWith "#some-el"

      domSpy.restore()

  describe "delegates", ->
    it "should validate delegate descriptors", ->
      instanciateDelegatedView = (delegates) ->
        ->
          class DelegatedView extends Stem.View
            @delegates delegates
          new DelegatedView
      expect(instanciateDelegatedView "eventName selector": ->).not.toThrow()
      expect(instanciateDelegatedView "no-selector": ->).toThrow()
      expect(instanciateDelegatedView "": ->).toThrow()

    it "should install delegates on the view element (function handler)", ->
      domSpy = sinon.spy(Stem.DOM, "delegate")

      class DelegatedView extends Stem.View
        @delegates
          "click .me": ->

      view = new DelegatedView
      (expect domSpy).toHaveBeenCalled()

      domSpy.restore()

    it "should install delegates on the view element (method handler)", ->
      domSpy = sinon.spy(Stem.DOM, "delegate")

      class DelegatedView extends Stem.View
        @delegates
          "click .me": "clickme"
        clickme: ->

      view = new DelegatedView
      (expect domSpy).toHaveBeenCalled()

      domSpy.restore()

  describe "bindings", ->
    it "should prevent passing both the 'model' and 'collection' attributes", ->
      shouldFail = ->
        new Stem.View
          model: new Stem.Model
          collection: new Stem.Collection

      expect(shouldFail).toThrow()

    it "should bind to model events (function handler)", ->
      callback = sinon.spy()

      class BoundView extends Stem.View
        @bindings
          "change:title": callback

      model = new Stem.Model
      view = new BoundView
        model: model

      (expect callback).not.toHaveBeenCalled()
      model.set title: "title"
      (expect callback).toHaveBeenCalled()

    it "should bind to model events (method handler)", ->
      class BoundView extends Stem.View
        @bindings
          "change:title": "callback"
        callback: ->

      callback = sinon.spy(BoundView.prototype, "callback")

      model = new Stem.Model
      view = new BoundView
        model: model

      (expect callback).not.toHaveBeenCalled()
      model.set title: "title"
      (expect callback).toHaveBeenCalled()

    it "should bind to collection events", ->
      callback = sinon.spy()

      class BoundView extends Stem.View
        @bindings
          "change:title": callback

      collection = new Stem.Collection {title: "one"}, {title: "two"}
      new BoundView collection: collection

      collection.at(0).set title: "modified"
      expect(callback).toHaveBeenCalledOnce()
      collection.at(1).set title: "modified"
      expect(callback).toHaveBeenCalledTwice()

  describe "invalidation", ->

    it "should handle invalidation and rendering through model updates", ->
      class InvalidateView extends Stem.View
        constructor: ->
          super
          @model.bind "change:title, change:body", @invalidate

      model = new Stem.Model
      view = new InvalidateView model: model

      spy = sinon.spy view, "render"

      # This is not a bound field, spy should not have been called
      model.set foo: "bar"
      (expect spy).not.toHaveBeenCalled()

      # Even if two listened properties changed, render is called only once
      model.set title: "new title", body: "new body"
      (expect spy).toHaveBeenCalledOnce()

      # This is not a bound field, spy should not have been called again
      model.set foo: "bar"
      (expect spy).toHaveBeenCalledOnce()

