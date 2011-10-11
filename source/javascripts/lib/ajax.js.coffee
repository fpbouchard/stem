Ajax = Stem.Ajax =
  request: (url, parameters = {}) -> null
  processResponseCommands: (commands) ->
    for command in commands
      switch command.action
        when "updateModel"
          modelKeys = command.directives.modelPath.split "."
          model = window
          model = model?[key] for key in modelKeys
          throw "Invalid model path: \"#{command.directives.modelPath}\"" unless model?
          model.set command.directives.attributes
        else
          throw "Unknown ajax response command: '#{command.action}'"

if window.Prototype?
  null

if window.jQuery?
  Stem.Ajax.request = (url, parameters = {}) ->
    jQuery.ajax url,
      type: "POST"
      dataType: "json"
      success: (data, textStatus, jqXHR) ->
        Ajax.processResponseCommands data