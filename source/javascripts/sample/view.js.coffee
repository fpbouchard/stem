class ModeWidget extends CoffeeMVC.View
  el: "#mode-toggler"
  template: _.template '''
                       <div class="mode">
                         <%= get("mode") %>
                       </div>
                       <a href="javascript:void(0)" class="toggle">Toggle!</a>
                       '''
  delegates:
    "click a.toggle": -> @model.toggleMode()

  constructor: ->
    super
    @model.bind("change:mode", @invalidate)

  render: ->
    $(@el).html(@template this.model)

modeWidget = new ModeWidget
  model: Sample.context

modeWidget.render()