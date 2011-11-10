describe "Model", ->
  describe "A simple model", ->
    class Post extends Stem.Model

    it "should implement Events", ->
      post = new Post
      (expect post["bind"]).toBeDefined()
      (expect post["trigger"]).toBeDefined()


    describe "with attributes", ->

      post = null
      poster =
        firstName: "John"
        lastName: "Doe"

      beforeEach ->
        post = new Post
          title: "title"
          poster: poster

      it "should be initialized with initial values", ->
        (expect post["attributes"]).toBeDefined()
        (expect post.attributes["title"]).toEqual "title"

      it "should use the initial values by reference (not cloned)", ->
        expect(post.get "poster").toBe poster

      it "should get an attribute", ->
        (expect post.get "title").toEqual "title"

      it "should set an attribute", ->
        post.set title: "new"
        (expect post.get "title").toEqual "new"

      it "should validate the arguments of the 'set' call", ->
        arraySet = ->
          post.set "title", "value"
        expect(arraySet).toThrow()

        objectSet = ->
          post.set "title": "value"
        expect(objectSet).not.toThrow()

    describe "events", ->

      post = null

      beforeEach ->
        post = new Post
          title: "title"

      it "should trigger a change event when any attributes change", ->
        callback = sinon.spy()
        post.bind "change", callback
        (expect callback).not.toHaveBeenCalled()
        post.set title: "new", foo: "bar"
        (expect callback).toHaveBeenCalledWith(post, ["title", "foo"])

      it "should trigger a change event when specific attributes change", ->
        titleCallback = sinon.spy()
        post.bind "change:title", titleCallback
        fooCallback = sinon.spy()
        post.bind "change:foo", fooCallback

        (expect titleCallback).not.toHaveBeenCalled()
        (expect fooCallback).not.toHaveBeenCalled()
        post.set title: "new"
        (expect titleCallback).toHaveBeenCalledWith(post, "title", "new")
        (expect fooCallback).not.toHaveBeenCalled()

      it "should not trigger a specific change event for fields that are set but did not change", ->
        callback = sinon.spy()
        post.bind "change:title", callback

        (expect callback).not.toHaveBeenCalled()
        post.set title: "title"
        (expect callback).not.toHaveBeenCalled()

      it "should not trigger a global change event for fields that are set but did not change", ->
        callback = sinon.spy()
        post.bind "change", callback

        (expect callback).not.toHaveBeenCalled()
        post.set title: "title"
        (expect callback).not.toHaveBeenCalled()
        post.set title: "title", foo: "bar"
        (expect callback).toHaveBeenCalledWith(post, ["foo"])

  describe "with defaults", ->

    poster =
      firstName: "John"
      lastName: "Doe"

    class PostWithDefaults extends Stem.Model
      defaults:
        title: "default"
        body: "body"
        poster: poster

    it "should initialize with its defaults", ->
      post = new PostWithDefaults
      (expect post.get "title").toEqual "default"
      (expect post.get "body").toEqual "body"

    it "should priorize attributes passed at the constructor over its defaults", ->
      post = new PostWithDefaults
        title: "overridden"
      (expect post.get "title").toEqual "overridden"
      (expect post.get "body").toEqual "body"

    it "should deep copy from its defaults when building an instance", ->
      post = new PostWithDefaults
      expect(post.get "poster").not.toBe poster
      expect(post.get "poster").toEqual poster

  describe "snapshots", ->

    it "should allow taking a snapshot of the current objects", ->

      post = new Stem.Model
        title: "new"

      expect(post.currentSnapshot).toBeUndefined()
      post.snapshot()
      expect(post.currentSnapshot).toBeDefined()
      expect(post.currentSnapshot["title"]).toEqual "new"

    it "should make deep copies for snapshots", ->
      poster =
        firstName: "John"
        lastName: "Smith"
      post = new Stem.Model
        title: "new"
        poster: poster

      expect(post.get "poster").toBe poster
      post.snapshot()
      expect(post.currentSnapshot["poster"]).not.toBe poster
      expect(post.currentSnapshot["poster"]).toEqual poster

    it "should allow restoring attributes from snapshots", ->
      post = new Stem.Model
        title: "new"
      post.snapshot()
      post.set title: "changed"
      post.restore "title"
      expect(post.get "title").toEqual "new"

    it "should allow restoring multiple attributes from snapshots", ->
      post = new Stem.Model
        title: "new"
        body: "body"
      post.snapshot()
      post.set title: "changed", body: "also changed"
      post.restore "title", "body"
      expect(post.get "title").toEqual "new"
      expect(post.get "body").toEqual "body"

  describe "A model with hooks", ->
    class Post extends Stem.Model
      beforeSet: (attributes) ->
        attributes.title = "intercepted"

    it "should allow to modify attributes before they are set (beforeSet)", ->
      post = new Post
        title: "new"
      post.set title: "changed"
      (expect post.get "title").toEqual "intercepted"
