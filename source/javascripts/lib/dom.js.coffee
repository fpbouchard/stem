# Abstract dom implementation, to be implemented with a js navigation/handling stack

Stem.DOM =
  select: (expression) -> []
  delegate: (element, selector, eventName, handler) -> null

# Implementations

if Prototype?
  Stem.DOM.select = (expression) -> Prototype.Selector.select(expression, document)
  Stem.DOM.delegate = (element, selector, eventName, handler) -> Event.on(element, eventName, selector, handler)

if jQuery?
  Stem.DOM.select = window.jQuery
  Stem.DOM.delegate = (element, selector, eventName, handler) -> jQuery(element).delegate(selector, eventName, handler)