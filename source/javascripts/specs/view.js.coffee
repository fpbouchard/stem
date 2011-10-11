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

  describe "delegates", ->
    it "should validate delegate descriptors", ->
      expect(-> new Stem.View delegates: "eventName selector": ->).not.toThrow()
      expect(-> new Stem.View delegates: "no-selector": ->).toThrow()
      expect(-> new Stem.View delegates: "": ->).toThrow()

    it "should install delegates on the view element (function handler)", ->
      domSpy = sinon.spy(Stem.DOM, "delegate")

      delegates = "click .me": ->
      view = new Stem.View
        delegates: delegates
      (expect view.delegates).toBe delegates
      (expect domSpy).toHaveBeenCalled()

      domSpy.restore()

    it "should install delegates on the view element (method handler)", ->
      domSpy = sinon.spy(Stem.DOM, "delegate")

      class ClickMeView extends Stem.View
        clickme: ->

      delegates = "click .me": "clickme"
      view = new ClickMeView
        delegates: delegates
      (expect view.delegates).toBe delegates
      (expect domSpy).toHaveBeenCalled()

      domSpy.restore()

  describe "with prototype-level bindings", ->
    it "should bind to model events at construction time (function handler)", ->
      callback = sinon.spy()

      class BoundView extends Stem.View
        bindings:
          "change:title": callback

      model = new Stem.Model
      view = new BoundView
        model: model

      (expect callback).not.toHaveBeenCalled()
      model.set title: "title"
      (expect callback).toHaveBeenCalled()

    it "should bind to model events at construction time (method handler)", ->
      class BoundView extends Stem.View
        bindings:
          "change:title": "callback"
        callback: ->

      callback = sinon.spy(BoundView.prototype, "callback")

      model = new Stem.Model
      view = new BoundView
        model: model

      (expect callback).not.toHaveBeenCalled()
      model.set title: "title"
      (expect callback).toHaveBeenCalled()
