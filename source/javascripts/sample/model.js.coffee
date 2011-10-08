class Context extends CoffeeMVC.Model
  defaults:
    mode: "MODE A"
  toggleMode: ->
    mode = @get "mode"
    @set(mode: if mode == "MODE A" then "MODE B" else "MODE A")


Sample.context = new Context