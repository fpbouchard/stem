window.$path = Path = CoffeeMVC.Path =
  walk: (path, container) ->
    segments = path.split "."
    cursor = container
    for segment in segments[0...segments.length - 1]
      cursor = cursor[segment] ||= {}
    [cursor, segments[segments.length - 1]]

  write: (path, container, value) ->
    segments = path.split "."
    cursor = container
    for segment in segments[0...segments.length - 1]
      cursor = cursor[segment] ||= {}
    [container, key] = Path.walk path, container
    container[key] = value

  read: (path, container) ->
    segments = path.split "."
    value = container
    value = value?[segment] for segment in segments
    value

  contains: (path1, path2) ->
    segments1 = path1.split "."
    segments2 = path2.split "."
    return false if segments1.length > segments2.length
    (return false if segments1[i] != segments2[i]) for i in [0..segments1.length - 1]
    true


