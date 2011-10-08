describe "Model", ->
  describe "A simple model", ->
    class Post extends CoffeeMVC.Model

    it "should implement Events", ->
      post = new Post
      (expect post["bind"]).toBeDefined()
      (expect post["trigger"]).toBeDefined()


    describe "with attributes", ->

      post = null

      beforeEach ->
        post = new Post
          title: "title"

      it "should be initialized with initial values", ->
        (expect post["attributes"]).toBeDefined()
        (expect post.attributes["title"]).toEqual "title"

      it "should get an attribute", ->
        (expect post.get "title").toEqual "title"

      it "should set an attribute", ->
        post.set title: "new"
        (expect post.get "title").toEqual "new"

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
        (expect titleCallback).toHaveBeenCalledWith(post, "new")
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

      class PostWithDefaults extends CoffeeMVC.Model
        defaults:
          title: "default"
          body: "body"

      it "should initialize with its defaults", ->
        post = new PostWithDefaults
        (expect post.get "title").toEqual "default"
        (expect post.get "body").toEqual "body"

      it "should priorize attributes passed at the constructor over its defaults", ->
        post = new PostWithDefaults
          title: "overridden"
        (expect post.get "title").toEqual "overridden"
        (expect post.get "body").toEqual "body"


  describe "A model with hooks", ->
    class Post extends CoffeeMVC.Model
      beforeSet: (attributes) ->
        attributes.title = "overridden"

    it "should allow to modify attributes before they are set (beforeSet)", ->
      post = new Post
        title: "new"
      post.set title: "changed"
      (expect post.get "title").toEqual "overridden"
