---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_Dashboard'

local dashboard_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
dashboard_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
dashboard_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
dashboard_Model.parametersName = 'CSK_Dashboard_Parameter' -- name of parameter dataset to be used for this module
dashboard_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the Dashboard_Model interface and give access
-- to the Dashboard_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setDashboard_ModelHandle = require('UI/Dashboard/Dashboard_Controller')
setDashboard_ModelHandle(dashboard_Model)

--Loading helper functions if needed
dashboard_Model.helperFuncs = require('UI/Dashboard/helper/funcs')

-- Create parameters / instances for this module
dashboard_Model.styleForUI = 'None' -- Optional parameter to set UI style
dashboard_Model.version = Engine.getCurrentAppVersion() -- Version of module

dashboard_Model.labels = {} -- Current labels to show on dashboard
dashboard_Model.data = {} -- Current data to show on dashboard
dashboard_Model.dataNumbers = {} -- Current data numbers to show on dashboard
dashboard_Model.dataStatus = {} -- Current data status to show on dashboard
dashboard_Model.updateFunctions = {} -- Internally used functions to update values

-- Parameters to be saved permanently if wanted
dashboard_Model.parameters = {}
dashboard_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
dashboard_Model.parameters.labels = {} -- Labels for Dashboard
dashboard_Model.parameters.events = {} -- Events to receive data to show in dashboard
dashboard_Model.parameters.parameterPositions = {} -- Position of parameters within received events
dashboard_Model.parameters.dataTypes = {} -- Types of data to show
dashboard_Model.parameters.gaugeMinimum = {} -- Types of data to show
dashboard_Model.parameters.gaugeMaximum = {} -- Types of data to show
dashboard_Model.parameters.gaugeDigits = {} -- Types of data to show

for i = 1, 20 do
  dashboard_Model.parameters.labels[i] = ''
  dashboard_Model.data[i] = ''
  dashboard_Model.dataNumbers[i] = 0
  dashboard_Model.dataStatus[i] = false
  dashboard_Model.parameters.dataTypes[i] = 'TEXT'
  dashboard_Model.parameters.gaugeMinimum[i] = 0
  dashboard_Model.parameters.gaugeMaximum[i] = 100
  dashboard_Model.parameters.gaugeDigits[i] = 0
  dashboard_Model.parameters.parameterPositions[i] = 1
  dashboard_Model.parameters.events[i] = ''

  local function updateValue(valueA, valueB, valueC, valueD)
    if dashboard_Model.parameters.parameterPositions[i] == 1 then
      dashboard_Model.data[i] = tostring(valueA)
      if tonumber(valueA) then
        dashboard_Model.dataNumbers[i] = tonumber(valueA)
      elseif type(valueA) == 'boolean' then
        dashboard_Model.dataStatus[i] = valueA
      elseif valueA == 'true' then
        dashboard_Model.dataStatus[i] = true
      elseif valueA == 'false' then
        dashboard_Model.dataStatus[i] = false
      end
    elseif dashboard_Model.parameters.parameterPositions[i] == 2 then
      dashboard_Model.data[i] = tostring(valueB)
      if tonumber(valueB) then
        dashboard_Model.dataNumbers[i] = tonumber(valueB)
      elseif type(valueB) == 'boolean' then
        dashboard_Model.dataStatus[i] = valueB
      elseif valueB == 'true' then
        dashboard_Model.dataStatus[i] = true
      elseif valueB == 'false' then
        dashboard_Model.dataStatus[i] = false
      end
    elseif dashboard_Model.parameters.parameterPositions[i] == 3 then
      dashboard_Model.data[i] = tostring(valueC)
      if tonumber(valueC) then
        dashboard_Model.dataNumbers[i] = tonumber(valueC)
      elseif type(valueC) == 'boolean' then
        dashboard_Model.dataStatus[i] = valueC
      elseif valueC == 'true' then
        dashboard_Model.dataStatus[i] = true
      elseif valueC == 'false' then
        dashboard_Model.dataStatus[i] = false
      end
    elseif dashboard_Model.parameters.parameterPositions[i] == 4 then
      dashboard_Model.data[i] = tostring(valueD)
      if tonumber(valueD) then
        dashboard_Model.dataNumbers[i] = tonumber(valueD)
      elseif type(valueD) == 'boolean' then
        dashboard_Model.dataStatus[i] = valueD
      elseif valueD == 'true' then
        dashboard_Model.dataStatus[i] = true
      elseif valueD == 'false' then
        dashboard_Model.dataStatus[i] = false
      end
    end
    Script.notifyEvent('Dashboard_OnNewData', dashboard_Model.data)
    Script.notifyEvent('Dashboard_OnNewDataNumbers', dashboard_Model.dataNumbers)
    Script.notifyEvent('Dashboard_OnNewDataStatus', dashboard_Model.dataStatus)
  end
  table.insert(dashboard_Model.updateFunctions, updateValue)
end

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  dashboard_Model.styleForUI = theme
  Script.notifyEvent("Dashboard_OnNewStatusCSKStyle", dashboard_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return dashboard_Model
