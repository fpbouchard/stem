class ModeToggler extends CoffeeMVC.View
  el: "#mode-toggler"
  template: _.template '''
                       <span class="mode">
                         <%= get("mode") %>
                       </span>
                       <a href="javascript:void(0)" class="toggle">Toggle!</a>
                       '''
  delegates:
    "click a.toggle": ->
      mode = this.model.get "mode"
      this.model.set mode: if mode == "mode1" then "mode2" else "mode1"

  constructor: ->
    super
    @model.bind "change:mode", @invalidate

  render: ->
    $(@el).html @template this.model

modeToggler = new ModeToggler
  model: Sample.context

modeToggler.render()