#= require lib/coffeemvc

class Post extends CoffeeMVC.Model
  @property "poster.fullName",
    get: -> "#{@get "poster.firstName"} #{@get "poster.middleName"} #{@get "poster.lastName"}"

window.post = new Post
  title: "Yay!",
  poster:
    firstName: "Paul",
    lastName: "Simard"

post.attach new CoffeeMVC.Observer
  set: (event, path, value) ->
    console.log path, "set to", value

post.set "poster.middleName", "M."
console.log post.get "poster.fullName"

post.set "poster.middleName", "A."
console.log post.get "poster.fullName"

post.set "poster", { firstName: "John", lastName: "James", middleName: "C." }
console.log post.get "poster.fullName"
