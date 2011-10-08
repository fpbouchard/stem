class ModeWidget extends CoffeeMVC.View
  el: "#mode-toggler"

  template: _.template '''
    <div class="mode">
      <%= get("mode") %>
    </div>
    <a href="javascript:void(0)" class="toggle">Toggle!</a>
  '''

  delegates:
    "click a.toggle": "toggleMode"

  bindings:
    "change:mode": "invalidate"

  render: ->
    $(@el).html(@template this.model)

  toggleMode: ->
    @model.toggleMode()

modeWidget = new ModeWidget
  model: Sample.context

modeWidget.render()