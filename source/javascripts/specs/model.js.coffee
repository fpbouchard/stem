describe "Model", ->

  describe "a simple model", ->

    class Post extends CoffeeMVC.Model

    it "should be able to read its properties at level zero", ->
      post = new Post
        title: "Yay!",
      (expect post.get "title").toEqual "Yay!"

    it "should be able to read its properties in a subtree", ->
      post = new Post
        poster:
          firstName: "John"
          lastName: "Smith"
      (expect post.get "poster").toEqual firstName: "John", lastName: "Smith"
      (expect post.get "poster.firstName").toEqual "John"
      (expect post.get "poster.lastName").toEqual "Smith"

    it "should not fail when reading undefined properties", ->
      post = new Post
      expect(post.get "foo").toBeUndefined()
      expect(post.get "foo.bar").toBeUndefined()

    it "should allow setting a simple property", ->
      post = new Post
        title: "Yay!"
      # Existing property
      post.set "title", "changed"
      (expect post.get "title").toEqual "changed"
      # New property
      post.set "new", "exists"
      (expect post.get "new").toEqual "exists"

    it "should allow setting property in subtrees", ->
      post = new Post
        poster:
          firstName: "John"
          lastName: "Smith"
      post.set "poster.firstName", "Pete"
      (expect post.get "poster.firstName").toEqual "Pete"

      post.set "poster", firstName: "Jane", lastName: "Doe"
      (expect post.get "poster").toEqual firstName: "Jane", lastName: "Doe"

  describe "the model class", ->

    it "should allow defining dynamic properties", ->
      class Post extends CoffeeMVC.Model
        @property "poster.fullName",
          get: -> "#{@get "poster.firstName"} #{@get "poster.middleName"} #{@get "poster.lastName"}"
      (expect Post.properties.length).toEqual 1

    it "should have its own list of dynamic properties", ->
      class Obj1 extends CoffeeMVC.Model
        @property "prop1",
          get: -> "val1"
      class Obj2 extends CoffeeMVC.Model
        @property "prop2",
          get: -> "val2"

      (expect Obj1.properties.length).toEqual 1
      (expect Obj1.properties[0].path).toEqual "prop1"
      (expect Obj2.properties.length).toEqual 1
      (expect Obj2.properties[0].path).toEqual "prop2"

  describe "a model with dynamic properties", ->
    class Post extends CoffeeMVC.Model
      @property "poster.fullName",
        get: -> "#{@get "poster.firstName"} #{@get "poster.middleName"} #{@get "poster.lastName"}"

    post = null

    beforeEach ->
      post = new Post
        poster:
          firstName: "John"
          middleName: "A."
          lastName: "Doe"

    it "should resolve its dynamic properties", ->
      (expect post.get "poster.fullName").toEqual "John A. Doe"

    it "should resolve its dynamic properties at runtime", ->
      post.set "poster.firstName", "Jane"
      (expect post.get "poster.fullName").toEqual "Jane A. Doe"

    it "should reinstall its dynamic properties when a model changes its contained object", ->
      post.set "poster", firstName: "Homer", middleName: "J.", lastName: "Simpson"
      (expect post.get "poster.fullName").toEqual "Homer J. Simpson"

  describe "an observable model", ->
    class Post extends CoffeeMVC.Model

    post = null

    beforeEach ->
      post = new Post
        poster:
          firstName: "John"
          middleName: "A."
          lastName: "Doe"

    it "should notify when a property is set", ->
      called = false
      observer = new CoffeeMVC.Observer
        set: (event, path, value) ->
          called = true
          (expect path).toEqual "poster.firstName"
          (expect value).toEqual "Jane"

      post.attach observer
      post.set "poster.firstName", "Jane"
      (expect called).toBeTruthy()