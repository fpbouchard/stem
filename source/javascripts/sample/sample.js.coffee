class Context extends Stem.Model
  defaults:
    mode: "MODE A"
  toggleMode: ->
    mode = @get "mode"
    @set(mode: if mode == "MODE A" then "MODE B" else "MODE A")

class ModeWidget extends Stem.View
  el: "#mode-toggler"

  template: _.template '''
    <div class="mode">
      <%= get("mode") %>
    </div>
    <a href="javascript:void(0)" class="toggle">Toggle!</a>
  '''

  @events
    "click a.toggle": "toggleMode"

  @bindings
    "change:mode": "invalidate"

  render: ->
    $(@el).html(@template this.model)

  toggleMode: =>
    @model.toggleMode()

context = new Context

modeWidget = new ModeWidget
  model: context
