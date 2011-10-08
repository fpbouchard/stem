class GlobalContext extends CoffeeMVC.Model
  default:
    mode: "mode1"
    # Current view scope, filters out weeks from the weekly grid
    viewScopeMonth: null
    viewScopeStartDate: null
    viewScopeEndDate: null
    # If in 'plan' mode, defines the selected plan
    plan: null
    # Filters
    filterWeeklyRows: []
    # Availability rows
    availabilityRowsResources: []
    availabilityRowsWeeklyRow: null
    # Resource highlight
    highlightedResource: null
    highlightedResources: []
    # Helper rows (array of helperRows.id)
    helperRows: []
    # Task selection fields
    multiSelect: false
    # Multi-selection works by clearing task/assignmentIndex/weeklyRowSpecificationId and adding to the tasks array
    tasks: []
    task: null
    assignmentIndex: null
    weeklyRowSpecificationId: null
    # The currently shown equity pack
    equityPack: null
    # Specifies the last run script step that is shown in the step result inspector
    lastRunStep: null
    # Inspector dock width
    dockWidth: 350
    dockMinimized: false
    # Calendar visibility
    showCalendars: true

  toggleMultiSelection: (property, values) ->
    currentValues = $A(@get property)
    for value in values
      if (idx = currentValues.indexOf value) >= 0
        currentValues.splice idx, 1
      else
        currentValues.push value

    newContext = {}
    newContext[property] = currentValues
    @set newContext

  toggleHighlightedResource: (resource) ->
    if @get "multiSelect"
      @toggleMultiSelection "highlightedResources", [resource]
    else
      if @get "highlightedResource" == resource
        @set highlightedResource: null
      else
        @set highlightedResource: resource

class AssignmentInspectorContext extends CoffeeMVC.Model
  default:
    showAssignedResources: true
    showAvailableResources: true
    showUnavailableResources: false
    showUnskilledResources: false

class EquityInspectorContext extends CoffeeMVC.Model
  default:
    selectedLabels: []
    showUnskilledResources: false

class StepResultInspectorContext extends CoffeeMVC.Model
  default:
    step: null

class ScriptResultInspectorContext extends CoffeeMVC.Model
  default:
    script: null

class MultiAssignmentInspectorContext extends CoffeeMVC.Model
  default:
    showSkilledResources: true
    showUnskilledResources: false