describe "View", ->

  it "should implement Events", ->
    view = new CoffeeMVC.View
    (expect view["bind"]).toBeDefined()
    (expect view["trigger"]).toBeDefined()

  it "should implement a render function", ->
    view = new CoffeeMVC.View
    (expect view["render"]).toBeDefined()

  it "should accept attributes", ->
    attributes = a: 1, b: 2
    view = new CoffeeMVC.View attributes
    (expect view["a"]).toEqual 1
    (expect view["b"]).toEqual 2

  describe "invalidation", ->

    it "should handle invalidation and rendering through model updates", ->
      class InvalidateView extends CoffeeMVC.View
        constructor: ->
          super
          @model.bind "change:title, change:body", @invalidate

      model = new CoffeeMVC.Model
      view = new InvalidateView model: model

      spy = sinon.spy view, "render"

      # This is not a invalidateOn field, spy should not have been called
      model.set foo: "bar"
      (expect spy).not.toHaveBeenCalled()

      # Even if two listened properties changed, render is called only once
      model.set title: "new title", body: "new body"
      (expect spy).toHaveBeenCalledOnce()

      # This is not a invalidateOn field, spy should not have been called again
      model.set foo: "bar"
      (expect spy).toHaveBeenCalledOnce()

  describe "delegates", ->
    it "should validate delegate descriptors", ->
      expect(-> new CoffeeMVC.View delegates: "eventName selector": ->).not.toThrow()
      expect(-> new CoffeeMVC.View delegates: "no-selector": ->).toThrow()
      expect(-> new CoffeeMVC.View delegates: "": ->).toThrow()

    it "should install delegates on the view element", ->
      domSpy = sinon.spy(CoffeeMVC.DOM, "delegate")

      handler = ->
      delegates = "click .me": handler
      el = {}
      view = new CoffeeMVC.View
        el: el
        delegates: delegates
      (expect view.delegates).toBe delegates
      (expect domSpy).toHaveBeenCalledWith(el, ".me", "click", handler)

      domSpy.restore()