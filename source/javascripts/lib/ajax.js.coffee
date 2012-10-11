Stem.Ajax =
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
        when "updateCollection"
          collectionKeys = command.directives.collectionPath.split "."
          collection = window
          collection = collection?[key] for key in collectionKeys
          throw "Invalid collection path: \"#{command.directives.collectionPath}\"" unless collection?
          collection.reset command.directives.models
        else
          throw "Unknown ajax response command: '#{command.action}'"

if window.Prototype?
  Stem.Ajax.request = (url, parameters = {}) ->
    new Ajax.Request url,
      method: "POST"
      contentType: "application/json"
      parameters: parameters
      onSuccess: (response) ->
        Stem.Ajax.processResponseCommands response.responseJSON
  null

if window.jQuery?
  Stem.Ajax.request = (url, parameters = {}) ->
    jQuery.ajax url,
      type: "POST"
      dataType: "json"
      success: (data, textStatus, jqXHR) ->
        Stem.Ajax.processResponseCommands data