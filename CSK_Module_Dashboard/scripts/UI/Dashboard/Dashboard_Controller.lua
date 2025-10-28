---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the Dashboard_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_Dashboard'

-- Timer to update UI via events after page was loaded
local tmrDashboard = Timer.create()
tmrDashboard:setExpirationTime(300)
tmrDashboard:setPeriodic(false)

-- Reference to global handle
local dashboard_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_Dashboard.OnNewStatusModuleVersion', 'Dashboard_OnNewStatusModuleVersion')
Script.serveEvent('CSK_Dashboard.OnNewStatusCSKStyle', 'Dashboard_OnNewStatusCSKStyle')
Script.serveEvent('CSK_Dashboard.OnNewStatusModuleIsActive', 'Dashboard_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_Dashboard.OnNewLabels', 'Dashboard_OnNewLabels')

Script.serveEvent('CSK_Dashboard.OnNewStatusSourceEvents', 'Dashboard_OnNewStatusSourceEvents')
Script.serveEvent('CSK_Dashboard.OnNewStatusSourceEventsDataPosition', 'Dashboard_OnNewStatusSourceEventsDataPosition')

Script.serveEvent('CSK_Dashboard.OnNewDataTypes', 'Dashboard_OnNewDataTypes')

Script.serveEvent('CSK_Dashboard.OnNewData', 'Dashboard_OnNewData')
Script.serveEvent('CSK_Dashboard.OnNewDataNumbers', 'Dashboard_OnNewDataNumbers')

Script.serveEvent('CSK_Dashboard.OnNewDataStatus', 'Dashboard_OnNewDataStatus')

Script.serveEvent('CSK_Dashboard.OnNewStatusGaugeMinimums', 'Dashboard_OnNewStatusGaugeMinimums')
Script.serveEvent('CSK_Dashboard.OnNewStatusGaugeMaximums', 'Dashboard_OnNewStatusGaugeMaximums')
Script.serveEvent('CSK_Dashboard.OnNewStatusGaugeDigits', 'Dashboard_OnNewStatusGaugeDigits')

Script.serveEvent('CSK_Dashboard.OnNewGaugeUnit', 'Dashboard_OnNewGaugeUnit')

--Script.serveEvent('CSK_Dashboard.OnNewData', 'Dashboard_OnNewDataNUMBERS')

--Script.serveEvent('CSK_Dashboard.OnNewStatusEventToRegister', 'Dashboard_OnNewStatusEventToRegister')

