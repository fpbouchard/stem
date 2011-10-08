# Abstract dom implementation, to be implemented with a js navigation/handling stack
#

window.CoffeeMVC.DOM =
  select: (expression) -> []
  delegate: (element, selector, eventName, handler) -> null


if window.jQuery?
  CoffeeMVC.DOM.select = window.jQuery
  CoffeeMVC.DOM.delegate = (element, selector, eventName, handler) -> $(element).delegate(selector, eventName, handler)

if window.Prototype?
  CoffeeMVC.DOM.select = (expression) -> Prototype.Selector.select(expression, document)
  CoffeeMVC.DOM.delegate = (element, selector, eventName, handler) -> Event.on(element, eventName, selector, handler)
