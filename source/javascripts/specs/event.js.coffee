describe "Event mixin", ->

  obj = null

  beforeEach ->
    obj = new CoffeeMVC.Events

  describe "single events", ->

    it "should bind to an event", ->
      (expect obj.bindings).toBeUndefined()
      obj.bind "event", ->
      (expect obj.bindings["event"]).toBeDefined()
      (expect obj.bindings["event"].length).toEqual 1

    it "should not bind twice to the same event/callback combo", ->
      callback = ->
      obj.bind "event", callback
      obj.bind "event", callback
      (expect obj.bindings["event"].length).toEqual 1

    it "should trigger an event and notify its bindings", ->
      callback = sinon.spy()
      obj.bind "event", callback
      (expect callback).not.toHaveBeenCalled()
      obj.trigger "event"
      (expect callback).toHaveBeenCalled()

    it "should not notify a binding of a non-matching event", ->
      callback = sinon.spy()
      obj.bind "foo", callback
      (expect callback).not.toHaveBeenCalled()
      obj.trigger "bar"
      (expect callback).not.toHaveBeenCalled()

    it "should pass an arbitrary number of arguments to bindings", ->
      callback = sinon.spy()
      obj.bind "event", callback

      (expect callback).not.toHaveBeenCalled()
      obj.trigger "event", 1, 2, [1,2]
      (expect callback).toHaveBeenCalledWith(1, 2, [1,2])

    it "should unbind from an event", ->
      callback = sinon.spy()
      obj.bind "foo", callback
      obj.trigger "foo"
      (expect callback).toHaveBeenCalledOnce()
      obj.unbind "foo", callback
      (expect obj.bindings["foo"].length).toEqual 0
      obj.trigger "foo"
      (expect callback).toHaveBeenCalledOnce()


  describe "multiple events", ->

    for eventDescriptor in ["foo,bar", "foo, bar", "foo,  bar", "foo,   bar"]
      it "should bind to multiple events using the \"#{eventDescriptor}\" eventDescriptor on the same callback", ->
        callback = sinon.spy()
        obj.bind eventDescriptor, callback

        (expect callback).not.toHaveBeenCalled()
        obj.trigger "foo"
        (expect callback).toHaveBeenCalledOnce()
        obj.trigger "bar"
        (expect callback).toHaveBeenCalledTwice()