Script.serveEvent('CSK_Dashboard.OnNewStatusFlowConfigPriority', 'Dashboard_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_Dashboard.OnNewStatusLoadParameterOnReboot", "Dashboard_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_Dashboard.OnPersistentDataModuleAvailable", "Dashboard_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_Dashboard.OnNewParameterName", "Dashboard_OnNewParameterName")
Script.serveEvent("CSK_Dashboard.OnDataLoadedOnReboot", "Dashboard_OnDataLoadedOnReboot")

Script.serveEvent('CSK_Dashboard.OnUserLevelOperatorActive', 'Dashboard_OnUserLevelOperatorActive')
Script.serveEvent('CSK_Dashboard.OnUserLevelMaintenanceActive', 'Dashboard_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_Dashboard.OnUserLevelServiceActive', 'Dashboard_OnUserLevelServiceActive')
Script.serveEvent('CSK_Dashboard.OnUserLevelAdminActive', 'Dashboard_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("Dashboard_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("Dashboard_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("Dashboard_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("Dashboard_OnUserLevelAdminActive", status)
end

--- Function to get access to the dashboard_Model object
---@param handle handle Handle of dashboard_Model object
local function setDashboard_Model_Handle(handle)
  dashboard_Model = handle
  if dashboard_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if dashboard_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("Dashboard_OnUserLevelAdminActive", true)
    Script.notifyEvent("Dashboard_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("Dashboard_OnUserLevelServiceActive", true)
    Script.notifyEvent("Dashboard_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrDashboard()

  updateUserLevel()

  Script.notifyEvent("Dashboard_OnNewStatusModuleVersion", 'v' .. dashboard_Model.version)
  Script.notifyEvent("Dashboard_OnNewStatusCSKStyle", dashboard_Model.styleForUI)
  Script.notifyEvent("Dashboard_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    Script.notifyEvent('Dashboard_OnNewDataTypes', dashboard_Model.parameters.dataTypes)

    Script.notifyEvent('Dashboard_OnNewData', dashboard_Model.data)
    Script.notifyEvent('Dashboard_OnNewDataNumbers', dashboard_Model.dataNumbers)
    Script.notifyEvent('Dashboard_OnNewDataStatus', dashboard_Model.dataStatus)

    Script.notifyEvent('Dashboard_OnNewStatusGaugeMinimums', dashboard_Model.parameters.gaugeMinimum)
    Script.notifyEvent('Dashboard_OnNewStatusGaugeMaximums', dashboard_Model.parameters.gaugeMaximum)
    Script.notifyEvent('Dashboard_OnNewStatusGaugeDigits', dashboard_Model.parameters.gaugeDigits)

    Script.notifyEvent('Dashboard_OnNewGaugeUnit', '')

    Script.notifyEvent('Dashboard_OnNewLabels', dashboard_Model.parameters.labels)
    Script.notifyEvent('Dashboard_OnNewStatusSourceEvents', dashboard_Model.parameters.events)
    Script.notifyEvent('Dashboard_OnNewStatusSourceEventsDataPosition', dashboard_Model.parameters.parameterPositions)

    Script.notifyEvent("Dashboard_OnNewStatusFlowConfigPriority", dashboard_Model.parameters.flowConfigPriority)
    Script.notifyEvent("Dashboard_OnNewStatusLoadParameterOnReboot", dashboard_Model.parameterLoadOnReboot)
    Script.notifyEvent("Dashboard_OnPersistentDataModuleAvailable", dashboard_Model.persistentModuleAvailable)
    Script.notifyEvent("Dashboard_OnNewParameterName", dashboard_Model.parametersName)
  end
end
Timer.register(tmrDashboard, "OnExpired", handleOnExpiredTmrDashboard)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrDashboard:start()
  return ''
end
Script.serveFunction("CSK_Dashboard.pageCalled", pageCalled)

local function setEventToRegister(dataID, event, parameterPos)
  if dashboard_Model.parameters.events[dataID] then
    Script.deregister(dashboard_Model.parameters.events[dataID], dashboard_Model.updateFunctions[dataID])
  end
  dashboard_Model.parameters.events[dataID] = event
  dashboard_Model.parameters.parameterPositions[dataID] = parameterPos

  if event ~= '' then
    Script.register(dashboard_Model.parameters.events[dataID], dashboard_Model.updateFunctions[dataID])
  end
end
Script.serveFunction('CSK_Dashboard.setEventToRegister', setEventToRegister)

--[[local function setLabel(dataID, label)
  dashboard_Model.parameters.labels[dataID] = label
  Script.notifyEvent('Dashboard_OnNewLabels', dashboard_Model.parameters.labels)
end
]]
local function setLabel(data)
  local dataID = tonumber(data[2])
  dashboard_Model.parameters.labels[dataID] = data[1]
  Script.notifyEvent('Dashboard_OnNewLabels', dashboard_Model.parameters.labels)
end
Script.serveFunction('CSK_Dashboard.setLabel', setLabel)

local function setSourceEvent(data)
  local dataID = tonumber(data[2])
  setEventToRegister(dataID, data[1], dashboard_Model.parameters.parameterPositions[dataID])
  Script.notifyEvent('Dashboard_OnNewStatusSourceEvents', dashboard_Model.parameters.events)
end
Script.serveFunction('CSK_Dashboard.setSourceEvent', setSourceEvent)

local function setSourceEventDataPosition(data)
  local dataID = tonumber(data[2])
  dashboard_Model.parameters.parameterPositions[dataID] = data[1]
  Script.notifyEvent('Dashboard_OnNewStatusSourceEventsDataPosition', dashboard_Model.parameters.parameterPositions)
end
Script.serveFunction('CSK_Dashboard.setSourceEventDataPosition', setSourceEventDataPosition)

local function setDataType(dataType)
  local dataID = tonumber(dataType[2])
  dashboard_Model.parameters.dataTypes[dataID] = dataType[1]
  Script.notifyEvent('Dashboard_OnNewDataTypes', dashboard_Model.parameters.dataTypes)
end
Script.serveFunction('CSK_Dashboard.setDataType', setDataType)

local function setGaugeMinimum(value)
  dashboard_Model.parameters.gaugeMinimum[value[2]] = value[1]
  Script.notifyEvent('Dashboard_OnNewStatusGaugeMinimums', dashboard_Model.parameters.gaugeMinimum)
end
Script.serveFunction('CSK_Dashboard.setGaugeMinimum', setGaugeMinimum)

local function setGaugeMaximum(value)
  dashboard_Model.parameters.gaugeMaximum[value[2]] = value[1]
  Script.notifyEvent('Dashboard_OnNewStatusGaugeMaximums', dashboard_Model.parameters.gaugeMaximum)
end
Script.serveFunction('CSK_Dashboard.setGaugeMaximum', setGaugeMaximum)

local function setGaugeDigits(value)
  dashboard_Model.parameters.gaugeDigits[value[2]] = value[1]
  Script.notifyEvent('Dashboard_OnNewStatusGaugeDigits', dashboard_Model.parameters.gaugeDigits)
end
Script.serveFunction('CSK_Dashboard.setGaugeDigits', setGaugeDigits)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_Dashboard.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  -- Insert code here to clear FlowConfig relevant actions
  for id, _ in pairs(dashboard_Model.data) do
    local num = tonumber(id)
    if dashboard_Model.parameters.events[num] then
      Script.deregister(dashboard_Model.parameters.events[num], dashboard_Model.updateFunctions[num])
      dashboard_Model.parameters.events[num] = ''
    end
    dashboard_Model.data[num] = ''
    dashboard_Model.parameters.labels[num] = ''
  end
  Script.notifyEvent('Dashboard_OnNewData', dashboard_Model.data)
  Script.notifyEvent('Dashboard_OnNewLabels', dashboard_Model.parameters.labels)
end
Script.serveFunction('CSK_Dashboard.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return dashboard_Model.helperFuncs.json.encode(dashboard_Model.parameters)
end
Script.serveFunction('CSK_Dashboard.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  dashboard_Model.parametersName = name
end
Script.serveFunction("CSK_Dashboard.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if dashboard_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(dashboard_Model.helperFuncs.convertTable2Container(dashboard_Model.parameters), dashboard_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, dashboard_Model.parametersName, dashboard_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send Dashboard parameters with name '" .. dashboard_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_Dashboard.sendParameters", sendParameters)

local function loadParameters()
  if dashboard_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(dashboard_Model.parametersName)
    if data then
      clearFlowConfigRelevantConfiguration()
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      dashboard_Model.parameters = dashboard_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      for key, value in pairs(dashboard_Model.parameters.events) do
        if value ~= '' then
          Script.register(value, dashboard_Model.updateFunctions[key])
        end
      end

      CSK_Dashboard.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_Dashboard.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  dashboard_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("Dashboard_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_Dashboard.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  dashboard_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("Dashboard_OnNewStatusFlowConfigPriority", dashboard_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_Dashboard.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')

    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')
      dashboard_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        dashboard_Model.parametersName = parameterName
        dashboard_Model.parameterLoadOnReboot = loadOnReboot
      end

      if dashboard_Model.parameterLoadOnReboot then
        loadParameters()
      end
      Script.notifyEvent('Dashboard_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_Dashboard.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setDashboard_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

