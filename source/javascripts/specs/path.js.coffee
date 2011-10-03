describe "Path", ->

  it "should read a simple property", ->
    container = prop: "value"
    expect($path.read "prop", container).toEqual "value"

  it "should read a nested property", ->
    container = branch: leaf: "value"
    expect($path.read "branch.leaf", container).toEqual "value"

  it "should allow to create a simple property", ->
    container = {}
    $path.write "prop", container, "value"
    expect($path.read "prop", container).toEqual "value"

  it "should allow to change a simple property", ->
    container = prop: "value"
    $path.write "prop", container, "changed"
    expect($path.read "prop", container).toEqual "changed"

  it "should allow to create a nested property", ->
    container = branch: leaf: "value"
    $path.write "branch.leaflet", container, "new"
    expect($path.read "branch.leaflet", container).toEqual "new"

  it "should allow to change a nested property", ->
    container = branch: leaf: "value"
    $path.write "branch.leaf", container, "changed"
    expect($path.read "branch.leaf", container).toEqual "changed"

  it "should walk in a container", ->
    container = {}
    [scopedContainer, lastLeaf] = $path.walk "branch.leaf", container
    (expect container["branch"]).toBeDefined()
    (expect scopedContainer).toBe container.branch
    (expect lastLeaf).toEqual "leaf"
    (expect scopedContainer[lastLeaf]).toBeUndefined()

  it "should show relationship between two paths", ->
    path1 = "a.b.c"
    path2 = "a.b"
    expect($path.contains path1, path2).toBeFalsy()
    expect($path.contains path2, path1).toBeTruthy()

    path1 = "a.b.c"
    path2 = "a.b.c"
    expect($path.contains path1, path2).toBeTruthy()