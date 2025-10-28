-- Block namespace
local BLOCK_NAMESPACE = 'Dashboard_FC.UpdateValue'
local nameOfModule = 'CSK_Dashboard'

--*************************************************************
--*************************************************************

local updateUITmr = Timer.create()
updateUITmr:setExpirationTime(500)
updateUITmr:setPeriodic(false)

local function handleOnExpired()
  CSK_Dashboard.pageCalled()
end
Timer.register(updateUITmr, 'OnExpired', handleOnExpired)

-- Required to keep track of already allocated resource
local instanceTable = {}

local function updateValue(handle, source)

  -- Optionally check for specific parameter
  local dataID = Container.get(handle, 'DataID')
  local label = Container.get(handle, 'Label')
  local parameterPos = Container.get(handle, 'ParameterPosition')

  -- Check incoming value
  if source then
    CSK_Dashboard.setLabel({label, tostring(dataID)})
    CSK_Dashboard.setEventToRegister(dataID, source, parameterPos)
  end
  updateUITmr:start()
end
Script.serveFunction(BLOCK_NAMESPACE .. '.updateValue', updateValue)

--*************************************************************
--*************************************************************

local function create(label, dataID, parameterPos)

  -- Check for multiple instances if same instance is already configured
  if instanceTable[dataID] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[dataID] = dataID

    Container.add(handle, 'DataID', dataID)
    Container.add(handle, 'Label', label)
    Container.add(handle, 'ParameterPosition', parameterPos or 1)
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)