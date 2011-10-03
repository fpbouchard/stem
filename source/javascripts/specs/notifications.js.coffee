describe "Notifications", ->

  describe "Subjects", ->

    subject = null

    beforeEach ->
      subject = new CoffeeMVC.Subject

    it "should allow attaching observers", ->
      observer = new CoffeeMVC.Observer
      (expect subject.observers.length).toEqual 0
      subject.attach observer
      (expect subject.observers.length).toEqual 1
      (expect subject.observers[0]).toBe observer

    it "should allow to notify events, and observers to listen", ->
      pong = false
      observer = new CoffeeMVC.Observer
        ping: -> pong = true
      subject.attach observer
      (expect pong).toBeFalsy()
      subject.notify "ping"
      (expect pong).toBeTruthy()

    it "should notify observers as they are attached", ->
      attached = false
      observer = new CoffeeMVC.Observer
        attached: -> attached = true
      (expect attached).toBeFalsy()
      subject.attach observer
      (expect attached).toBeTruthy()

    it "should return an event instance after notifying a simple event", ->
      observer = new CoffeeMVC.Observer
        ping: (event) -> event.pong = true
      subject.attach observer

      event = subject.notify "ping"
      expect(event).toBeDefined()
      expect(event.pong).toBeTruthy()

    it "should pass an arbitrary number of arguments to observers", ->
      called = false
      observer = new CoffeeMVC.Observer
        ping: (event, a, b, c, d) ->
          called = true
          (expect a).toEqual 1
          (expect b).toEqual 2
          (expect c).toEqual [1,2]
          (expect d).toBeUndefined()

      subject.attach observer
      (expect called).toBeFalsy()
      subject.notify "ping", 1, 2, [1,2]
      (expect called).toBeTruthy()
