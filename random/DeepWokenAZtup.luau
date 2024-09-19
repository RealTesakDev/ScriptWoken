local keyhandler = require(game.ReplicatedStorage:WaitForChild("Modules", math.huge):WaitForChild("ClientManager", math.huge):WaitForChild("KeyHandler", math.huge))

local stack = debug.getupvalue(getrawmetatable(debug.getupvalue(keyhandler, 8)).__index, 1)[1][1]
local GetKey = stack[89]
local key = stack[64]
getupvalue(GetKey, 2)[0][1][2][4] = "HtttpGet"
local is_synapse_function = isexecutorclosure

local setRP = function() end
local destroyRP = function() end
---@diagnostic disable: invalid-class-name
print("lol")
local statusEvent = getgenv().ah_statusEvent;

local function setStatus(...)
    if (not statusEvent) then return end;
    statusEvent:Fire(...);
end;


getgenv().aztupHubV3Ran = true;
getgenv().aztupHubV3RanReal = true;

local originalFunctions = {};
local HttpService = game:GetService('HttpService');


if (not game:IsLoaded()) then
    setStatus('Waiting for game to load');
    game.Loaded:Wait();
end;

--setreadonly(syn, false);

local oldRequest = clonefunction(request);
local gameId = game.GameId;

local LocalPlayer = game:GetService('Players').LocalPlayer;
originalFunctions.getRankInGroup = clonefunction(LocalPlayer.GetRankInGroup);

local websiteKey, scriptKey = getgenv().websiteKey, getgenv().scriptKey;
local jobId, placeId = game.JobId, game.PlaceId;

local userId = LocalPlayer.UserId;
local isUserTrolled = false;
local accountData;
local scriptVersion;

jsonEncode = HttpService.JSONEncode
jsonDecode = HttpService.JSONDecode
findFirstChild = game.FindFirstChild

local sharedRequires = {};



setStatus('All done', true);
sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'] = (function()
	
	--- Lua-side duplication of the API of events on Roblox objects.
	-- Signals are needed for to ensure that for local events objects are passed by
	-- reference rather than by value where possible, as the BindableEvent objects
	-- always pass signal arguments by value, meaning tables will be deep copied.
	-- Roblox's deep copy method parses to a non-lua table compatable format.
	-- @classmod Signal
	
	local Signal = {}
	Signal.__index = Signal
	Signal.ClassName = "Signal"
	
	--- Constructs a new signal.
	-- @constructor Signal.new()
	-- @treturn Signal
	function Signal.new()
		local self = setmetatable({}, Signal)
	
		self._bindableEvent = Instance.new("BindableEvent")
		self._argData = nil
		self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil
	
		return self
	end
	
	function Signal.isSignal(object)
		return typeof(object) == 'table' and getmetatable(object) == Signal;
	end;
	
	--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
	-- Roblox signal conventions.
	-- @param ... Variable arguments to pass to handler
	-- @treturn nil
	function Signal:Fire(...)
		self._argData = {...}
		self._argCount = select("#", ...)
		self._bindableEvent:Fire()
		self._argData = nil
		self._argCount = nil
	end
	
	--- Connect a new handler to the event. Returns a connection object that can be disconnected.
	-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
	-- @treturn Connection Connection object that can be disconnected
	function Signal:Connect(handler)
		if not self._bindableEvent then return error("Signal has been destroyed"); end --Fixes an error while respawning with the UI injected
	
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end
	
		return self._bindableEvent.Event:Connect(function()
			handler(unpack(self._argData, 1, self._argCount))
		end)
	end
	
	--- Wait for fire to be called, and return the arguments it was given.
	-- @treturn ... Variable arguments from connection
	function Signal:Wait()
		self._bindableEvent.Event:Wait()
		assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
		return unpack(self._argData, 1, self._argCount)
	end
	
	--- Disconnects all connected events to the signal. Voids the signal as unusable.
	-- @treturn nil
	function Signal:Destroy()
		if self._bindableEvent then
			self._bindableEvent:Destroy()
			self._bindableEvent = nil
		end
	
		self._argData = nil
		self._argCount = nil
	end
	
	return Signal
end)();

sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'] = (function()
	
	---	Manages the cleaning of events and other things.
	-- Useful for encapsulating state and make deconstructors easy
	-- @classmod Maid
	-- @see Signal
	
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	local tableStr = "table";
	local classNameStr = "Maid";
	local funcStr = "function";
	local threadStr = "thread";
	
	local Maid = {}
	Maid.ClassName = "Maid"
	
	--- Returns a new Maid object
	-- @constructor Maid.new()
	-- @treturn Maid
	function Maid.new()
		return setmetatable({
			_tasks = {}
		}, Maid)
	end
	
	function Maid.isMaid(value)
		return type(value) == tableStr and value.ClassName == classNameStr
	end
	
	--- Returns Maid[key] if not part of Maid metatable
	-- @return Maid[key] value
	function Maid.__index(self, index)
		if Maid[index] then
			return Maid[index]
		else
			return self._tasks[index]
		end
	end
	
	--- Add a task to clean up. Tasks given to a maid will be cleaned when
	--  maid[index] is set to a different value.
	-- @usage
	-- Maid[key] = (function)         Adds a task to perform
	-- Maid[key] = (event connection) Manages an event connection
	-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
	-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
	-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
	--                                it is destroyed.
	function Maid:__newindex(index, newTask)
		if Maid[index] ~= nil then
			error(("'%s' is reserved"):format(tostring(index)), 2)
		end
	
		local tasks = self._tasks
		local oldTask = tasks[index]
	
		if oldTask == newTask then
			return
		end
	
		tasks[index] = newTask
	
		if oldTask then
			if type(oldTask) == "function" then
				oldTask()
			elseif typeof(oldTask) == "RBXScriptConnection" then
				oldTask:Disconnect();
			elseif typeof(oldTask) == 'table' then
				oldTask:Remove();
			elseif (Signal.isSignal(oldTask)) then
				oldTask:Destroy();
			elseif (typeof(oldTask) == 'thread') then
				task.cancel(oldTask);
			elseif oldTask.Destroy then
				oldTask:Destroy();
			end
		end
	end
	
	--- Same as indexing, but uses an incremented number as a key.
	-- @param task An item to clean
	-- @treturn number taskId
	function Maid:GiveTask(task)
		if not task then
			error("Task cannot be false or nil", 2)
		end
	
		local taskId = #self._tasks+1
		self[taskId] = task
	
		return taskId
	end
	
	--- Cleans up all tasks.
	-- @alias Destroy
	function Maid:DoCleaning()
		local tasks = self._tasks
	
		-- Disconnect all events first as we know this is safe
		for index, task in pairs(tasks) do
			if typeof(task) == "RBXScriptConnection" then
				tasks[index] = nil
				task:Disconnect()
			end
		end
	
		-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
		local index, taskData = next(tasks)
		while taskData ~= nil do
			tasks[index] = nil
			if type(taskData) == funcStr then
				taskData()
			elseif typeof(taskData) == "RBXScriptConnection" then
				taskData:Disconnect()
			elseif (Signal.isSignal(taskData)) then
				taskData:Destroy();
			elseif typeof(taskData) == tableStr then
				taskData:Remove();
			elseif (typeof(taskData) == threadStr) then
				task.cancel(taskData);
			elseif taskData.Destroy then
				taskData:Destroy()
			end
			index, taskData = next(tasks)
		end
	end
	
	--- Alias for DoCleaning()
	-- @function Destroy
	Maid.Destroy = Maid.DoCleaning
	
	return Maid;
end)();

sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'] = (function()
	
	local Services = {};
	local vim = getvirtualinputmanager and getvirtualinputmanager();
	
	function Services:Get(...)
	    local allServices = {};
	
	    for _, service in next, {...} do
	        table.insert(allServices, self[service]);
	    end
	
	    return unpack(allServices);
	end;
	
	setmetatable(Services, {
	    __index = function(self, p)
	        if (p == 'VirtualInputManager' and vim) then
	            return vim;
	        end;
	
	        local service = game:GetService(p);
	        if (p == 'VirtualInputManager') then
	            service.Name = "VirtualInputManager ";
	        end;
	
	        rawset(self, p, service);
	        return rawget(self, p);
	    end,
	});
	
	return Services;
end)();

sharedRequires['033acf99ef958056f4fdb09f61b779b3a7cbab225ad1d01917ba377dace933c8'] = (function()
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local UserInputService = Services:Get('UserInputService');
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	
	local keybindVisualizer = {};
	keybindVisualizer.__index = keybindVisualizer;
	
	local viewportSize = workspace.CurrentCamera.ViewportSize;
	local library;
	
	function keybindVisualizer.new()
	    local self = setmetatable({}, keybindVisualizer);
	
	    self._textSizes = {};
	    self._maid = Maid.new();
	
	    self:_init();
	
	    local dragObject;
	    local dragging;
	    local dragStart;
	    local startPos;
	
	    self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
	        if (input.UserInputType == Enum.UserInputType.MouseButton1 and self:MouseInFrame()) then
	            dragObject = self._textBox
	            dragging = true
	            dragStart = input.Position
	            startPos = dragObject.Position
	        end;
	    end));
	
	    self._maid:GiveTask(UserInputService.InputChanged:connect(function(input)
	        if dragging and input.UserInputType.Name == 'MouseMovement' and not self._destroyed then
	            if dragging then
	                local delta = input.Position - dragStart;
	                local yPos = (startPos.Y + delta.Y) < -36 and -36 or startPos.Y + delta.Y;
	
	                self._textBox.Position = Vector2.new(startPos.X + delta.X,  yPos);
	                library.configVars.keybindVisualizerPos = tostring(self._textBox.Position);
	            end;
	        end;
	    end));
	
	    self._maid:GiveTask(UserInputService.InputEnded:connect(function(input)
	        if input.UserInputType.Name == 'MouseButton1' then
	            dragging = false
	        end
	    end));
	
	    library.OnLoad:Connect(function()
	        if (not library.configVars.keybindVisualizerPos) then return end;
	        self._textBox.Position = Vector2.new(unpack(library.configVars.keybindVisualizerPos:split(',')));
	    end);
	
	    return self;
	end;
	
	function keybindVisualizer:_getTextBounds(text, fontSize)
	    local t = Drawing.new('Text');
	    t.Text = text;
	    t.Size = fontSize;
	
	    local res = t.TextBounds;
	    t:Remove();
	    return res.X;
	end;
	
	function keybindVisualizer:_createDrawingInstance(instanceType, properties)
	    local instance = Drawing.new(instanceType);
	
	    if (properties.Visible == nil) then
	        properties.Visible = true;
	    end;
	
	    for i,  v in next,  properties do
	        instance[i] = v;
	    end;
	
	    return instance;
	end;
	
	function keybindVisualizer:_init()
	    self._textBox = self:_createDrawingInstance('Text', {
	        Size = 30,
	        Position = viewportSize-Vector2.new(180, viewportSize.Y/2),
	        Color = Color3.new(255, 255, 255)
	    });
	end
	
	function keybindVisualizer:GetLargest()
	    table.sort(self._textSizes, function(a, b) return a.magnitude>b.magnitude; end)
	    return self._textSizes[1] or Vector2.new(0, 30);
	end
	
	function keybindVisualizer:AddText(txt)
	    if (self._destroyed) then return end;
	    self._largest = self:GetLargest();
	
	    local tab = string.split(self._textBox.Text, '\n');
	    if (table.find(tab, txt)) then return end;
	
	    local textSize = Vector2.new(self:_getTextBounds(txt, 30), 30);
	    table.insert(self._textSizes, textSize);
	
	    table.insert(tab, txt);
	    table.sort(tab, function(a, b) return #a < #b; end)
	
	    self._textBox.Text = table.concat(tab, '\n');
	    self._textBox.Position -= Vector2.new(0, 30);
	end
	
	function keybindVisualizer:MouseInFrame()
		local mousePos = UserInputService:GetMouseLocation();
		local framePos = self._textBox.Position;
		local bottomRight = framePos + self._textBox.TextBounds
	
		return (mousePos.X >= framePos.X and mousePos.X <= bottomRight.X) and (mousePos.Y >= framePos.Y and mousePos.Y <= bottomRight.Y)
	end;
	
	function keybindVisualizer:RemoveText(txt)
	    if (self._destroyed) then return end;
	    local textSize = Vector2.new(self:_getTextBounds(txt, 30), 30);
		table.remove(self._textSizes, table.find(self._textSizes,  textSize));
	
	    self._largest = self:GetLargest();
	
	    local tab = string.split(self._textBox.Text, '\n');
	    table.remove(tab, table.find(tab, txt));
	
	    self._textBox.Text = table.concat(tab, '\n');
	    self._textBox.Position += Vector2.new(0, 30);
	end
	
	function keybindVisualizer:UpdateColor(color)
	    if (self._destroyed) then return end;
	    self._textBox.Color = color;
	end;
	
	function keybindVisualizer:SetEnabled(state)
	    if (self._destroyed) then return end;
	    self._textBox.Visible = state;
	end;
	
	function keybindVisualizer:Remove()
	    self._destroyed = true;
	    self._maid:Destroy();
	    self._textBox:Remove();
	end;
	
	function keybindVisualizer.init(newLibrary)
	    library = newLibrary;
	end;
	
	return keybindVisualizer;
end)();

sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'] = (function()
	
	local stringPattern = "%s(.)";
	return function (text)
	    return string.lower(text):gsub(stringPattern, string.upper);
	end;
end)();

sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'] = (function()
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	
	local TweenService, UserInputService = Services:Get('TweenService', 'UserInputService');
	
	local Notifications = {};
	
	local Notification = {};
	Notification.__index = Notification;
	Notification.NotifGap = 40;
	
	local viewportSize = workspace.CurrentCamera.ViewportSize;
	
	local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad);
	local VALUE_NAMES = {
	    number = 'NumberValue',
	    Color3 = 'Color3Value',
	    Vector2 = 'Vector3Value',
	};
	
	local movingUpFinished = true;
	local movingDownFinished = true;
	
	local vector2Str = "Vector2";
	local positionStr = "Position";
	
	function Notification.new(options)
	    local self = setmetatable({
	        _options = options
	    }, Notification);
	
	    self._options = options;
	    self._maid = Maid.new();
	
	    self.Destroying = Signal.new();
	
		self._tweens = {};
	    task.spawn(self._init, self);
	
	    return self;
	end;
	
	function Notification:_createDrawingInstance(instanceType, properties)
	    local instance = Drawing.new(instanceType);
	
	    if (properties.Visible == nil) then
	        properties.Visible = true;
	    end;
	
	    for i, v in next, properties do
	        instance[i] = v;
	    end;
	
	    return instance;
	end;
	
	function Notification:_getTextBounds(text, fontSize)
	    local t = Drawing.new('Text');
	    t.Text = text;
	    t.Size = fontSize;
	
	    local res = t.TextBounds;
	    t:Remove();
	    return res.X;
	    -- This is completetly inaccurate but there is no function to get the textbounds on v2; It prob also matter abt screen size but lets ignore that
	    -- return #text * (fontSize / 3.15);
	end;
	
	function Notification:_tweenProperty(instance, property, value, tweenInfo, dontCancel)
	    local currentValue = instance[property]
	    local valueType = typeof(currentValue);
	    local valueObject = Instance.new(VALUE_NAMES[valueType]);
	
	    self._maid:GiveTask(valueObject);
	    if (valueType == vector2Str) then
	        value = Vector3.new(value.X, value.Y, 0);
	        currentValue = Vector3.new(currentValue.X, currentValue.Y, 0);
	    end;
	
	    valueObject.Value = currentValue;
	    local tween = TweenService:Create(valueObject, tweenInfo, {Value = value});
	
		self._tweens[tween] = dontCancel or false;
	
	    self._maid:GiveTask(valueObject:GetPropertyChangedSignal('Value'):Connect(function()
	        local newValue = valueObject.Value;
	
	        if (valueType == vector2Str) then
	            newValue = Vector2.new(newValue.X, newValue.Y);
	        end;
	
			if self._destroyed then return; end
	
	        instance[property] = newValue;
	    end));
	
	    self._maid:GiveTask(tween.Completed:Connect(function()
	        valueObject:Destroy();
			self._tweens[tween] = nil;
	    end));
	
	    tween:Play();
	
	    if (instance == self._progressBar and property == 'Size') then
	        self._maid:GiveTask(tween.Completed:Connect(function(playbackState)
	            if (playbackState ~= Enum.PlaybackState.Completed) then return end;
	            self:Destroy();
	        end));
	    end;
	
	    return tween;
	end;
	
	function Notification:_init()
		self:MoveUp();
	
	    local textSize = Vector2.new(self:_getTextBounds(self._options.text, 19), 30);
	    textSize += Vector2.new(10, 0); -- // Padding
	
	    self._textSize = textSize
	
	    self._frame = self:_createDrawingInstance('Square', {
	        Size = textSize,
	        Position = viewportSize - Vector2.new(-10, textSize.Y+10),
	        Color = Color3.fromRGB(12, 12, 12),
	        Filled = true
	    });
	
	    self._originalPosition = self._frame.Position;
	
	    self._text = self:_createDrawingInstance('Text', {
	        Text = self._options.text,
	        Center = true,
	        Color = Color3.fromRGB(255, 255, 255),
	        Position = self._frame.Position + Vector2.new(textSize.X/2, 5), -- 5 Cuz of the padding
	        Size = 19
	    });
	
	    self._progressBar = self:_createDrawingInstance('Square', {
	        Size = Vector2.new(textSize.X, 3),
	        Color = Color3.fromRGB(86, 180, 211),
	        Filled = true,
	        Position = self._frame.Position+Vector2.new(0, self._frame.Size.Y-3)
	    });
	
		table.insert(Notifications,self); --Insert it into the table we are using to move up
	
	    self._startTime = tick();
	    local framePos = viewportSize - textSize - Vector2.new(10, 10);
	
	    self:_tweenProperty(self._frame, positionStr, framePos, TWEEN_INFO,true);
	    self:_tweenProperty(self._text, positionStr, framePos + Vector2.new(textSize.X/2, 5), TWEEN_INFO,true);
	    local t = self:_tweenProperty(self._progressBar, positionStr, framePos + Vector2.new(0, self._frame.Size.Y-3), TWEEN_INFO, true); --We dont really want this to be cancelable
	
		self._maid._progressConnection = t.Completed:Connect(function() --This should prob use maids lol
			if (self._options.duration) then
				self:_tweenProperty(self._progressBar, 'Size', Vector2.new(0, 3), TweenInfo.new(self._options.duration, Enum.EasingStyle.Linear));
				self:_tweenProperty(self._progressBar, positionStr, framePos - Vector2.new(-self._frame.Size.X, -(self._frame.Size.Y-3)), TweenInfo.new(self._options.duration, Enum.EasingStyle.Linear)); --You should technically remove this after its complete but doesn't matter
			end;
		end)
	end;
	
	
	function Notification:MouseInFrame()
		local mousePos = UserInputService:GetMouseLocation();
		local framePos = self._frame.Position;
		local bottomRight = framePos + self._frame.Size
	
		return (mousePos.X >= framePos.X and mousePos.X <= bottomRight.X) and (mousePos.Y >= framePos.Y and mousePos.Y <= bottomRight.Y)
	end
	
	function Notification:GetHovered()
		for _,notif in next, Notifications do
			if notif:MouseInFrame() then return notif; end
		end
	
		return;
	end
	
	function Notification:MoveUp() --Going to use this to move all the drawing instances up one
	
		if (self._destroyed) then return; end
	
		repeat task.wait() until movingUpFinished;
	
		movingUpFinished = false;
	
		local distanceUp = Vector2.new(0, -self.NotifGap); --This can be made dynamic but I'm not sure if youd rather use screen size or an argument up to you
	
		for i,v in next, Notifications do
			--I mean you can obviously use le tween to make it cleaner
			v:CancelTweens(); --Cancel all current tweens that arent the default
	
			local newFramePos = v._frame.Position+distanceUp;
	
			v._frame.Position = newFramePos;
			v._text.Position = v._text.Position+distanceUp;
			v._progressBar.Position = v._progressBar.Position+distanceUp;
	
	        if (not v._options.duration) then continue end;
	
			local newDuration = v._options.duration-(tick()-v._startTime);
	
			v:_tweenProperty(v._progressBar, 'Size', Vector2.new(0, 3), TweenInfo.new(newDuration, Enum.EasingStyle.Linear));
			v:_tweenProperty(v._progressBar, positionStr, newFramePos - Vector2.new(-v._frame.Size.X, -(v._frame.Size.Y-3)), TweenInfo.new(newDuration, Enum.EasingStyle.Linear));
		end
		movingUpFinished = true;
	end
	
	
	function Notification:MoveDown() --Going to use this to move all the drawing instances up one
	
		if (self._destroyed) then return; end
	
		repeat task.wait() until movingDownFinished;
	
		movingDownFinished = false;
	
		local distanceDown = Vector2.new(0, self.NotifGap); --This can be made dynamic but I'm not sure if youd rather use screen size or an argument up to you
	
		local index = table.find(Notifications,self) or 1;
	
		for i = index, 1,-1 do
			local v = Notifications[i];
	
			v:CancelTweens(); --Cancel all current tweens that arent the default
	
			local newFramePos = v._frame.Position+distanceDown;
	
			v._frame.Position = newFramePos;
			v._text.Position = v._text.Position+distanceDown;
			v._progressBar.Position = v._progressBar.Position+distanceDown;
	
	        if (not v._options.duration) then continue end;
	
			v._startTime = v._startTime or tick();
			local newDuration = v._options.duration-(tick()-v._startTime);
	
			v:_tweenProperty(v._progressBar, 'Size', Vector2.new(0, 3), TweenInfo.new(newDuration, Enum.EasingStyle.Linear));
			v:_tweenProperty(v._progressBar, positionStr, newFramePos - Vector2.new(-v._frame.Size.X, -(v._frame.Size.Y-3)), TweenInfo.new(newDuration, Enum.EasingStyle.Linear));
		end
		movingDownFinished = true;
	end
	
	function Notification:CancelTweens()
		for tween,cancelInfo in next, self._tweens do
			if cancelInfo then
				self._maid._progressConnection = nil;
				tween.Completed:Wait();
				continue;
			end
			tween:Cancel();
		end
	end
	
	function Notification:ClearAllAbove()
		local index = table.find(Notifications,self);
	
		for i = 1, index do
			task.spawn(function()
				Notifications[i]:Destroy();
			end)
		end
	end
	
	function Notification:Remove()
		table.remove(Notifications,table.find(Notifications,self)); --We kind of want to use this and kind of don't its causing ALOT of issues with a large amount of things, but it also fixes the order issue gl
	end
	
	function Notification:Destroy()
	    -- // TODO: Use a maid in the future
	    if (self._destroyFixed) then return; end;
	    self._destroyFixed = true;
	
	    self.Destroying:Fire();
	
	    local framePos = self._originalPosition;
	    local textSize = self._textSize;
	
		self:CancelTweens();
	
	    self:_tweenProperty(self._frame, positionStr, framePos, TWEEN_INFO,true);
	    self:_tweenProperty(self._text, positionStr, framePos + Vector2.new(textSize.X/2, 5), TWEEN_INFO,true);
	    self:_tweenProperty(self._progressBar, positionStr, framePos + Vector2.new(0, self._frame.Size.Y-3), TWEEN_INFO,true).Completed:Wait();
	
		self:MoveDown();
	
		self:Remove();
	
	    self._destroyed = true;
	
	    self._frame:Remove();
		self._text:Remove();
		self._progressBar:Remove();
	end;
	
	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then  --Clear just that one
			local notif = Notification:GetHovered();
			if notif then
				notif:Destroy();
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then --Clear all above it
			local notif = Notification:GetHovered();
			if notif then
				notif:ClearAllAbove();
			end
		end
	end
	
	UserInputService.InputBegan:Connect(onInputBegan)
	
	return Notification;
end)();

sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'] = (function()
	
	
	-- // Services
	
	local libraryLoadAt = tick();
	
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local KeyBindVisualizer = sharedRequires['033acf99ef958056f4fdb09f61b779b3a7cbab225ad1d01917ba377dace933c8'];
	
	local CoreGui, Players, RunService, TextService, UserInputService, ContentProvider, HttpService, TweenService, GuiService, TeleportService = Services:Get('CoreGui', 'Players', 'RunService', 'TextService', 'UserInputService', 'ContentProvider', 'HttpService', 'TweenService', 'GuiService', 'TeleportService');
	
	local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local ToastNotif = sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'];
	
	local LocalPlayer = Players.LocalPlayer;
	local visualizer;
	
	if getgenv().library then
		getgenv().library:Unload();
	end;
	

	if (not isfile('Aztup Hub V3')) then
	    makefolder('Aztup Hub V3');
	end;

	if (not isfile('Aztup Hub V3/configs')) then
	    makefolder('Aztup Hub V3/configs');
	end;
	
	if (not isfile('Aztup Hub V3/configs/globalConf.bin')) then
	    -- By default global config is turned on
	    writefile('Aztup Hub V3/configs/globalConf.bin', 'true');
	end;
	
	local globalConfFilePath = 'Aztup Hub V3/configs/globalConf.bin';
	local isGlobalConfigOn = readfile(globalConfFilePath) == 'true';
	
	local library = {
	    unloadMaid = Maid.new(),
		tabs = {},
		draggable = true,
		flags = {},
		title = string.format('Aztup Hub | v%s', 'DEBUG'),
		open = false,
		popup = nil,
		instances = {},
		connections = {},
		options = {},
		notifications = {},
	    configVars = {},
		tabSize = 0,
		theme = {},
		foldername =  isGlobalConfigOn and 'Aztup Hub V3/configs/global' or string.format('Aztup Hub V3/configs/%s', tostring(LocalPlayer.UserId)),
		fileext = ".json",
	    chromaColor = Color3.new()
	}
	
	library.originalTitle = library.title;
	
	do -- // Load
	    library.unloadMaid:GiveTask(task.spawn(function()
	        while true do
	            for i = 1, 360 do
	                library.chromaColor = Color3.fromHSV(i / 360, 1, 1);
	                task.wait(0.1);
	            end;
	        end;
	    end));
	
	    -- if(debugMode) then
	        getgenv().library = library
	    -- end;
	
	    library.OnLoad = Signal.new();
	    library.OnKeyPress = Signal.new();
	    library.OnKeyRelease = Signal.new();
	
	    library.OnFlagChanged = Signal.new();
	
	    KeyBindVisualizer.init(library);
	
	    library.unloadMaid:GiveTask(library.OnLoad);
	    library.unloadMaid:GiveTask(library.OnKeyPress);
	    library.unloadMaid:GiveTask(library.OnKeyRelease);
	    library.unloadMaid:GiveTask(library.OnFlagChanged);
	
	    visualizer = KeyBindVisualizer.new();
	    local mouseMovement = Enum.UserInputType.MouseMovement;
	
	    --Locals
	    local dragging, dragInput, dragStart, startPos, dragObject
	
	    local blacklistedKeys = { --add or remove keys if you find the need to
	        Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Escape
	    }
	    local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
	        Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
	    }
	
	    local function onInputBegan(input, gpe)
	        local inputType = input.UserInputType;
	        if (inputType == mouseMovement) then return end;
	
	        if (UserInputService:GetFocusedTextBox()) then return end;
	        local inputKeyCode = input.KeyCode;
	
	        local fastInputObject = {
	            KeyCode = {
	                Name = inputKeyCode.Name,
	                Value = inputKeyCode.Value
	            },
	
	            UserInputType = {
	                Name = inputType.Name,
	                Value = inputType.Value
	            },
	
	            UserInputState = input.UserInputState,
	            realKeyCode = inputKeyCode,
	            realInputType = inputType
	        };
	
	        library.OnKeyPress:Fire(fastInputObject, gpe);
	    end;
	
	    local function onInputEnded(input)
	        local inputType = input.UserInputType;
	        if (inputType == mouseMovement) then return end;
	
	        local inputKeyCode = input.KeyCode;
	
	        local fastInputObject = {
	            KeyCode = {
	                Name = inputKeyCode.Name,
	                Value = inputKeyCode.Value
	            },
	
	            UserInputType = {
	                Name = inputType.Name,
	                Value = inputType.Value
	            },
	
	            UserInputState = input.UserInputState,
	            realKeyCode = inputKeyCode,
	            realInputType = inputType
	        };
	
	        library.OnKeyRelease:Fire(fastInputObject);
	    end;
	
	    library.unloadMaid:GiveTask(UserInputService.InputBegan:Connect(onInputBegan));
	    library.unloadMaid:GiveTask(UserInputService.InputEnded:Connect(onInputEnded));
	
	    local function makeTooltip(interest, option)
	        library.unloadMaid:GiveTask(interest.InputChanged:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                    library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36);
	                end;
	            end;
	        end));
	
	        library.unloadMaid:GiveTask(interest.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if option.tip then
	                    library.tooltip.Position = UDim2.fromScale(10, 10);
	                end;
	            end;
	        end));
	    end;
	
	    --Functions
	    library.round = function(num, bracket)
	        bracket = bracket or 1
	        if typeof(num) == "Vector2" then
	            return Vector2.new(library.round(num.X), library.round(num.Y))
	        elseif typeof(num) == "Color3" then
	            return library.round(num.r * 255), library.round(num.g * 255), library.round(num.b * 255)
	        else
	            return num - num % bracket;
	        end
	    end
	
	    function library:Create(class, properties)
	        properties = properties or {}
	        if not class then return end
	        local a = class == 'Square' or class == 'Line' or class == 'Text' or class == 'Quad' or class == 'Circle' or class == 'Triangle'
	        local t = a and Drawing or Instance
	        local inst = t.new(class)
	        for property, value in next, properties do
	            inst[property] = value
	        end
	        table.insert(self.instances, {object = inst, method = a})
	        return inst
	    end
	
	    function library:AddConnection(connection, name, callback)
	        callback = type(name) == 'function' and name or callback
	        connection = connection:Connect(callback)
	        self.unloadMaid:GiveTask(connection);
	        if name ~= callback then
	            self.connections[name] = connection
	        else
	            table.insert(self.connections, connection)
	        end
	        return connection
	    end
	
	    function library:Unload()
	        task.wait();
	        visualizer:Remove();
	
	        for _, o in next, self.options do
	            if o.type == 'toggle' and not string.find(string.lower(o.flag), 'panic') and o.flag ~= 'saveconfigauto' then
	                pcall(o.SetState, o, false);
	            end;
	        end;
	
	        library.unloadMaid:Destroy();
	    end
	
	    local function readFileAndDecodeIt(filePath)
	        if (not isfile(filePath)) then return; end;
	
	        local suc, fileContent = pcall(readfile, filePath);
	        if (not suc) then return; end;
	
	        local suc2, configData = pcall(HttpService.JSONDecode, HttpService, fileContent);
	        if (not suc2) then return; end;
	
	        return configData;
	    end;
	
	    local function getConfigForGame(configData)
	        local configValueName = library.gameName or 'Universal';
	
	        if (not configData[configValueName]) then
	            configData[configValueName] = {};
	        end;
	
	        return configData[configValueName];
	    end;
	
	    function library:LoadConfig(configName)
	        if (not table.find(self:GetConfigs(), configName)) then
	            return;
	        end;
	
	        local filePath = string.format('%s/%s.%s%s', self.foldername, configName, 'config', self.fileext);
	        local configData = readFileAndDecodeIt(filePath);
	        if (not configData) then print('no config', configName); return; end;
	        configData = getConfigForGame(configData);
	
	        -- Set the loaded config to the new config so we save it only when its actually loaded
	        library.loadedConfig = configName;
	        library.options.configList:SetValue(configName);
	
	        for _, option in next, self.options do
	            if (not option.hasInit or option.type == 'button' or not option.flag or option.skipflag) then
	                continue;
	            end;
	
	            local configDataVal = configData[option.flag];
	
	            if (typeof(configDataVal) == 'nil') then
	                continue;
	            end;
	
	            if (option.type == 'toggle') then
	                task.spawn(option.SetState, option, configDataVal == 1);
	            elseif (option.type == 'color') then
	                task.spawn(option.SetColor, option, Color3.fromHex(configDataVal));
	
	                if option.trans then
	                    task.spawn(option.SetTrans, option, configData[option.flag .. 'Transparency']);
	                end;
	            elseif (option.type == 'bind') then
	                task.spawn(option.SetKeys, option, configDataVal);
	            else
	                task.spawn(option.SetValue, option, configDataVal);
	            end;
	        end;
	
	        return true;
	    end;
	
	    function library:SaveConfig(configName)
	        local filePath = string.format('%s/%s.%s%s', self.foldername, configName, 'config', self.fileext);
	        local allConfigData = readFileAndDecodeIt(filePath) or {};
	
	        if (allConfigData.configVersion ~= '1') then
	            allConfigData = {};
	            allConfigData.configVersion = '1';
	        end;
	
	        local configData = getConfigForGame(allConfigData);
	
	        debug.profilebegin('Set config value');
	        for _, option in next, self.options do
	            if (option.type == 'button' or not option.flag) then continue end;
	            if (option.skipflag or option.noSave) then continue end;
	
	            local flag = option.flag;
	
	            if (option.type == 'toggle') then
	                configData[flag] = option.state and 1 or 0;
	            elseif (option.type == 'color') then
	                configData[flag] = option.color:ToHex();
	                if (not option.trans) then continue end;
	                configData[flag .. 'Transparency'] = option.trans;
	            elseif (option.type == 'bind' and option.key ~= 'none') then
	                local toSave = {};
	                for _, v in next, option.keys do
	                    table.insert(toSave, v.Name);
	                end;
	
	                configData[flag] = toSave;
	            elseif (option.type == 'list') then
	                configData[flag] = option.value;
	            elseif (option.type == 'box' and option.value ~= 'nil' and option.value ~= '') then
	                configData[flag] = option.value;
	            else
	                configData[flag] = option.value;
	            end;
	        end;
	        debug.profileend();
	
	        local configVars = library.configVars;
	        configVars.config = configName;
	
	        debug.profilebegin('writefile');
	        writefile(self.foldername .. '/' .. self.fileext, HttpService:JSONEncode(configVars));
	        debug.profileend();
	
	        debug.profilebegin('writefile');
	        writefile(filePath, HttpService:JSONEncode(allConfigData));
	        debug.profileend();
	    end
	
	    function library:GetConfigs()
	        if not isfolder(self.foldername) then
	            makefolder(self.foldername)
	        end
	
	        local configFiles = {};
	
	        for i, v in next, listfiles(self.foldername) do
	            local fileName = v:match('\\(.+)');
	            local fileSubExtension = v:match('%.(.+)%.json');
	
	            if (fileSubExtension == 'config') then
	                table.insert(configFiles, fileName:match('(.-)%.config'));
	            end;
	        end;
	
	        if (not table.find(configFiles, 'default')) then
	            table.insert(configFiles, 'default');
	        end;
	
	        return configFiles;
	    end
	
	    function library:UpdateConfig()
	        if (not library.hasInit) then return end;
	        debug.profilebegin('Config Save');
	
	        library:SaveConfig(library.loadedConfig or 'default');
	
	        debug.profileend();
	    end;
	
	    local function createLabel(option, parent)
	        option.main = library:Create('TextLabel', {
	            LayoutOrder = option.position,
	            Position = UDim2.new(0, 6, 0, 0),
	            Size = UDim2.new(1, -12, 0, 24),
	            BackgroundTransparency = 1,
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextXAlignment = Enum.TextXAlignment.Left,
	            TextYAlignment = Enum.TextYAlignment.Top,
	            TextWrapped = true,
	            RichText = true,
	            Parent = parent
	        })
	
	        setmetatable(option, {__newindex = function(t, i, v)
	            if i == 'Text' then
	                option.main.Text = tostring(v)
	
	                local textSize = TextService:GetTextSize(option.main.ContentText, 15, Enum.Font.Code, Vector2.new(option.main.AbsoluteSize.X, 9e9));
	                option.main.Size = UDim2.new(1, -12, 0, textSize.Y);
	            end
	        end})
	
	        option.Text = option.text
	    end
	
	    local function createDivider(option, parent)
	        option.main = library:Create('Frame', {
	            LayoutOrder = option.position,
	            Size = UDim2.new(1, 0, 0, 18),
	            BackgroundTransparency = 1,
	            Parent = parent
	        })
	
	        library:Create('Frame', {
	            AnchorPoint = Vector2.new(0.5, 0.5),
	            Position = UDim2.new(0.5, 0, 0.5, 0),
	            Size = UDim2.new(1, -24, 0, 1),
	            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
	            BorderColor3 = Color3.new(),
	            Parent = option.main
	        })
	
	        option.title = library:Create('TextLabel', {
	            AnchorPoint = Vector2.new(0.5, 0.5),
	            Position = UDim2.new(0.5, 0, 0.5, 0),
	            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	            BorderSizePixel = 0,
	            TextColor3 =  Color3.new(1, 1, 1),
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextXAlignment = Enum.TextXAlignment.Center,
	            Parent = option.main
	        })
	
	        local interest = option.main;
	        makeTooltip(interest, option);
	
	        setmetatable(option, {__newindex = function(t, i, v)
	            if i == 'Text' then
	                if v then
	                    option.title.Text = tostring(v)
	                    option.title.Size = UDim2.new(0, TextService:GetTextSize(option.title.Text, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 12, 0, 20)
	                    option.main.Size = UDim2.new(1, 0, 0, 18)
	                else
	                    option.title.Text = ''
	                    option.title.Size = UDim2.new()
	                    option.main.Size = UDim2.new(1, 0, 0, 6)
	                end
	            end
	        end})
	        option.Text = option.text
	    end
	
	    local function createToggle(option, parent)
	        option.hasInit = true
	        option.onStateChanged = Signal.new();
	
	        option.main = library:Create('Frame', {
	            LayoutOrder = option.position,
	            Size = UDim2.new(1, 0, 0, 0),
	            BackgroundTransparency = 1,
	            AutomaticSize = Enum.AutomaticSize.Y,
	            Parent = parent
	        })
	
	        local tickbox
	        local tickboxOverlay
	        if option.style then
	            tickbox = library:Create('ImageLabel', {
	                Position = UDim2.new(0, 6, 0, 4),
	                Size = UDim2.new(0, 12, 0, 12),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://3570695787',
	                ImageColor3 = Color3.new(),
	                Parent = option.main
	            })
	
	            library:Create('ImageLabel', {
	                AnchorPoint = Vector2.new(0.5, 0.5),
	                Position = UDim2.new(0.5, 0, 0.5, 0),
	                Size = UDim2.new(1, -2, 1, -2),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://3570695787',
	                ImageColor3 = Color3.fromRGB(60, 60, 60),
	                Parent = tickbox
	            })
	
	            library:Create('ImageLabel', {
	                AnchorPoint = Vector2.new(0.5, 0.5),
	                Position = UDim2.new(0.5, 0, 0.5, 0),
	                Size = UDim2.new(1, -6, 1, -6),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://3570695787',
	                ImageColor3 = Color3.fromRGB(40, 40, 40),
	                Parent = tickbox
	            })
	
	            tickboxOverlay = library:Create('ImageLabel', {
	                AnchorPoint = Vector2.new(0.5, 0.5),
	                Position = UDim2.new(0.5, 0, 0.5, 0),
	                Size = UDim2.new(1, -6, 1, -6),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://3570695787',
	                ImageColor3 = library.flags.menuAccentColor,
	                Visible = option.state,
	                Parent = tickbox
	            })
	
	            library:Create('ImageLabel', {
	                AnchorPoint = Vector2.new(0.5, 0.5),
	                Position = UDim2.new(0.5, 0, 0.5, 0),
	                Size = UDim2.new(1, 0, 1, 0),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://5941353943',
	                ImageTransparency = 0.6,
	                Parent = tickbox
	            })
	
	            table.insert(library.theme, tickboxOverlay)
	        else
	            tickbox = library:Create('Frame', {
	                Position = UDim2.new(0, 6, 0, 4),
	                Size = UDim2.new(0, 12, 0, 12),
	                BackgroundColor3 = library.flags.menuAccentColor,
	                BorderColor3 = Color3.new(),
	                Parent = option.main
	            })
	
	            tickboxOverlay = library:Create('ImageLabel', {
	                Size = UDim2.new(1, 0, 1, 0),
	                BackgroundTransparency = option.state and 1 or 0,
	                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	                BorderColor3 = Color3.new(),
	                Image = 'rbxassetid://4155801252',
	                ImageTransparency = 0.6,
	                ImageColor3 = Color3.new(),
	                Parent = tickbox
	            })
	
	            library:Create('ImageLabel', {
	                Size = UDim2.new(1, 0, 1, 0),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://2592362371',
	                ImageColor3 = Color3.fromRGB(60, 60, 60),
	                ScaleType = Enum.ScaleType.Slice,
	                SliceCenter = Rect.new(2, 2, 62, 62),
	                Parent = tickbox
	            })
	
	            library:Create('ImageLabel', {
	                Size = UDim2.new(1, -2, 1, -2),
	                Position = UDim2.new(0, 1, 0, 1),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://2592362371',
	                ImageColor3 = Color3.new(),
	                ScaleType = Enum.ScaleType.Slice,
	                SliceCenter = Rect.new(2, 2, 62, 62),
	                Parent = tickbox
	            })
	
	            table.insert(library.theme, tickbox)
	        end
	
	        option.interest = library:Create('Frame', {
	            Position = UDim2.new(0, 0, 0, 0),
	            Size = UDim2.new(1, 0, 0, 20),
	            BackgroundTransparency = 1,
	            Parent = option.main
	        })
	
	        option.title = library:Create('TextLabel', {
	            Position = UDim2.new(0, 24, 0, 0),
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Text = option.text,
	            TextColor3 =  option.state and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(180, 180, 180),
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextXAlignment = Enum.TextXAlignment.Left,
	            Parent = option.interest
	        })
	
	        library.unloadMaid:GiveTask(option.interest.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                option:SetState(not option.state)
	            end
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    if option.style then
	                        tickbox.ImageColor3 = library.flags.menuAccentColor
	                    else
	                        tickbox.BorderColor3 = library.flags.menuAccentColor
	                        tickboxOverlay.BorderColor3 = library.flags.menuAccentColor
	                    end
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end))
	
	        makeTooltip(option.interest, option);
	
	        library.unloadMaid:GiveTask(option.interest.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if option.style then
	                    tickbox.ImageColor3 = Color3.new()
	                else
	                    tickbox.BorderColor3 = Color3.new()
	                    tickboxOverlay.BorderColor3 = Color3.new()
	                end
	            end
	        end));
	
	        function option:SetState(state, nocallback)
	            state = typeof(state) == 'boolean' and state
	            state = state or false
	            library.flags[self.flag] = state
	            self.state = state
	            option.title.TextColor3 = state and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(160, 160, 160)
	            if option.style then
	                tickboxOverlay.Visible = state
	            else
	                tickboxOverlay.BackgroundTransparency = state and 1 or 0
	            end
	
	            if not nocallback then
	                task.spawn(self.callback, state);
	            end
	
	            option.onStateChanged:Fire(state);
	            library.OnFlagChanged:Fire(self);
	        end
	
	        task.defer(function()
	            option:SetState(option.state);
	        end);
	
	        setmetatable(option, {__newindex = function(t, i, v)
	            if i == 'Text' then
	                option.title.Text = tostring(v)
	            else
	                rawset(t, i, v);
	            end
	        end})
	    end
	
	    local function createButton(option, parent)
	        option.hasInit = true
	
	        option.main = option.sub and option:getMain() or library:Create('Frame', {
	            LayoutOrder = option.position,
	            Size = UDim2.new(1, 0, 0, 26),
	            BackgroundTransparency = 1,
	            Parent = parent
	        })
	
	        option.title = library:Create('TextLabel', {
	            AnchorPoint = Vector2.new(0.5, 1),
	            Position = UDim2.new(0.5, 0, 1, -5),
	            Size = UDim2.new(1, -12, 0, 18),
	            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	            BorderColor3 = Color3.new(),
	            Text = option.text,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            Parent = option.main
	        })
	
	        if (option.sub) then
	            if (not option.parent.subInit) then
	                option.parent.subInit = true;
	
	                -- If we are a sub option then set some properties of parent
	
	                option.parent.title.Size = UDim2.fromOffset(0, 18);
	
	                option.parent.listLayout = library:Create('UIGridLayout', {
	                    Parent = option.parent.main,
	                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
	                    FillDirection = Enum.FillDirection.Vertical,
	                    VerticalAlignment = Enum.VerticalAlignment.Center,
	                    CellSize = UDim2.new(1 / (#option.main:GetChildren()-1), -8, 0, 18)
	                });
	            end;
	
	            option.parent.listLayout.CellSize = UDim2.new(1 / (#option.parent.main:GetChildren()-1), -8, 0, 18);
	        end;
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.title
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.title
	        })
	
	        library:Create('UIGradient', {
	            Color = ColorSequence.new({
	                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
	                ColorSequenceKeypoint.new(1, Color3.fromRGB(253, 253, 253)),
	            }),
	            Rotation = -90,
	            Parent = option.title
	        })
	
	        library.unloadMaid:GiveTask(option.title.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                option.callback()
	                if library then
	                    library.flags[option.flag] = true
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    option.title.BorderColor3 = library.flags.menuAccentColor;
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end));
	
	        makeTooltip(option.title, option);
	
	        library.unloadMaid:GiveTask(option.title.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                option.title.BorderColor3 = Color3.new();
	            end
	        end));
	    end
	
	    local function createBind(option, parent)
	        option.hasInit = true
	
	        local Loop
	        local maid = Maid.new()
	
	        library.unloadMaid:GiveTask(function()
	            maid:Destroy();
	        end);
	
	        if option.sub then
	            option.main = option:getMain()
	        else
	            option.main = option.main or library:Create('Frame', {
	                LayoutOrder = option.position,
	                Size = UDim2.new(1, 0, 0, 20),
	                BackgroundTransparency = 1,
	                Parent = parent
	            })
	
	            option.title = library:Create('TextLabel', {
	                Position = UDim2.new(0, 6, 0, 0),
	                Size = UDim2.new(1, -12, 1, 0),
	                BackgroundTransparency = 1,
	                Text = option.text,
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextColor3 = Color3.fromRGB(210, 210, 210),
	                TextXAlignment = Enum.TextXAlignment.Left,
	                Parent = option.main
	            })
	        end
	
	        local bindinput = library:Create(option.sub and 'TextButton' or 'TextLabel', {
	            Position = UDim2.new(1, -6 - (option.subpos or 0), 0, option.sub and 2 or 3),
	            SizeConstraint = Enum.SizeConstraint.RelativeYY,
	            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	            BorderSizePixel = 0,
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.fromRGB(160, 160, 160),
	            TextXAlignment = Enum.TextXAlignment.Right,
	            Parent = option.main
	        })
	
	        if option.sub then
	            bindinput.AutoButtonColor = false
	        end
	
	        local interest = option.sub and bindinput or option.main;
	        local maid = Maid.new();
	
	        local function formatKey(key)
	            if (key:match('Mouse')) then
	                key = key:gsub('Button', ''):gsub('Mouse', 'M');
	            elseif (key:match('Shift') or key:match('Alt') or key:match('Control')) then
	                key = key:gsub('Left', 'L'):gsub('Right', 'R');
	            end;
	
	            return key:gsub('Control', 'CTRL'):upper();
	        end;
	
	        local function formatKeys(keys)
	            if (not keys) then return {}; end;
	            local ret = {};
	
	            for _, key in next, keys do
	                table.insert(ret, formatKey(typeof(key) == 'string' and key or key.Name));
	            end;
	
	            return ret;
	        end;
	
	        local busy = false;
	
	        makeTooltip(interest, option);
	
	        library.unloadMaid:GiveTask(interest.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' and not busy then
	                busy = true;
	                library.disableKeyBind = true;
	
	                bindinput.Text = '[...]'
	                bindinput.Size = UDim2.new(0, -TextService:GetTextSize(bindinput.Text, 16, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 16)
	                bindinput.TextColor3 = library.flags.menuAccentColor
	
	                local displayKeys = {};
	                local keys = {};
	
	                maid.keybindLoop = RunService.Heartbeat:Connect(function()
	                    for _, key in next, UserInputService:GetKeysPressed() do
	                        local value = formatKey(key.KeyCode.Name);
	
	                        if (value == 'BACKSPACE') then
	                            maid.keybindLoop = nil;
	                            option:SetKeys('none');
	                            return;
	                        end;
	
	                        if (table.find(displayKeys, value)) then continue; end;
	                        table.insert(displayKeys, value);
	                        table.insert(keys, key.KeyCode);
	                    end;
	
	                    for _, mouseBtn in next, UserInputService:GetMouseButtonsPressed() do
	                        local value = formatKey(mouseBtn.UserInputType.Name);
	
	                        if (option.nomouse) then continue end;
	                        if (not table.find(whitelistedMouseinputs, mouseBtn.UserInputType)) then continue end;
	
	                        if (table.find(displayKeys, value)) then continue; end;
	
	                        table.insert(displayKeys, value);
	                        table.insert(keys, mouseBtn.UserInputType);
	                    end;
	
	                    bindinput.Text = '[' .. table.concat(displayKeys, '+') .. ']';
	
	                    if (#displayKeys == 3) then
	                        maid.keybindLoop = nil;
	                    end;
	                end);
	
	                task.wait(0.05);
	                maid.onInputEnded = UserInputService.InputEnded:Connect(function(input)
	                    if(input.UserInputType ~= Enum.UserInputType.Keyboard and not input.UserInputType.Name:find('MouseButton')) then return; end;
	
	                    maid.keybindLoop = nil;
	                    maid.onInputEnded = nil;
	
	                    option:SetKeys(keys);
	                    library.disableKeyBind = false;
	                    task.wait(0.2);
	                    busy = false;
	                end);
	            end
	        end));
	
	        local function isKeybindPressed()
	            local foundCount = 0;
	
	            for _, key in next, UserInputService:GetKeysPressed() do
	                if (table.find(option.keys, key.KeyCode)) then
	                    foundCount += 1;
	                end;
	            end;
	
	            for _, key in next, UserInputService:GetMouseButtonsPressed() do
	                if (table.find(option.keys, key.UserInputType)) then
	                    foundCount += 1;
	                end;
	            end;
	
	            return foundCount == #option.keys;
	        end;
	
	        local debounce = false;
	
	        function option:SetKeys(keys)
	            if (typeof(keys) == 'string') then
	                keys = {keys};
	            end;
	
	            keys = keys or {option.key ~= 'none' and option.key or nil};
	
	            for i, key in next, keys do
	                if (typeof(key) == 'string' and key ~= 'none') then
	                    local isMouse = key:find('MouseButton');
	
	                    if (isMouse) then
	                        keys[i] = Enum.UserInputType[key];
	                    else
	                        keys[i] = Enum.KeyCode[key];
	                    end;
	                end;
	            end;
	
	            bindinput.TextColor3 = Color3.fromRGB(160, 160, 160)
	
	            if Loop then
	                Loop:Disconnect()
	                Loop = nil;
	                library.flags[option.flag] = false
	                option.callback(true, 0)
	            end
	
	            self.keys = keys;
	
	            if self.keys[1] == 'Backspace' or #self.keys == 0 then
	                self.key = 'none'
	                bindinput.Text = '[NONE]'
	
	                if (#self.keys ~= 0) then
	                    visualizer:RemoveText(self.text);
	                end;
	            else
	                if (self.parentFlag and self.key ~= 'none') then
	                    if (library.flags[self.parentFlag]) then
	                        visualizer:AddText(self.text);
	                    end;
	                end;
	
	                local formattedKey = formatKeys(self.keys);
	                bindinput.Text = '[' .. table.concat(formattedKey, '+') .. ']';
	                self.key = table.concat(formattedKey, '+');
	            end
	
	            bindinput.Size = UDim2.new(0, -TextService:GetTextSize(bindinput.Text, 16, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 16)
	
	            if (self.key == 'none') then
	                maid.onKeyPress = nil;
	                maid.onKeyRelease = nil;
	            else
	                maid.onKeyPress = library.OnKeyPress:Connect(function()
	                    if (library.disableKeyBind or #option.keys == 0 or debounce) then return end;
	                    if (not isKeybindPressed()) then return; end;
	
	                    debounce = true;
	
	                    if option.mode == 'toggle' then
	                        library.flags[option.flag] = not library.flags[option.flag]
	                        option.callback(library.flags[option.flag], 0)
	                    else
	                        library.flags[option.flag] = true
	
	                        if Loop then
	                            Loop:Disconnect();
	                            Loop = nil;
	                            option.callback(true, 0);
	                        end;
	
	                        Loop = library:AddConnection(RunService.Heartbeat, function(step)
	                            if not UserInputService:GetFocusedTextBox() then
	                                option.callback(nil, step)
	                            end
	                        end)
	                    end
	                end);
	
	                maid.onKeyRelease = library.OnKeyRelease:Connect(function()
	                    if (debounce and not isKeybindPressed()) then debounce = false; end;
	                    if (option.mode ~= 'hold') then return; end;
	
	                    local bindKey = option.key;
	                    if (bindKey == 'none') then return end;
	
	                    if not isKeybindPressed() then
	                        if Loop then
	                            Loop:Disconnect()
	                            Loop = nil;
	
	                            library.flags[option.flag] = false
	                            option.callback(true, 0)
	                        end
	                    end
	                end);
	            end;
	        end;
	
	        option:SetKeys();
	    end
	
	    local function createSlider(option, parent)
	        option.hasInit = true
	
	        if option.sub then
	            option.main = option:getMain()
	        else
	            option.main = library:Create('Frame', {
	                LayoutOrder = option.position,
	                Size = UDim2.new(1, 0, 0, option.textpos and 24 or 40),
	                BackgroundTransparency = 1,
	                Parent = parent
	            })
	        end
	
	        option.slider = library:Create('Frame', {
	            Position = UDim2.new(0, 6, 0, (option.sub and 22 or option.textpos and 4 or 20)),
	            Size = UDim2.new(1, -12, 0, 16),
	            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	            BorderColor3 = Color3.new(),
	            Parent = option.main
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.8,
	            Parent = option.slider
	        })
	
	        option.fill = library:Create('Frame', {
	            BackgroundColor3 = library.flags.menuAccentColor,
	            BorderSizePixel = 0,
	            Parent = option.slider
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.slider
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.slider
	        })
	
	        option.title = library:Create('TextBox', {
	            Position = UDim2.new((option.sub or option.textpos) and 0.5 or 0, (option.sub or option.textpos) and 0 or 6, 0, 0),
	            Size = UDim2.new(0, 0, 0, (option.sub or option.textpos) and 14 or 18),
	            BackgroundTransparency = 1,
	            Text = (option.text == 'nil' and '' or option.text .. ': ') .. option.value .. option.suffix,
	            TextSize = (option.sub or option.textpos) and 14 or 15,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.fromRGB(210, 210, 210),
	            TextXAlignment = Enum.TextXAlignment[(option.sub or option.textpos) and 'Center' or 'Left'],
	            Parent = (option.sub or option.textpos) and option.slider or option.main
	        })
	        table.insert(library.theme, option.fill)
	
	        library:Create('UIGradient', {
	            Color = ColorSequence.new({
	                ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 115)),
	                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
	            }),
	            Rotation = -90,
	            Parent = option.fill
	        })
	
	        if option.min >= 0 then
	            option.fill.Size = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 1, 0)
	        else
	            option.fill.Position = UDim2.new((0 - option.min) / (option.max - option.min), 0, 0, 0)
	            option.fill.Size = UDim2.new(option.value / (option.max - option.min), 0, 1, 0)
	        end
	
	        local manualInput
	        library.unloadMaid:GiveTask(option.title.Focused:connect(function()
	            if not manualInput then
	                option.title:ReleaseFocus()
	                option.title.Text = (option.text == 'nil' and '' or option.text .. ': ') .. option.value .. option.suffix
	            end
	        end));
	
	        library.unloadMaid:GiveTask(option.title.FocusLost:connect(function()
	            option.slider.BorderColor3 = Color3.new()
	            if manualInput then
	                if tonumber(option.title.Text) then
	                    option:SetValue(tonumber(option.title.Text))
	                else
	                    option.title.Text = (option.text == 'nil' and '' or option.text .. ': ') .. option.value .. option.suffix
	                end
	            end
	            manualInput = false
	        end));
	
	        local interest = (option.sub or option.textpos) and option.slider or option.main
	        library.unloadMaid:GiveTask(interest.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
	                    manualInput = true
	                    option.title:CaptureFocus()
	                else
	                    library.slider = option
	                    option.slider.BorderColor3 = library.flags.menuAccentColor
	                    option:SetValue(option.min + ((input.Position.X - option.slider.AbsolutePosition.X) / option.slider.AbsoluteSize.X) * (option.max - option.min))
	                end
	            end
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    option.slider.BorderColor3 = library.flags.menuAccentColor
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end));
	
	        makeTooltip(interest, option);
	
	        library.unloadMaid:GiveTask(interest.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if option ~= library.slider then
	                    option.slider.BorderColor3 = Color3.new();
	                end;
	            end;
	        end));
	
	        if (option.parent) then
	            local oldParent = option.slider.Parent;
	
	            option.parent.onStateChanged:Connect(function(state)
	                option.slider.Parent = state and oldParent or nil;
	            end);
	        end;
	
	        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	
	        function option:SetValue(value, nocallback)
	            value = value or self.value;
	
	            value = library.round(value, option.float)
	            value = math.clamp(value, self.min, self.max)
	
	            if self.min >= 0 then
	                TweenService:Create(option.fill, tweenInfo, {Size = UDim2.new((value - self.min) / (self.max - self.min), 0, 1, 0)}):Play();
	            else
	                TweenService:Create(option.fill, tweenInfo, {
	                    Size = UDim2.new(value / (self.max - self.min), 0, 1, 0),
	                    Position = UDim2.new((0 - self.min) / (self.max - self.min), 0, 0, 0)
	                }):Play();
	            end
	            library.flags[self.flag] = value
	            self.value = value
	            option.title.Text = (option.text == 'nil' and '' or option.text .. ': ') .. string.format(option.float == 1 and '%d' or '%.02f', option.value) .. option.suffix
	            if not nocallback then
	                task.spawn(self.callback, value)
	            end
	
	            library.OnFlagChanged:Fire(self)
	        end
	
	        task.defer(function()
	            if library then
	                option:SetValue(option.value)
	            end
	        end)
	    end
	
	    local function createList(option, parent)
	        option.hasInit = true
	
	        if option.sub then
	            option.main = option:getMain()
	            option.main.Size = UDim2.new(1, 0, 0, 48)
	        else
	            option.main = library:Create('Frame', {
	                LayoutOrder = option.position,
	                Size = UDim2.new(1, 0, 0, option.text == 'nil' and 30 or 48),
	                BackgroundTransparency = 1,
	                Parent = parent
	            })
	
	            if option.text ~= 'nil' then
	                library:Create('TextLabel', {
	                    Position = UDim2.new(0, 6, 0, 0),
	                    Size = UDim2.new(1, -12, 0, 18),
	                    BackgroundTransparency = 1,
	                    Text = option.text,
	                    TextSize = 15,
	                    Font = Enum.Font.Code,
	                    TextColor3 = Color3.fromRGB(210, 210, 210),
	                    TextXAlignment = Enum.TextXAlignment.Left,
	                    Parent = option.main
	                })
	            end
	        end
	
	        if(option.playerOnly) then
	            library.OnLoad:Connect(function()
	                option.values = {};
	
	                for i,v in next, Players:GetPlayers() do
	                    if (v == LocalPlayer) then continue end;
	                    option:AddValue(v.Name);
	                end;
	
	                library.unloadMaid:GiveTask(Players.PlayerAdded:Connect(function(plr)
	                    option:AddValue(plr.Name);
	                end));
	
	                library.unloadMaid:GiveTask(Players.PlayerRemoving:Connect(function(plr)
	                    option:RemoveValue(plr.Name);
	                end));
	            end);
	        end;
	
	        local function getMultiText()
	            local t = {};
	
	            if (option.playerOnly and option.multiselect) then
	                for i, v in next, option.values do
	                    if (option.value[i]) then
	                        table.insert(t, tostring(i));
	                    end;
	                end;
	            else
	                for i, v in next, option.values do
	                    if (option.value[v]) then
	                        table.insert(t, tostring(v));
	                    end;
	                end;
	            end;
	
	            return table.concat(t, ', ');
	        end
	
	        option.listvalue = library:Create('TextBox', {
	            Position = UDim2.new(0, 6, 0, (option.text == 'nil' and not option.sub) and 4 or 22),
	            Size = UDim2.new(1, -12, 0, 22),
	            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	            BorderColor3 = Color3.new(),
	            Active = false,
	            ClearTextOnFocus = false,
	            Text = ' ' .. (typeof(option.value) == 'string' and option.value or getMultiText()),
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextXAlignment = Enum.TextXAlignment.Left,
	            TextTruncate = Enum.TextTruncate.AtEnd,
	            Parent = option.main
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.8,
	            Parent = option.listvalue
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.listvalue
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.listvalue
	        })
	
	        option.arrow = library:Create('ImageLabel', {
	            Position = UDim2.new(1, -16, 0, 7),
	            Size = UDim2.new(0, 8, 0, 8),
	            Rotation = 90,
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://4918373417',
	            ImageColor3 = Color3.new(1, 1, 1),
	            ScaleType = Enum.ScaleType.Fit,
	            ImageTransparency = 0.4,
	            Parent = option.listvalue
	        })
	
	        option.holder = library:Create('TextButton', {
	            ZIndex = 4,
	            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	            BorderColor3 = Color3.new(),
	            Text = '',
	            TextColor3 = Color3.fromRGB(255,255, 255),
	            AutoButtonColor = false,
	            Visible = false,
	            Parent = library.base
	        })
	
	        option.content = library:Create('ScrollingFrame', {
	            ZIndex = 4,
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            BorderSizePixel = 0,
	            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
	            ScrollBarThickness = 6,
	            ScrollingDirection = Enum.ScrollingDirection.Y,
	            VerticalScrollBarInset = Enum.ScrollBarInset.Always,
	            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	            Parent = option.holder
	        })
	
	        library:Create('ImageLabel', {
	            ZIndex = 4,
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.holder
	        })
	
	        library:Create('ImageLabel', {
	            ZIndex = 4,
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.holder
	        })
	
	        local layout = library:Create('UIListLayout', {
	            Padding = UDim.new(0, 2),
	            Parent = option.content
	        })
	
	        library:Create('UIPadding', {
	            PaddingTop = UDim.new(0, 4),
	            PaddingLeft = UDim.new(0, 4),
	            Parent = option.content
	        })
	
	        local valueCount = 0;
	
	        local function updateHolder(newValueCount)
	            option.holder.Size = UDim2.new(0, option.listvalue.AbsoluteSize.X, 0, 8 + ((newValueCount or valueCount) > option.max and (-2 + (option.max * 22)) or layout.AbsoluteContentSize.Y))
	            option.content.CanvasSize = UDim2.new(0, 0, 0, 8 + layout.AbsoluteContentSize.Y)
	        end;
	
	        library.unloadMaid:GiveTask(layout.Changed:Connect(function() updateHolder(); end));
	        local interest = option.sub and option.listvalue or option.main
	        local focused = false;
	
	        library.unloadMaid:GiveTask(option.listvalue.Focused:Connect(function() focused = true; end));
	        library.unloadMaid:GiveTask(option.listvalue.FocusLost:Connect(function() focused = false; end));
	
	        library.unloadMaid:GiveTask(option.listvalue:GetPropertyChangedSignal('Text'):Connect(function()
	            if (not focused) then return end;
	            local newText = option.listvalue.Text;
	
	            if (newText:sub(1, 1) ~= ' ') then
	                newText = ' ' .. newText;
	                option.listvalue.Text = newText;
	                option.listvalue.CursorPosition = 2;
	            end;
	
	            local search = string.lower(newText:sub(2));
	            local matchedResults = 0;
	
	            for name, label in next, option.labels do
	                if (string.find(string.lower(name), search)) then
	                    matchedResults += 1;
	                    label.Visible = true;
	                else
	                    label.Visible = false;
	                end;
	            end;
	
	            updateHolder(matchedResults);
	        end));
	
	        library.unloadMaid:GiveTask(option.listvalue.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                if library.popup == option then library.popup:Close() return end
	                if library.popup then
	                    library.popup:Close()
	                end
	                option.arrow.Rotation = -90
	                option.open = true
	                option.holder.Visible = true
	                local pos = option.main.AbsolutePosition
	                option.holder.Position = UDim2.new(0, pos.X + 6, 0, pos.Y + ((option.text == 'nil' and not option.sub) and 66 or 84))
	                library.popup = option
	                option.listvalue.BorderColor3 = library.flags.menuAccentColor
	                option.listvalue:CaptureFocus();
	                option.listvalue.CursorPosition = string.len(typeof(option.value) == 'string' and option.value or getMultiText() or option.value) + 2;
	
	                if (option.multiselect) then
	                    option.listvalue.Text = ' ';
	                end;
	            end
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    option.listvalue.BorderColor3 = library.flags.menuAccentColor
	                end
	            end
	        end));
	
	        library.unloadMaid:GiveTask(option.listvalue.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not option.open then
	                    option.listvalue.BorderColor3 = Color3.new()
	                end
	            end
	        end));
	
	        library.unloadMaid:GiveTask(interest.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end));
	
	        makeTooltip(interest, option);
	
	        function option:AddValue(value, state)
	            if self.labels[value] then return end
	            state = state or (option.playerOnly and false)
	
	            valueCount = valueCount + 1
	
	            if self.multiselect then
	                self.values[value] = state
	            else
	                if not table.find(self.values, value) then
	                    table.insert(self.values, value)
	                end
	            end
	
	            local label = library:Create('TextLabel', {
	                ZIndex = 4,
	                Size = UDim2.new(1, 0, 0, 20),
	                BackgroundTransparency = 1,
	                Text = value,
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextTransparency = self.multiselect and (self.value[value] and 1 or 0) or self.value == value and 1 or 0,
	                TextColor3 = Color3.fromRGB(210, 210, 210),
	                TextXAlignment = Enum.TextXAlignment.Left,
	                Parent = option.content
	            })
	
	            self.labels[value] = label
	
	            local labelOverlay = library:Create('TextLabel', {
	                ZIndex = 4,
	                Size = UDim2.new(1, 0, 1, 0),
	                BackgroundTransparency = 0.8,
	                Text = ' ' ..value,
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextColor3 = library.flags.menuAccentColor,
	                TextXAlignment = Enum.TextXAlignment.Left,
	                Visible = self.multiselect and self.value[value] or self.value == value,
	                Parent = label
	            });
	
	            table.insert(library.theme, labelOverlay)
	
	            library.unloadMaid:GiveTask(label.InputBegan:connect(function(input)
	                if input.UserInputType.Name == 'MouseButton1' then
	                    if self.multiselect then
	                        self.value[value] = not self.value[value]
	                        self:SetValue(self.value);
	                        self.listvalue.Text = ' ';
	                        self.listvalue.CursorPosition = 2;
	                        self.listvalue:CaptureFocus();
	                    else
	                        self:SetValue(value)
	                        self:Close()
	                    end
	                end
	            end));
	        end
	
	        for i, value in next, option.values do
	            option:AddValue(tostring(typeof(i) == 'number' and value or i))
	        end
	
	        function option:RemoveValue(value)
	            local label = self.labels[value]
	            if label then
	                label:Destroy()
	                self.labels[value] = nil
	                valueCount = valueCount - 1
	                if self.multiselect then
	                    self.values[value] = nil
	                    self:SetValue(self.value)
	                else
	                    table.remove(self.values, table.find(self.values, value))
	                    if self.value == value then
	                        self:SetValue(self.values[1] or '')
	
	                        if (not self.values[1]) then
	                            option.listvalue.Text = '';
	                        end;
	                    end
	                end
	            end
	        end
	
	        function option:SetValue(value, nocallback)
	            if self.multiselect and typeof(value) ~= 'table' then
	                value = {}
	                for i,v in next, self.values do
	                    value[v] = false
	                end
	            end
	
	            if (not value) then return end;
	
	            self.value = self.multiselect and value or self.values[table.find(self.values, value) or 1];
	            if (self.playerOnly and not self.multiselect) then
	                self.value = Players:FindFirstChild(value);
	            end;
	
	            if (not self.value) then return end;
	
	            library.flags[self.flag] = self.value;
	            option.listvalue.Text = ' ' .. (self.multiselect and getMultiText() or tostring(self.value));
	
	            for name, label in next, self.labels do
	                local visible = self.multiselect and self.value[name] or self.value == name;
	                label.TextTransparency = visible and 1 or 0;
	                if label:FindFirstChild'TextLabel' then
	                    label.TextLabel.Visible = visible;
	                end;
	            end;
	
	            if not nocallback then
	                self.callback(self.value)
	            end
	        end
	
	        task.defer(function()
	            if library and not option.noload then
	                option:SetValue(option.value)
	            end
	        end)
	
	        function option:Close()
	            library.popup = nil
	            option.arrow.Rotation = 90
	            self.open = false
	            option.holder.Visible = false
	            option.listvalue.BorderColor3 = Color3.new()
	            option.listvalue:ReleaseFocus();
	            option.listvalue.Text = ' ' .. (self.multiselect and getMultiText() or tostring(self.value));
	
	            for _, label in next, option.labels do
	                label.Visible = true;
	            end;
	        end
	
	        return option
	    end
	
	    local function createBox(option, parent)
	        option.hasInit = true
	
	        option.main = library:Create('Frame', {
	            LayoutOrder = option.position,
	            Size = UDim2.new(1, 0, 0, option.text == 'nil' and 28 or 44),
	            BackgroundTransparency = 1,
	            Parent = parent
	        })
	
	        if option.text ~= 'nil' then
	            option.title = library:Create('TextLabel', {
	                Position = UDim2.new(0, 6, 0, 0),
	                Size = UDim2.new(1, -12, 0, 18),
	                BackgroundTransparency = 1,
	                Text = option.text,
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextColor3 = Color3.fromRGB(210, 210, 210),
	                TextXAlignment = Enum.TextXAlignment.Left,
	                Parent = option.main
	            })
	        end
	
	        option.holder = library:Create('Frame', {
	            Position = UDim2.new(0, 6, 0, option.text == 'nil' and 4 or 20),
	            Size = UDim2.new(1, -12, 0, 20),
	            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	            BorderColor3 = Color3.new(),
	            Parent = option.main
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.8,
	            Parent = option.holder
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.holder
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.holder
	        })
	
	        local inputvalue = library:Create('TextBox', {
	            Position = UDim2.new(0, 4, 0, 0),
	            Size = UDim2.new(1, -4, 1, 0),
	            BackgroundTransparency = 1,
	            Text = '  ' .. option.value,
	            TextSize = 15,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextXAlignment = Enum.TextXAlignment.Left,
	            TextWrapped = true,
	            ClearTextOnFocus = false,
	            Parent = option.holder
	        })
	
	        library.unloadMaid:GiveTask(inputvalue.FocusLost:connect(function(enter)
	            option.holder.BorderColor3 = Color3.new()
	            option:SetValue(inputvalue.Text, enter)
	        end));
	
	        library.unloadMaid:GiveTask(inputvalue.Focused:connect(function()
	            option.holder.BorderColor3 = library.flags.menuAccentColor
	        end));
	
	        library.unloadMaid:GiveTask(inputvalue.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    option.holder.BorderColor3 = library.flags.menuAccentColor
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end));
	
	        makeTooltip(inputvalue, option);
	
	        library.unloadMaid:GiveTask(inputvalue.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not inputvalue:IsFocused() then
	                    option.holder.BorderColor3 = Color3.new();
	                end;
	            end;
	        end));
	
	        function option:SetValue(value, enter)
	            if (value:gsub('%s+', '') == '') then
	                value = '';
	            end;
	
	            library.flags[self.flag] = tostring(value);
	            self.value = tostring(value);
	            inputvalue.Text = self.value;
	            self.callback(value, enter);
	
	            library.OnFlagChanged:Fire(self);
	        end
	        task.defer(function()
	            if library then
	                option:SetValue(option.value)
	            end
	        end)
	    end
	
	    local function createColorPickerWindow(option)
	        option.mainHolder = library:Create('TextButton', {
	            ZIndex = 4,
	            --Position = UDim2.new(1, -184, 1, 6),
	            Size = UDim2.new(0, option.trans and 200 or 184, 0, 264),
	            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	            BorderColor3 = Color3.new(),
	            AutoButtonColor = false,
	            Visible = false,
	            Parent = library.base
	        })
	
	        option.rgbBox = library:Create('Frame', {
	            Position = UDim2.new(0, 6, 0, 214),
	            Size = UDim2.new(0, (option.mainHolder.AbsoluteSize.X - 12), 0, 20),
	            BackgroundColor3 = Color3.fromRGB(57, 57, 57),
	            BorderColor3 = Color3.new(),
	            ZIndex = 5;
	            Parent = option.mainHolder
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.8,
	            ZIndex = 6;
	            Parent = option.rgbBox
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            ZIndex = 6;
	            Parent = option.rgbBox
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            ZIndex = 6;
	            Parent = option.rgbBox
	        })
	
	        local r, g, b = library.round(option.color);
	        local colorText = table.concat({r, g, b}, ',');
	
	        option.rgbInput = library:Create('TextBox', {
	            Position = UDim2.new(0, 4, 0, 0),
	            Size = UDim2.new(1, -4, 1, 0),
	            BackgroundTransparency = 1,
	            Text = colorText,
	            TextSize = 14,
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextXAlignment = Enum.TextXAlignment.Center,
	            TextWrapped = true,
	            ClearTextOnFocus = false,
	            ZIndex = 6;
	            Parent = option.rgbBox
	        })
	
	        option.hexBox = option.rgbBox:Clone()
	        option.hexBox.Position = UDim2.new(0, 6, 0, 238)
	        -- option.hexBox.Size = UDim2.new(0, (option.mainHolder.AbsoluteSize.X/2 - 10), 0, 20)
	        option.hexBox.Parent = option.mainHolder
	        option.hexInput = option.hexBox.TextBox;
	
	        library:Create('ImageLabel', {
	            ZIndex = 4,
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.mainHolder
	        })
	
	        library:Create('ImageLabel', {
	            ZIndex = 4,
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.mainHolder
	        })
	
	        local hue, sat, val = Color3.toHSV(option.color)
	        hue, sat, val = hue == 0 and 1 or hue, sat + 0.005, val - 0.005
	        local editinghue
	        local editingsatval
	        local editingtrans
	
	        local transMain
	        if option.trans then
	            transMain = library:Create('ImageLabel', {
	                ZIndex = 5,
	                Size = UDim2.new(1, 0, 1, 0),
	                BackgroundTransparency = 1,
	                Image = 'rbxassetid://2454009026',
	                ImageColor3 = Color3.fromHSV(hue, 1, 1),
	                Rotation = 180,
	                Parent = library:Create('ImageLabel', {
	                    ZIndex = 4,
	                    AnchorPoint = Vector2.new(1, 0),
	                    Position = UDim2.new(1, -6, 0, 6),
	                    Size = UDim2.new(0, 10, 1, -60),
	                    BorderColor3 = Color3.new(),
	                    Image = 'rbxassetid://4632082392',
	                    ScaleType = Enum.ScaleType.Tile,
	                    TileSize = UDim2.new(0, 5, 0, 5),
	                    Parent = option.mainHolder
	                })
	            })
	
	            option.transSlider = library:Create('Frame', {
	                ZIndex = 5,
	                Position = UDim2.new(0, 0, option.trans, 0),
	                Size = UDim2.new(1, 0, 0, 2),
	                BackgroundColor3 = Color3.fromRGB(38, 41, 65),
	                BorderColor3 = Color3.fromRGB(255, 255, 255),
	                Parent = transMain
	            })
	
	            library.unloadMaid:GiveTask(transMain.InputBegan:connect(function(Input)
	                if Input.UserInputType.Name == 'MouseButton1' then
	                    editingtrans = true
	                    option:SetTrans(1 - ((Input.Position.Y - transMain.AbsolutePosition.Y) / transMain.AbsoluteSize.Y))
	                end
	            end));
	
	            library.unloadMaid:GiveTask(transMain.InputEnded:connect(function(Input)
	                if Input.UserInputType.Name == 'MouseButton1' then
	                    editingtrans = false
	                end
	            end));
	        end
	
	        local hueMain = library:Create('Frame', {
	            ZIndex = 4,
	            AnchorPoint = Vector2.new(0, 1),
	            Position = UDim2.new(0, 6, 1, -54),
	            Size = UDim2.new(1, option.trans and -28 or -12, 0, 10),
	            BackgroundColor3 = Color3.new(1, 1, 1),
	            BorderColor3 = Color3.new(),
	            Parent = option.mainHolder
	        })
	
	        library:Create('UIGradient', {
	            Color = ColorSequence.new({
	                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
	                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
	                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
	                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
	                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
	                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	            }),
	            Parent = hueMain
	        })
	
	        local hueSlider = library:Create('Frame', {
	            ZIndex = 4,
	            Position = UDim2.new(1 - hue, 0, 0, 0),
	            Size = UDim2.new(0, 2, 1, 0),
	            BackgroundColor3 = Color3.fromRGB(38, 41, 65),
	            BorderColor3 = Color3.fromRGB(255, 255, 255),
	            Parent = hueMain
	        })
	
	        library.unloadMaid:GiveTask(hueMain.InputBegan:connect(function(Input)
	            if Input.UserInputType.Name == 'MouseButton1' then
	                editinghue = true
	                local X = (hueMain.AbsolutePosition.X + hueMain.AbsoluteSize.X) - hueMain.AbsolutePosition.X
	                X = math.clamp((Input.Position.X - hueMain.AbsolutePosition.X) / X, 0, 0.995)
	                option:SetColor(Color3.fromHSV(1 - X, sat, val))
	            end
	        end));
	
	        library.unloadMaid:GiveTask(hueMain.InputEnded:connect(function(Input)
	            if Input.UserInputType.Name == 'MouseButton1' then
	                editinghue = false
	            end
	        end));
	
	        local satval = library:Create('ImageLabel', {
	            ZIndex = 4,
	            Position = UDim2.new(0, 6, 0, 6),
	            Size = UDim2.new(1, option.trans and -28 or -12, 1, -74),
	            BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
	            BorderColor3 = Color3.new(),
	            Image = 'rbxassetid://4155801252',
	            ClipsDescendants = true,
	            Parent = option.mainHolder
	        })
	
	        local satvalSlider = library:Create('Frame', {
	            ZIndex = 4,
	            AnchorPoint = Vector2.new(0.5, 0.5),
	            Position = UDim2.new(sat, 0, 1 - val, 0),
	            Size = UDim2.new(0, 4, 0, 4),
	            Rotation = 45,
	            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	            Parent = satval
	        })
	
	        library.unloadMaid:GiveTask(satval.InputBegan:connect(function(Input)
	            if Input.UserInputType.Name == 'MouseButton1' then
	                editingsatval = true
	                local X = (satval.AbsolutePosition.X + satval.AbsoluteSize.X) - satval.AbsolutePosition.X
	                local Y = (satval.AbsolutePosition.Y + satval.AbsoluteSize.Y) - satval.AbsolutePosition.Y
	                X = math.clamp((Input.Position.X - satval.AbsolutePosition.X) / X, 0.005, 1)
	                Y = math.clamp((Input.Position.Y - satval.AbsolutePosition.Y) / Y, 0, 0.995)
	                option:SetColor(Color3.fromHSV(hue, X, 1 - Y))
	            end
	        end));
	
	        library:AddConnection(UserInputService.InputChanged, function(Input)
	            if (not editingsatval and not editinghue and not editingtrans) then return end;
	
	            if Input.UserInputType.Name == 'MouseMovement' then
	                if editingsatval then
	                    local X = (satval.AbsolutePosition.X + satval.AbsoluteSize.X) - satval.AbsolutePosition.X
	                    local Y = (satval.AbsolutePosition.Y + satval.AbsoluteSize.Y) - satval.AbsolutePosition.Y
	                    X = math.clamp((Input.Position.X - satval.AbsolutePosition.X) / X, 0.005, 1)
	                    Y = math.clamp((Input.Position.Y - satval.AbsolutePosition.Y) / Y, 0, 0.995)
	                    option:SetColor(Color3.fromHSV(hue, X, 1 - Y))
	                elseif editinghue then
	                    local X = (hueMain.AbsolutePosition.X + hueMain.AbsoluteSize.X) - hueMain.AbsolutePosition.X
	                    X = math.clamp((Input.Position.X - hueMain.AbsolutePosition.X) / X, 0, 0.995)
	                    option:SetColor(Color3.fromHSV(1 - X, sat, val))
	                elseif editingtrans then
	                    option:SetTrans(1 - ((Input.Position.Y - transMain.AbsolutePosition.Y) / transMain.AbsoluteSize.Y))
	                end
	            end
	        end)
	
	        library.unloadMaid:GiveTask(satval.InputEnded:connect(function(Input)
	            if Input.UserInputType.Name == 'MouseButton1' then
	                editingsatval = false
	            end
	        end));
	
	        option.hexInput.Text = option.color:ToHex();
	
	        library.unloadMaid:GiveTask(option.rgbInput.FocusLost:connect(function()
	            local color = Color3.fromRGB(unpack(option.rgbInput.Text:split(',')));
	            return option:SetColor(color)
	        end));
	
	        library.unloadMaid:GiveTask(option.hexInput.FocusLost:connect(function()
	            local color = Color3.fromHex(option.hexInput.Text);
	            return option:SetColor(color);
	        end));
	
	        function option:updateVisuals(Color)
	            hue, sat, val = Color:ToHSV();
	            hue, sat, val = math.clamp(hue, 0, 1), math.clamp(sat, 0, 1), math.clamp(val, 0, 1);
	
	            hue = hue == 0 and 1 or hue
	            satval.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
	            if option.trans then
	                transMain.ImageColor3 = Color3.fromHSV(hue, 1, 1)
	            end
	            hueSlider.Position = UDim2.new(1 - hue, 0, 0, 0)
	            satvalSlider.Position = UDim2.new(sat, 0, 1 - val, 0)
	
	            local color = Color3.fromHSV(hue, sat, val);
	            local r, g, b = library.round(color);
	
	            option.hexInput.Text = color:ToHex();
	            option.rgbInput.Text = table.concat({r, g, b}, ',');
	        end
	
	        return option
	    end
	
	    local function createColor(option, parent)
	        option.hasInit = true
	
	        if option.sub then
	            option.main = option:getMain()
	        else
	            option.main = library:Create('Frame', {
	                LayoutOrder = option.position,
	                Size = UDim2.new(1, 0, 0, 20),
	                BackgroundTransparency = 1,
	                Parent = parent
	            })
	
	            option.title = library:Create('TextLabel', {
	                Position = UDim2.new(0, 6, 0, 0),
	                Size = UDim2.new(1, -12, 1, 0),
	                BackgroundTransparency = 1,
	                Text = option.text,
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextColor3 = Color3.fromRGB(210, 210, 210),
	                TextXAlignment = Enum.TextXAlignment.Left,
	                Parent = option.main
	            })
	        end
	
	        option.visualize = library:Create(option.sub and 'TextButton' or 'Frame', {
	            Position = UDim2.new(1, -(option.subpos or 0) - 24, 0, 4),
	            Size = UDim2.new(0, 18, 0, 12),
	            SizeConstraint = Enum.SizeConstraint.RelativeYY,
	            BackgroundColor3 = option.color,
	            BorderColor3 = Color3.new(),
	            Parent = option.main
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.6,
	            Parent = option.visualize
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.visualize
	        })
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = option.visualize
	        })
	
	        local interest = option.sub and option.visualize or option.main
	
	        if option.sub then
	            option.visualize.Text = ''
	            option.visualize.AutoButtonColor = false
	        end
	
	        library.unloadMaid:GiveTask(interest.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                if not option.mainHolder then
	                    createColorPickerWindow(option)
	                end
	                if library.popup == option then library.popup:Close() return end
	                if library.popup then library.popup:Close() end
	                option.open = true
	                local pos = option.main.AbsolutePosition
	                option.mainHolder.Position = UDim2.new(0, pos.X + 36 + (option.trans and -16 or 0), 0, pos.Y + 56)
	                option.mainHolder.Visible = true
	                library.popup = option
	                option.visualize.BorderColor3 = library.flags.menuAccentColor
	            end
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not library.warning and not library.slider then
	                    option.visualize.BorderColor3 = library.flags.menuAccentColor
	                end
	                if option.tip then
	                    library.tooltip.Text = option.tip;
	                end
	            end
	        end));
	
	        makeTooltip(interest, option);
	
	        library.unloadMaid:GiveTask(interest.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseMovement' then
	                if not option.open then
	                    option.visualize.BorderColor3 = Color3.new();
	                end;
	            end;
	        end));
	
	        function option:SetColor(newColor, nocallback, noFire)
	            newColor = newColor or Color3.new(1, 1, 1)
	            if self.mainHolder then
	                self:updateVisuals(newColor)
	            end
	            option.visualize.BackgroundColor3 = newColor
	            library.flags[self.flag] = newColor
	            self.color = newColor
	
	            if not nocallback then
	                task.spawn(self.callback, newColor)
	            end
	
	            if (not noFire) then
	                library.OnFlagChanged:Fire(self);
	            end;
	        end
	
	        if option.trans then
	            function option:SetTrans(value, manual)
	                value = math.clamp(tonumber(value) or 0, 0, 1)
	                if self.transSlider then
	                    self.transSlider.Position = UDim2.new(0, 0, value, 0)
	                end
	                self.trans = value
	                library.flags[self.flag .. 'Transparency'] = 1 - value
	                task.spawn(self.calltrans, value)
	            end
	            option:SetTrans(option.trans)
	        end
	
	        task.defer(function()
	            if library then
	                option:SetColor(option.color)
	            end
	        end)
	
	        function option:Close()
	            library.popup = nil
	            self.open = false
	            self.mainHolder.Visible = false
	            option.visualize.BorderColor3 = Color3.new()
	        end
	    end
	
	    function library:AddTab(title, pos)
	        local tab = {canInit = true, columns = {}, title = tostring(title)}
	        table.insert(self.tabs, pos or #self.tabs + 1, tab)
	
	        function tab:AddColumn()
	            local column = {sections = {}, position = #self.columns, canInit = true, tab = self}
	            table.insert(self.columns, column)
	
	            function column:AddSection(title)
	                local section = {title = tostring(title), options = {}, canInit = true, column = self}
	                table.insert(self.sections, section)
	
	                function section:AddLabel(text)
	                    local option = {text = text}
	                    option.section = self
	                    option.type = 'label'
	                    option.position = #self.options
	                    table.insert(self.options, option)
	
	                    if library.hasInit and self.hasInit then
	                        createLabel(option, self.content)
	                    else
	                        option.Init = createLabel
	                    end
	
	                    return option
	                end
	
	                function section:AddDivider(text, tip)
	                    local option = {text = text, tip = tip}
	                    option.section = self
	                    option.type = 'divider'
	                    option.position = #self.options
	                    table.insert(self.options, option)
	
	                    if library.hasInit and self.hasInit then
	                        createDivider(option, self.content)
	                    else
	                        option.Init = createDivider
	                    end
	
	                    return option
	                end
	
	                function section:AddToggle(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.state = typeof(option.state) == 'boolean' and option.state or false
	                    option.default = option.state;
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.type = 'toggle'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.subcount = 0
	                    option.tip = option.tip and tostring(option.tip)
	                    option.style = option.style == 2
	                    library.flags[option.flag] = option.state
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    function option:AddColor(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddColor(subOption)
	                    end
	
	                    function option:AddBind(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddBind(subOption)
	                    end
	
	                    function option:AddList(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddList(subOption)
	                    end
	
	                    function option:AddSlider(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	
	                        subOption.parent = option;
	                        return section:AddSlider(subOption)
	                    end
	
	                    if library.hasInit and self.hasInit then
	                        createToggle(option, self.content)
	                    else
	                        option.Init = createToggle
	                    end
	
	                    return option
	                end
	
	                function section:AddButton(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.type = 'button'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.subcount = 0
	                    option.tip = option.tip and tostring(option.tip)
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    function option:AddBind(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() option.main.Size = UDim2.new(1, 0, 0, 40) return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddBind(subOption)
	                    end
	
	                    function option:AddColor(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() option.main.Size = UDim2.new(1, 0, 0, 40) return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddColor(subOption)
	                    end
	
	                    function option:AddButton(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        subOption.parent = option;
	                        section:AddButton(subOption)
	
	                        return option;
	                    end;
	
	                    function option:SetText(text)
	                        option.title.Text = text;
	                    end;
	
	                    if library.hasInit and self.hasInit then
	                        createButton(option, self.content)
	                    else
	                        option.Init = createButton
	                    end
	
	                    return option
	                end
	
	                function section:AddBind(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.key = (option.key and option.key.Name) or option.key or 'none'
	                    option.nomouse = typeof(option.nomouse) == 'boolean' and option.nomouse or false
	                    option.mode = typeof(option.mode) == 'string' and ((option.mode == 'toggle' or option.mode == 'hold') and option.mode) or 'toggle'
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.type = 'bind'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.tip = option.tip and tostring(option.tip)
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    if library.hasInit and self.hasInit then
	                        createBind(option, self.content)
	                    else
	                        option.Init = createBind
	                    end
	
	                    return option
	                end
	
	                function section:AddSlider(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.min = typeof(option.min) == 'number' and option.min or 0
	                    option.max = typeof(option.max) == 'number' and option.max or 0
	                    option.value = option.min < 0 and 0 or math.clamp(typeof(option.value) == 'number' and option.value or option.min, option.min, option.max)
	                    option.default = option.value;
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.float = typeof(option.value) == 'number' and option.float or 1
	                    option.suffix = option.suffix and tostring(option.suffix) or ''
	                    option.textpos = option.textpos == 2
	                    option.type = 'slider'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.subcount = 0
	                    option.tip = option.tip and tostring(option.tip)
	                    library.flags[option.flag] = option.value
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    function option:AddColor(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddColor(subOption)
	                    end
	
	                    function option:AddBind(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddBind(subOption)
	                    end
	
	                    if library.hasInit and self.hasInit then
	                        createSlider(option, self.content)
	                    else
	                        option.Init = createSlider
	                    end
	
	                    return option
	                end
	
	                function section:AddList(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.values = typeof(option.values) == 'table' and option.values or {}
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.multiselect = typeof(option.multiselect) == 'boolean' and option.multiselect or false
	                    --option.groupbox = (not option.multiselect) and (typeof(option.groupbox) == 'boolean' and option.groupbox or false)
	                    option.value = option.multiselect and (typeof(option.value) == 'table' and option.value or {}) or tostring(option.value or option.values[1] or '')
	                    if option.multiselect then
	                        for i,v in next, option.values do
	                            option.value[v] = false
	                        end
	                    end
	                    option.max = option.max or 8
	                    option.open = false
	                    option.type = 'list'
	                    option.position = #self.options
	                    option.labels = {}
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.subcount = 0
	                    option.tip = option.tip and tostring(option.tip)
	                    library.flags[option.flag] = option.value
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    function option:AddValue(value, state)
	                        if self.multiselect then
	                            self.values[value] = state
	                        else
	                            table.insert(self.values, value)
	                        end
	                    end
	
	                    function option:AddColor(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddColor(subOption)
	                    end
	
	                    function option:AddBind(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddBind(subOption)
	                    end
	
	                    if library.hasInit and self.hasInit then
	                        createList(option, self.content)
	                    else
	                        option.Init = createList
	                    end
	
	                    return option
	                end
	
	                function section:AddBox(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.value = tostring(option.value or '')
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.type = 'box'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.tip = option.tip and tostring(option.tip)
	                    library.flags[option.flag] = option.value
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    if library.hasInit and self.hasInit then
	                        createBox(option, self.content)
	                    else
	                        option.Init = createBox
	                    end
	
	                    return option
	                end
	
	                function section:AddColor(option)
	                    option = typeof(option) == 'table' and option or {}
	                    option.section = self
	                    option.text = tostring(option.text)
	                    option.color = typeof(option.color) == 'table' and Color3.new(option.color[1], option.color[2], option.color[3]) or option.color or Color3.new(1, 1, 1)
	                    option.callback = typeof(option.callback) == 'function' and option.callback or function() end
	                    option.calltrans = typeof(option.calltrans) == 'function' and option.calltrans or (option.calltrans == 1 and option.callback) or function() end
	                    option.open = false
	                    option.default = option.color;
	                    option.trans = tonumber(option.trans)
	                    option.subcount = 1
	                    option.type = 'color'
	                    option.position = #self.options
	                    option.flag = (library.flagprefix or '') .. toCamelCase(option.flag or option.text)
	                    option.tip = option.tip and tostring(option.tip)
	                    library.flags[option.flag] = option.color
	                    table.insert(self.options, option)
	                    library.options[option.flag] = option
	
	                    function option:AddColor(subOption)
	                        subOption = typeof(subOption) == 'table' and subOption or {}
	                        subOption.sub = true
	                        subOption.subpos = self.subcount * 24
	                        function subOption:getMain() return option.main end
	                        self.subcount = self.subcount + 1
	                        return section:AddColor(subOption)
	                    end
	
	                    if option.trans then
	                        library.flags[option.flag .. 'Transparency'] = option.trans
	                    end
	
	                    if library.hasInit and self.hasInit then
	                        createColor(option, self.content)
	                    else
	                        option.Init = createColor
	                    end
	
	                    return option
	                end
	
	                function section:SetTitle(newTitle)
	                    self.title = tostring(newTitle)
	                    if self.titleText then
	                        self.titleText.Text = tostring(newTitle)
	                    end
	                end
	
	                function section:Init()
	                    if self.hasInit then return end
	                    self.hasInit = true
	
	                    self.main = library:Create('Frame', {
	                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	                        BorderColor3 = Color3.new(),
	                        Parent = column.main
	                    })
	
	                    self.content = library:Create('Frame', {
	                        Size = UDim2.new(1, 0, 1, 0),
	                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	                        BorderColor3 = Color3.fromRGB(60, 60, 60),
	                        BorderMode = Enum.BorderMode.Inset,
	                        Parent = self.main
	                    })
	
	                    library:Create('ImageLabel', {
	                        Size = UDim2.new(1, -2, 1, -2),
	                        Position = UDim2.new(0, 1, 0, 1),
	                        BackgroundTransparency = 1,
	                        Image = 'rbxassetid://2592362371',
	                        ImageColor3 = Color3.new(),
	                        ScaleType = Enum.ScaleType.Slice,
	                        SliceCenter = Rect.new(2, 2, 62, 62),
	                        Parent = self.main
	                    })
	
	                    table.insert(library.theme, library:Create('Frame', {
	                        Size = UDim2.new(1, 0, 0, 1),
	                        BackgroundColor3 = library.flags.menuAccentColor,
	                        BorderSizePixel = 0,
	                        BorderMode = Enum.BorderMode.Inset,
	                        Parent = self.main
	                    }))
	
	                    local layout = library:Create('UIListLayout', {
	                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
	                        SortOrder = Enum.SortOrder.LayoutOrder,
	                        Padding = UDim.new(0, 2),
	                        Parent = self.content
	                    })
	
	                    library:Create('UIPadding', {
	                        PaddingTop = UDim.new(0, 12),
	                        Parent = self.content
	                    })
	
	                    self.titleText = library:Create('TextLabel', {
	                        AnchorPoint = Vector2.new(0, 0.5),
	                        Position = UDim2.new(0, 12, 0, 0),
	                        Size = UDim2.new(0, TextService:GetTextSize(self.title, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 10, 0, 3),
	                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	                        BorderSizePixel = 0,
	                        Text = self.title,
	                        TextSize = 15,
	                        Font = Enum.Font.Code,
	                        TextColor3 = Color3.new(1, 1, 1),
	                        Parent = self.main
	                    })
	
	                    library.unloadMaid:GiveTask(layout.Changed:connect(function()
	                        self.main.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 16)
	                    end));
	
	                    for _, option in next, self.options do
	                        option.Init(option, self.content)
	                    end
	                end
	
	                if library.hasInit and self.hasInit then
	                    section:Init()
	                end
	
	                return section
	            end
	
	            function column:Init()
	                if self.hasInit then return end
	                self.hasInit = true
	
	                self.main = library:Create('ScrollingFrame', {
	                    ZIndex = 2,
	                    Position = UDim2.new(0, 6 + (self.position * 239), 0, 2),
	                    Size = UDim2.new(0, 233, 1, -4),
	                    BackgroundTransparency = 1,
	                    BorderSizePixel = 0,
	                    ScrollBarImageColor3 = Color3.fromRGB(),
	                    ScrollBarThickness = 4,
	                    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	                    ScrollingDirection = Enum.ScrollingDirection.Y,
	                    Visible = true
	                })
	
	                local layout = library:Create('UIListLayout', {
	                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
	                    SortOrder = Enum.SortOrder.LayoutOrder,
	                    Padding = UDim.new(0, 12),
	                    Parent = self.main
	                })
	
	                library:Create('UIPadding', {
	                    PaddingTop = UDim.new(0, 8),
	                    PaddingLeft = UDim.new(0, 2),
	                    PaddingRight = UDim.new(0, 2),
	                    Parent = self.main
	                })
	
	                library.unloadMaid:GiveTask(layout.Changed:connect(function()
	                    self.main.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
	                end));
	
	                for _, section in next, self.sections do
	                    if section.canInit and #section.options > 0 then
	                        section:Init()
	                    end
	                end
	            end
	
	            if library.hasInit and self.hasInit then
	                column:Init()
	            end
	
	            return column
	        end
	
	        function tab:Init()
	            if self.hasInit then return end
	            self.hasInit = true
	
	            local size = TextService:GetTextSize(self.title, 18, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 10
	
	            self.button = library:Create('TextLabel', {
	                Position = UDim2.new(0, library.tabSize, 0, 22),
	                Size = UDim2.new(0, size, 0, 30),
	                BackgroundTransparency = 1,
	                Text = self.title,
	                TextColor3 = Color3.new(1, 1, 1),
	                TextSize = 15,
	                Font = Enum.Font.Code,
	                TextWrapped = true,
	                ClipsDescendants = true,
	                Parent = library.main
	            });
	
	            library.tabSize = library.tabSize + size
	
	            library.unloadMaid:GiveTask(self.button.InputBegan:connect(function(input)
	                if input.UserInputType.Name == 'MouseButton1' then
	                    library:selectTab(self);
	                end;
	            end));
	
	            for _, column in next, self.columns do
	                if column.canInit then
	                    column:Init();
	                end;
	            end;
	        end;
	
	        if self.hasInit then
	            tab:Init()
	        end
	
	        return tab
	    end
	
	    function library:AddWarning(warning)
	        warning = typeof(warning) == 'table' and warning or {}
	        warning.text = tostring(warning.text)
	        warning.type = warning.type == 'confirm' and 'confirm' or ''
	
	        local answer
	        function warning:Show()
	            library.warning = warning
	            if warning.main and warning.type == '' then
	                warning.main:Destroy();
	                warning.main = nil;
	            end
	            if library.popup then library.popup:Close() end
	            if not warning.main then
	                warning.main = library:Create('TextButton', {
	                    ZIndex = 2,
	                    Size = UDim2.new(1, 0, 1, 0),
	                    BackgroundTransparency = 0.3,
	                    BackgroundColor3 = Color3.new(),
	                    BorderSizePixel = 0,
	                    Text = '',
	                    AutoButtonColor = false,
	                    Parent = library.main
	                })
	
	                warning.message = library:Create('TextLabel', {
	                    ZIndex = 2,
	                    Position = UDim2.new(0, 20, 0.5, -60),
	                    Size = UDim2.new(1, -40, 0, 40),
	                    BackgroundTransparency = 1,
	                    TextSize = 16,
	                    Font = Enum.Font.Code,
	                    TextColor3 = Color3.new(1, 1, 1),
	                    TextWrapped = true,
	                    RichText = true,
	                    Parent = warning.main
	                })
	
	                if warning.type == 'confirm' then
	                    local button = library:Create('TextLabel', {
	                        ZIndex = 2,
	                        Position = UDim2.new(0.5, -105, 0.5, -10),
	                        Size = UDim2.new(0, 100, 0, 20),
	                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	                        BorderColor3 = Color3.new(),
	                        Text = 'Yes',
	                        TextSize = 16,
	                        Font = Enum.Font.Code,
	                        TextColor3 = Color3.new(1, 1, 1),
	                        Parent = warning.main
	                    })
	
	                    library:Create('ImageLabel', {
	                        ZIndex = 2,
	                        Size = UDim2.new(1, 0, 1, 0),
	                        BackgroundTransparency = 1,
	                        Image = 'rbxassetid://2454009026',
	                        ImageColor3 = Color3.new(),
	                        ImageTransparency = 0.8,
	                        Parent = button
	                    })
	
	                    library:Create('ImageLabel', {
	                        ZIndex = 2,
	                        Size = UDim2.new(1, 0, 1, 0),
	                        BackgroundTransparency = 1,
	                        Image = 'rbxassetid://2592362371',
	                        ImageColor3 = Color3.fromRGB(60, 60, 60),
	                        ScaleType = Enum.ScaleType.Slice,
	                        SliceCenter = Rect.new(2, 2, 62, 62),
	                        Parent = button
	                    })
	
	                    local button1 = library:Create('TextLabel', {
	                        ZIndex = 2,
	                        Position = UDim2.new(0.5, 5, 0.5, -10),
	                        Size = UDim2.new(0, 100, 0, 20),
	                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	                        BorderColor3 = Color3.new(),
	                        Text = 'No',
	                        TextSize = 16,
	                        Font = Enum.Font.Code,
	                        TextColor3 = Color3.new(1, 1, 1),
	                        Parent = warning.main
	                    })
	
	                    library:Create('ImageLabel', {
	                        ZIndex = 2,
	                        Size = UDim2.new(1, 0, 1, 0),
	                        BackgroundTransparency = 1,
	                        Image = 'rbxassetid://2454009026',
	                        ImageColor3 = Color3.new(),
	                        ImageTransparency = 0.8,
	                        Parent = button1
	                    })
	
	                    library:Create('ImageLabel', {
	                        ZIndex = 2,
	                        Size = UDim2.new(1, 0, 1, 0),
	                        BackgroundTransparency = 1,
	                        Image = 'rbxassetid://2592362371',
	                        ImageColor3 = Color3.fromRGB(60, 60, 60),
	                        ScaleType = Enum.ScaleType.Slice,
	                        SliceCenter = Rect.new(2, 2, 62, 62),
	                        Parent = button1
	                    })
	
	                    library.unloadMaid:GiveTask(button.InputBegan:connect(function(input)
	                        if input.UserInputType.Name == 'MouseButton1' then
	                            answer = true
	                        end
	                    end));
	
	                    library.unloadMaid:GiveTask(button1.InputBegan:connect(function(input)
	                        if input.UserInputType.Name == 'MouseButton1' then
	                            answer = false
	                        end
	                    end));
	                else
	                    local button = library:Create('TextLabel', {
	                        ZIndex = 2,
	                        Position = UDim2.new(0.5, -50, 0.5, -10),
	                        Size = UDim2.new(0, 100, 0, 20),
	                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	                        BorderColor3 = Color3.new(),
	                        Text = 'OK',
	                        TextSize = 16,
	                        Font = Enum.Font.Code,
	                        TextColor3 = Color3.new(1, 1, 1),
	                        Parent = warning.main
	                    })
	
	                    library.unloadMaid:GiveTask(button.InputEnded:connect(function(input)
	                        if input.UserInputType.Name == 'MouseButton1' then
	                            answer = true
	                        end
	                    end));
	                end
	            end
	            warning.main.Visible = true
	            warning.message.Text = warning.text
	
	            repeat task.wait() until answer ~= nil;
	            library.warning = nil;
	
	            local answerCopy = answer;
	            warning:Close();
	
	            return answerCopy;
	        end
	
	        function warning:Close()
	            answer = nil
	            if not warning.main then return end
	            warning.main.Visible = false
	        end
	
	        return warning
	    end
	
	    function library:Close()
	        self.open = not self.open
	
	        if self.main then
	            if self.popup then
	                self.popup:Close()
	            end
	
	            self.base.Enabled = self.open
	        end
	
	        library.tooltip.Position = UDim2.fromScale(10, 10);
	    end
	
	    function library:Init(silent)
	        if self.hasInit then return end
	
	        self.hasInit = true
	        self.base = library:Create('ScreenGui', {IgnoreGuiInset = true, AutoLocalize = false, Enabled = not silent})
	        self.dummyBox = library:Create('TextBox', {Visible = false, Parent = self.base});
	        self.dummyModal = library:Create('TextButton', {Visible = false, Modal = true, Parent = self.base});
	
	        self.unloadMaid:GiveTask(self.base);
	
	        self.base.Parent = CoreGui
	
	        self.main = self:Create('ImageButton', {
	            AutoButtonColor = false,
	            Position = UDim2.new(0, 100, 0, 46),
	            Size = UDim2.new(0, 500, 0, 600),
	            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	            BorderColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Tile,
	            Visible = true,
	            Parent = self.base
	        })
	
	        local top = self:Create('Frame', {
	            Size = UDim2.new(1, 0, 0, 50),
	            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	            BorderColor3 = Color3.new(),
	            Parent = self.main
	        })
	
	        self.titleLabel = self:Create('TextLabel', {
	            Position = UDim2.new(0, 6, 0, -1),
	            Size = UDim2.new(0, 0, 0, 20),
	            BackgroundTransparency = 1,
	            Text = tostring(self.title),
	            Font = Enum.Font.Code,
	            TextSize = 18,
	            TextColor3 = Color3.new(1, 1, 1),
	            TextXAlignment = Enum.TextXAlignment.Left,
	            Parent = self.main
	        })
	
	        table.insert(library.theme, self:Create('Frame', {
	            Size = UDim2.new(1, 0, 0, 1),
	            Position = UDim2.new(0, 0, 0, 24),
	            BackgroundColor3 = library.flags.menuAccentColor,
	            BorderSizePixel = 0,
	            Parent = self.main
	        }))
	
	        library:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2454009026',
	            ImageColor3 = Color3.new(),
	            ImageTransparency = 0.4,
	            Parent = top
	        })
	
	        self.tabHighlight = self:Create('Frame', {
	            BackgroundColor3 = library.flags.menuAccentColor,
	            BorderSizePixel = 0,
	            Parent = self.main
	        })
	        table.insert(library.theme, self.tabHighlight)
	
	        self.columnHolder = self:Create('Frame', {
	            Position = UDim2.new(0, 5, 0, 55),
	            Size = UDim2.new(1, -10, 1, -60),
	            BackgroundTransparency = 1,
	            Parent = self.main
	        })
	
	        self.tooltip = self:Create('TextLabel', {
	            ZIndex = 2,
	            BackgroundTransparency = 1,
	            BorderSizePixel = 0,
	            TextSize = 15,
	            Size = UDim2.fromOffset(0, 0),
	            Position = UDim2.fromScale(10, 10),
	            Font = Enum.Font.Code,
	            TextColor3 = Color3.new(1, 1, 1),
	            Visible = true,
	            Active = false,
	            TextWrapped = true,
	            TextXAlignment = Enum.TextXAlignment.Left,
	            Parent = self.base,
	            AutomaticSize = Enum.AutomaticSize.XY
	        })
	
	        self:Create('UISizeConstraint', {
	            Parent = self.tooltip,
	            MaxSize = Vector2.new(400, 1000),
	            MinSize = Vector2.new(0, 0),
	        });
	
	        self:Create('Frame', {
	            AnchorPoint = Vector2.new(0.5, 0),
	            Position = UDim2.new(0.5, 0, 0, 0),
	            Size = UDim2.new(1, 10, 1, 0),
	            Active = false,
	            Style = Enum.FrameStyle.RobloxRound,
	            Parent = self.tooltip
	        })
	
	        self:Create('ImageLabel', {
	            Size = UDim2.new(1, 0, 1, 0),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.fromRGB(60, 60, 60),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = self.main
	        })
	
	        self:Create('ImageLabel', {
	            Size = UDim2.new(1, -2, 1, -2),
	            Position = UDim2.new(0, 1, 0, 1),
	            BackgroundTransparency = 1,
	            Image = 'rbxassetid://2592362371',
	            ImageColor3 = Color3.new(),
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 62, 62),
	            Parent = self.main
	        })
	
	        library.unloadMaid:GiveTask(top.InputBegan:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                dragObject = self.main
	                dragging = true
	                dragStart = input.Position
	                startPos = dragObject.Position
	                if library.popup then library.popup:Close() end
	            end
	        end));
	
	        library.unloadMaid:GiveTask(top.InputChanged:connect(function(input)
	            if dragging and input.UserInputType.Name == 'MouseMovement' then
	                dragInput = input
	            end
	        end));
	
	        library.unloadMaid:GiveTask(top.InputEnded:connect(function(input)
	            if input.UserInputType.Name == 'MouseButton1' then
	                dragging = false
	            end
	        end));
	
	        local titleTextSize = TextService:GetTextSize(self.titleLabel.Text, 18, Enum.Font.Code, Vector2.new(1000, 0));
	
	        local searchLabel = library:Create('ImageLabel', {
	            Position = UDim2.new(0, titleTextSize.X + 10, 0.5, -8),
	            Size = UDim2.new(0, 16, 0, 16),
	            BackgroundTransparency = 1,
	            Image = 'rbxasset://textures/ui/Settings/ShareGame/icons.png',
	            ImageRectSize = Vector2.new(16, 16),
	            ImageRectOffset = Vector2.new(6, 106),
	            ClipsDescendants = true,
	            Parent = self.titleLabel
	        });
	
	        local searchBox = library:Create('TextBox', {
	            BackgroundTransparency = 1,
	            Position = UDim2.fromOffset(searchLabel.AbsolutePosition.X-80, 5),
	            Size = UDim2.fromOffset(50, 15),
	            TextColor3 = Color3.fromRGB(255, 255, 255),
	            TextXAlignment = Enum.TextXAlignment.Left,
	            Parent = self.titleLabel,
	            Text = '',
	            PlaceholderText = 'Type something to search...',
	            Visible = false
	        });
	
	        local searchContainer = library:Create('ScrollingFrame', {
	            BackgroundTransparency = 1,
	            Visible = false,
	            Size = UDim2.fromScale(1, 1),
	            AutomaticCanvasSize = Enum.AutomaticSize.Y,
	            Parent = library.columnHolder,
	            BorderSizePixel = 0,
	            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
	            ScrollBarThickness = 6,
	            CanvasSize = UDim2.new(),
	            ScrollingDirection = Enum.ScrollingDirection.Y,
	            VerticalScrollBarInset = Enum.ScrollBarInset.Always,
	            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	        });
	
	        library:Create('UIListLayout', {
	            Parent = searchContainer
	        })
	
	        local allFoundResults = {};
	        local modifiedNames = {};
	
	        local function clearFoundResult()
	            for _, option in next, allFoundResults do
	                option.main.Parent = option.originalParent;
	            end;
	
	            for _, option in next, modifiedNames do
	                option.title.Text = option.text;
	                option.main.Parent = option.originalParent;
	            end;
	
	            table.clear(allFoundResults);
	            table.clear(modifiedNames);
	        end;
	
	        local sFind, sLower = string.find, string.lower;
	
	        library.unloadMaid:GiveTask(searchBox:GetPropertyChangedSignal('Text'):Connect(function()
	            local text = string.lower(searchBox.Text):gsub('%s', '');
	
	            for _, v in next, library.options do
	                if (not v.originalParent) then
	                    v.originalParent = v.main.Parent;
	                end;
	            end;
	
	            clearFoundResult();
	
	            for _, v in next, library.currentTab.columns do
	                v.main.Visible = text == '' and true or false;
	            end;
	
	            if (text == '') then return; end;
	            local matchedResults = false;
	
	            for _, v in next, library.options do
	                local main = v.main;
	
	                if (v.text == 'Enable' or v.parentFlag) then
	                    if (v.type == 'toggle' or v.type == 'bind') then
	                        local parentName = v.parentFlag and 'Bind' or v.section.title;
	                        v.title.Text = string.format('%s [%s]', v.text, parentName);
	
	                        table.insert(modifiedNames, v);
	                    end;
	                end;
	
	                if (sFind(sLower(v.text), text) or sFind(sLower(v.flag), text)) then
	                    matchedResults = true;
	                    main.Parent = searchContainer;
	                    table.insert(allFoundResults, v);
	                else
	                    main.Parent = v.originalParent;
	                end;
	            end;
	
	            searchContainer.Visible = matchedResults;
	        end));
	
	        library.unloadMaid:GiveTask(searchLabel.InputBegan:Connect(function(inputObject)
	            if(inputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return end;
	            searchBox.Visible = true;
	            searchBox:CaptureFocus();
	        end));
	
	        library.unloadMaid:GiveTask(searchBox.FocusLost:Connect(function()
	            if (searchBox.Text:gsub('%s', '') ~= '') then return end;
	            searchBox.Visible = false;
	        end));
	
	
	        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	
	        function self:selectTab(tab)
	            if self.currentTab == tab then return end
	            if library.popup then library.popup:Close() end
	            clearFoundResult();
	            searchBox.Visible = false;
	            searchBox.Text = '';
	
	            if self.currentTab then
	                self.currentTab.button.TextColor3 = Color3.fromRGB(255, 255, 255)
	                for _, column in next, self.currentTab.columns do
	                    column.main.Parent = nil;
	                    column.main.Visible = true;
	                end
	            end
	            self.main.Size = UDim2.new(0, 16 + ((#tab.columns < 2 and 2 or #tab.columns) * 239), 0, 600)
	            self.currentTab = tab
	            tab.button.TextColor3 = library.flags.menuAccentColor;
	
	            TweenService:Create(self.tabHighlight, tweenInfo, {
	                Position = UDim2.new(0, tab.button.Position.X.Offset, 0, 50),
	                Size = UDim2.new(0, tab.button.AbsoluteSize.X, 0, -1)
	            }):Play();
	
	            for _, column in next, tab.columns do
	                column.main.Parent = self.columnHolder
	            end
	        end
	
	        task.spawn(function()
	            while library do
	                local Configs = self:GetConfigs()
	                for _, config in next, Configs do
	                    if config ~= 'nil' and not table.find(self.options.configList.values, config) then
	                        self.options.configList:AddValue(config)
	                    end
	                end
	                for _, config in next, self.options.configList.values do
	                    if config ~= 'nil' and not table.find(Configs, config) then
	                        self.options.configList:RemoveValue(config)
	                    end
	                end
	                task.wait(1);
	            end
	        end)
	
	        for _, tab in next, self.tabs do
	            if tab.canInit then
	                tab:Init();
	            end;
	        end;
	
	        self:AddConnection(UserInputService.InputEnded, function(input)
	            if (input.UserInputType.Name == 'MouseButton1') and self.slider then
	                self.slider.slider.BorderColor3 = Color3.new();
	                self.slider = nil;
	            end;
	        end);
	
	        self:AddConnection(UserInputService.InputChanged, function(input)
	            if self.open then
	                if input == dragInput and dragging and library.draggable then
	                    local delta = input.Position - dragStart;
	                    local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y;
	
	                    dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), 'Out', 'Quint', 0.1, true);
	                end;
	
	                if self.slider and input.UserInputType.Name == 'MouseMovement' then
	                    self.slider:SetValue(self.slider.min + ((input.Position.X - self.slider.slider.AbsolutePosition.X) / self.slider.slider.AbsoluteSize.X) * (self.slider.max - self.slider.min));
	                end;
	            end;
	        end);
	
	        local configData = readFileAndDecodeIt(library.foldername .. '/' .. library.fileext);
	
	        if (configData) then
	            library.configVars = configData;
	            library:LoadConfig(configData.config);
	
	            library.OnLoad:Connect(function()
	                library.options.configList:SetValue(library.loadedConfig or 'default');
	            end);
	        else
	            print('[Script] [Config Loader] An error has occured', configData);
	        end;
	
	        self:selectTab(self.tabs[1]);
	
	        if (not silent) then
	            self:Close();
	        else
	            self.open = false;
	        end;
	
	        library.OnLoad:Fire();
	        library.OnLoad:Destroy();
	        library.OnLoad = nil;
	    end;
	
	    function library:SetTitle(text)
	        if (not self.titleLabel) then
	            return;
	        end;
	
	        self.titleLabel.Text = text;
	    end;
	
	    do -- // Load Basics
	        local configWarning = library:AddWarning({type = 'confirm'})
	        local messageWarning = library:AddWarning();
	
	        function library:ShowConfirm(text)
	            configWarning.text = text;
	            return configWarning:Show();
	        end;
	
	        function library:ShowMessage(text)
	            messageWarning.text = text;
	            return messageWarning:Show();
	        end
	
	        local function showBasePrompt(text)
	            local r, g, b = library.round(library.flags.menuAccentColor);
	
	            local configName = text == 'create' and library.flags.configName or library.flags.configList;
	            local trimedValue = configName:gsub('%s', '');
	
	            if(trimedValue == '') then
	                library:ShowMessage(string.format('Can not %s a config with no name !', text));
	                return false;
	            end;
	
	            return library:ShowConfirm(string.format(
	                'Are you sure you want to %s config <font color=\'rgb(%s, %s, %s)\'>%s</font>',
	                text,
	                r,
	                g,
	                b,
	                configName
	            ));
	        end;
	
	        local joinDiscord;
	
	        do -- // Utils
	            function joinDiscord(code)
	                for i = 6463, 6472 do -- // Just cause there is a 10 range port
	                    if(pcall(function()
	                        request({
	                            Url = ('http://127.0.0.1:%s/rpc?v=1'):format(i),
	                            Method = 'POST',
	                            Headers = {
	                                ['Content-Type'] = 'application/json',
	                                Origin = 'https://discord.com' -- // memery moment
	                            },
	                            Body = ('{"cmd":"INVITE_BROWSER","args":{"code":"%s"},"nonce":"%s"}'):format(code, string.lower(HttpService:GenerateGUID(false)))
	                        });
	                    end)) then
	                        print('found port', i);
	                        break;
	                    end;
	                end;
	            end;
	        end;
	
	        local maid = Maid.new();
	        library.unloadMaid:GiveTask(function()
	            maid:Destroy();
	        end);
	
	        local settingsTab       = library:AddTab('Settings', 100);
	        local settingsColumn    = settingsTab:AddColumn();
	        local settingsColumn1   = settingsTab:AddColumn();
	        local settingsMain      = settingsColumn:AddSection('Main');
	        local settingsMenu      = settingsColumn:AddSection('Menu');
	        local configSection     = settingsColumn1:AddSection('Configs');
	        local discordSection    = settingsColumn:AddSection('Discord');
	        local BackgroundArray   = {};
	
	        local Backgrounds = {
	            Floral  = 5553946656,
	            Flowers = 6071575925,
	            Circles = 6071579801,
	            Hearts  = 6073763717,
	        };
	
	        task.spawn(function()
	            for i, v in next, Backgrounds do
	                table.insert(BackgroundArray, 'rbxassetid://' .. v);
	            end;
	
	            ContentProvider:PreloadAsync(BackgroundArray);
	        end);
	
	        local lastShownNotifAt = 0;
	
	        local function setCustomBackground()
	            local imageURL = library.flags.customBackground;
	            imageURL = imageURL:gsub('%s', '');
	
	            if (imageURL == '') then return end;
	
	            if (not isfolder('Aztup Hub V3/CustomBackgrounds')) then
	                makefolder('Aztup Hub V3/CustomBackgrounds');
	            end;
	
	            local path = string.format('Aztup Hub V3/CustomBackgrounds/%s.bin', crypt.hash(imageURL));
	
	            if (not isfile(path)) then
	                local suc, httpRequest = pcall(request, {
	                    Url = imageURL,
	                });
	
	                if (not suc) then return library:ShowMessage('The url you have specified for the custom background is invalid.'); end;
	
	                if (not httpRequest.Success) then return library:ShowMessage(string.format('Request failed %d', httpRequest.StatusCode)); end;
	                local imgType = httpRequest.Headers['Content-Type']:lower();
	                if (imgType ~= 'image/png' and imgType ~= 'image/jpeg') then return library:ShowMessage('Only PNG and JPEG are supported'); end;
	
	                writefile(path, httpRequest.Body);
	            end;
	
	            library.main.Image = getsynasset(path);
	
	            local acColor = library.flags.menuBackgroundColor;
	            local r, g, b = acColor.R * 255, acColor.G * 255, acColor.B * 255;
	
	            if (r <= 100 and g <= 100 and b <= 100 and tick() - lastShownNotifAt > 1) then
	                lastShownNotifAt = tick();
	                ToastNotif.new({text = 'Your menu accent color is dark custom background may not show.', duration = 20});
	            end;
	        end;
	
	        settingsMain:AddBox({
	            text = 'Custom Background',
	            tip = 'Put a valid image link here',
	            callback = setCustomBackground
	        });
	
	        library.OnLoad:Connect(function()
	            local customBackground = library.flags.customBackground;
	            if (customBackground:gsub('%s', '') == '') then return end;
	
	            task.defer(setCustomBackground);
	        end);
	
	        do
	            local scaleTypes = {};
	
	            for _, scaleType in next, Enum.ScaleType:GetEnumItems() do
	                table.insert(scaleTypes, scaleType.Name);
	            end;
	
	            settingsMain:AddList({
	                text = 'Background Scale Type',
	                values = scaleTypes,
	                callback = function()
	                    library.main.ScaleType = Enum.ScaleType[library.flags.backgroundScaleType];
	                end
	            });
	        end;
	
	        settingsMain:AddButton({
	            text = 'Unload Menu',
	            nomouse = true,
	            callback = function()
	                library:Unload()
	            end
	        });
	
	        settingsMain:AddBind({
	            text = 'Unload Key',
	            nomouse = true,
	            callback = library.options.unloadMenu.callback
	        });
	
	        -- settingsMain:AddToggle({
	        --     text = 'Remote Control'
	        -- });
	
	        settingsMenu:AddBind({
	            text = 'Open / Close',
	            flag = 'UI Toggle',
	            nomouse = true,
	            key = 'LeftAlt',
	            callback = function() library:Close() end
	        })
	
	        settingsMenu:AddColor({
	            text = 'Accent Color',
	            flag = 'Menu Accent Color',
	            color = Color3.fromRGB(18, 127, 253),
	            callback = function(Color)
	                if library.currentTab then
	                    library.currentTab.button.TextColor3 = Color
	                end
	
	                for _, obj in next, library.theme do
	                    obj[(obj.ClassName == 'TextLabel' and 'TextColor3') or (obj.ClassName == 'ImageLabel' and 'ImageColor3') or 'BackgroundColor3'] = Color
	                end
	            end
	        })
	
	        settingsMenu:AddToggle({
	            text = 'Keybind Visualizer',
	            state = true,
	            callback = function(state)
	                return visualizer:SetEnabled(state);
	            end
	        }):AddColor({
	            text = 'Keybind Visualizer Color',
	            callback = function(color)
	                return visualizer:UpdateColor(color);
	            end
	        });
	
	        settingsMenu:AddToggle({
	            text = 'Rainbow Keybind Visualizer',
	            callback = function(t)
	                if (not t) then
	                    return maid.rainbowKeybindVisualizer;
	                end;
	
	                maid.rainbowKeybindVisualizer = task.spawn(function()
	                    while task.wait() do
	                        visualizer:UpdateColor(library.chromaColor);
	                    end;
	                end);
	            end
	        })
	
	        settingsMenu:AddList({
	            text = 'Background',
	            flag = 'UI Background',
	            values = {'Floral', 'Flowers', 'Circles', 'Hearts'},
	            callback = function(Value)
	                if Backgrounds[Value] then
	                    library.main.Image = 'rbxassetid://' .. Backgrounds[Value]
	                end
	            end
	        }):AddColor({
	            flag = 'Menu Background Color',
	            color = Color3.new(),
	            trans = 1,
	            callback = function(Color)
	                library.main.ImageColor3 = Color
	            end,
	            calltrans = function(Value)
	                library.main.ImageTransparency = 1 - Value
	            end
	        });
	
	        settingsMenu:AddSlider({
	            text = 'Tile Size',
	            value = 90,
	            min = 50,
	            max = 500,
	            callback = function(Value)
	                library.main.TileSize = UDim2.new(0, Value, 0, Value)
	            end
	        })
	
	        configSection:AddBox({
	            text = 'Config Name',
	            skipflag = true,
	        })
	
	        local function getAllConfigs()
	            local files = {};
	
	            for _, v in next, listfiles('Aztup Hub V3/configs') do
	                if (not isfolder(v)) then continue; end;
	
	                for _, v2 in next, listfiles(v) do
	                    local configName = v2:match('(%w+).config.json');
	                    if (not configName) then continue; end;
	
	                    local folderName = v:match('configs\\(%w+)');
	                    local fullConfigName = string.format('%s - %s', folderName, configName);
	
	                    table.insert(files, fullConfigName);
	                end;
	            end;
	
	            return files;
	        end;
	
	        local function updateAllConfigs()
	            for _, v in next, library.options.loadFromList.values do
	                library.options.loadFromList:RemoveValue(v);
	            end;
	
	            for _, configName in next, getAllConfigs() do
	                library.options.loadFromList:AddValue(configName);
	            end;
	        end
	
	        configSection:AddList({
	            text = 'Configs',
	            skipflag = true,
	            value = '',
	            flag = 'Config List',
	            values = library:GetConfigs(),
	        })
	
	        configSection:AddButton({
	            text = 'Create',
	            callback = function()
	                if (showBasePrompt('create')) then
	                    library.options.configList:AddValue(library.flags.configName);
	                    library.options.configList:SetValue(library.flags.configName);
	                    library:SaveConfig(library.flags.configName);
	                    library:LoadConfig(library.flags.configName);
	
	                    updateAllConfigs();
	                end;
	            end
	        })
	
	        local btn;
	        btn = configSection:AddButton({
	            text = isGlobalConfigOn and 'Switch To Local Config' or 'Switch to Global Config';
	
	            callback = function()
	                isGlobalConfigOn = not isGlobalConfigOn;
	                writefile(globalConfFilePath, tostring(isGlobalConfigOn));
	
	                btn:SetText(isGlobalConfigOn and 'Switch To Local Config' or 'Switch to Global Config');
	                library:ShowMessage('Note: Switching from Local to Global requires script relaunch.');
	            end
	        });
	
	        configSection:AddButton({
	            text = 'Save',
	            callback = function()
	                if (showBasePrompt('save')) then
	                    library:SaveConfig(library.flags.configList);
	                end;
	            end
	        }):AddButton({
	            text = 'Load',
	            callback = function()
	                if (showBasePrompt('load')) then
	                    library:UpdateConfig(); -- Save config before switching to new one
	                    library:LoadConfig(library.flags.configList);
	                end
	            end
	        }):AddButton({
	            text = 'Delete',
	            callback = function()
	                if (showBasePrompt('delete')) then
	                    local Config = library.flags.configList
	                    local configFilePath = library.foldername .. '/' .. Config .. '.config' .. library.fileext;
	
	                    if table.find(library:GetConfigs(), Config) and isfile(configFilePath) then
	                        library.options.configList:RemoveValue(Config)
	                        delfile(configFilePath);
	                    end
	                end;
	            end
	        })
	
	        configSection:AddList({
	            text = 'Load From',
	            flag = 'Load From List',
	            values = getAllConfigs()
	        });
	
	        configSection:AddButton({
	            text = 'Load From',
	            callback = function()
	                if (not showBasePrompt('load from')) then return; end;
	                if (isGlobalConfigOn) then return library:ShowMessage('You can not load a config from another user if you are in global config mode.'); end;
	
	                local folderName, configName = library.flags.loadFromList:match('(%w+) %p (.+)');
	                local fullConfigName = string.format('%s.config.json', configName);
	
	                if (isfile(library.foldername .. '/' .. fullConfigName)) then
	                    -- If there is already an existing config with this name then
	
	                    if (not library:ShowConfirm('There is already a config with this name in your config folder. Would you like to delete it? Pressing no will cancel the operation')) then
	                        return;
	                    end;
	                end;
	
	                local configData = readfile(string.format('Aztup Hub V3/configs/%s/%s', folderName, fullConfigName));
	                writefile(string.format('%s/%s', library.foldername, fullConfigName), configData);
	
	                library:LoadConfig(configName);
	            end
	        })
	
	        configSection:AddToggle({
	            text = 'Automatically Save Config',
	            state = true,
	            flag = 'saveConfigAuto',
	            callback = function(toggle)
	                -- This is required incase the game crash but we can move the interval to 60 seconds
	
	                if(not toggle) then
	                    maid.saveConfigAuto = nil;
	                    library:UpdateConfig(); -- Make sure that we update config to save that user turned off automatically save config
	                    return;
	                end;
	
	                maid.saveConfigAuto = task.spawn(function()
	                    while true do
	                        task.wait(60);
	                        library:UpdateConfig();
	                    end;
	                end);
	            end,
	        })
	
	        local function saveConfigBeforeGameLeave()
	            if (not library.flags.saveconfigauto) then return; end;
	            library:UpdateConfig();
	        end;
	
	        library.unloadMaid:GiveTask(GuiService.NativeClose:Connect(saveConfigBeforeGameLeave));
	
	        -- NativeClose does not fire on the Lua App
	        library.unloadMaid:GiveTask(GuiService.MenuOpened:Connect(saveConfigBeforeGameLeave));
	
	        library.unloadMaid:GiveTask(LocalPlayer.OnTeleport:Connect(function(state)
	            if (state ~= Enum.TeleportState.Started and state ~= Enum.TeleportState.RequestedFromServer) then return end;
	            saveConfigBeforeGameLeave();
	        end));
	
	        discordSection:AddButton({
	            text = 'Join Discord',
	            callback = function() return joinDiscord('gWCk7pTXNs') end
	        });
	
	        discordSection:AddButton({
	            text = 'Copy Discord Invite',
	            callback = function() return setclipboard('discord.gg/gWCk7pTXNs') end
	        });
	    end;
	end;
	
	warn(string.format('[Script] [Library] Loaded in %.02f seconds', tick() - libraryLoadAt));
	
	library.OnFlagChanged:Connect(function(data)
	    local keybindExists = library.options[string.lower(data.flag) .. 'Bind'];
	    if (not keybindExists or not keybindExists.key or keybindExists.key == 'none') then return end;
	
	    local toggled = library.flags[data.flag];
	
	    if (toggled) then
	        visualizer:AddText(data.text);
	    else
	        visualizer:RemoveText(data.text);
	    end
	end);
	
	return library;
end)();

sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'] = (function()
	
	
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	
	local Players, UserInputService, HttpService, CollectionService = Services:Get('Players', 'UserInputService', 'HttpService', 'CollectionService');
	local LocalPlayer = Players.LocalPlayer;
	
	local Utility = {};
	
	Utility.onPlayerAdded = Signal.new();
	Utility.onCharacterAdded = Signal.new();
	Utility.onLocalCharacterAdded = Signal.new();
	
	local mathFloor = clonefunction(math.floor)
	local isDescendantOf = clonefunction(game.IsDescendantOf);
	local findChildIsA = clonefunction(game.FindFirstChildWhichIsA);
	local findFirstChild = clonefunction(game.FindFirstChild);
	
	local IsA = clonefunction(game.IsA);
	
	local getMouseLocation = clonefunction(UserInputService.GetMouseLocation);
	local getPlayers = clonefunction(Players.GetPlayers);
	
	local worldToViewportPoint = clonefunction(Instance.new("Camera").WorldToViewportPoint);
	
	function Utility:countTable(t)
	    local found = 0;
	
	    for i, v in next, t do
	        found = found + 1;
	    end;
	
	    return found;
	end;
	
	function Utility:roundVector(vector)
	    return Vector3.new(vector.X, 0, vector.Z);
	end;
	
	function Utility:getCharacter(player)
	    local playerData = self:getPlayerData(player);
	    if (not playerData.alive) then return end;
	
	    local maxHealth, health = playerData.maxHealth, playerData.health;
	    return playerData.character, maxHealth, (health / maxHealth) * 100, mathFloor(health), playerData.rootPart;
	end;
	
	function Utility:isTeamMate(player)
	    local playerData, myPlayerData = self:getPlayerData(player), self:getPlayerData();
	    local playerTeam, myTeam = playerData.team, myPlayerData.team;
	
	    if(playerTeam == nil or myTeam == nil) then
	        return false;
	    end;
	
	    return playerTeam == myTeam;
	end;
	
	function Utility:getRootPart(player)
	    local playerData = self:getPlayerData(player);
	    return playerData and playerData.rootPart;
	end;
	
	function Utility:renderOverload(data) end;
	
	local function castPlayer(origin, direction, rayParams, playerToFind)
	    local distanceTravalled = 0;
	
	    while true do
	        distanceTravalled = distanceTravalled + direction.Magnitude;
	
	        local target = workspace:Raycast(origin, direction, rayParams);
	
	        if(target) then
	            if(isDescendantOf(target.Instance, playerToFind)) then
	                return false;
	            elseif(target and target.Instance.CanCollide) then
	                return true;
	            end;
	        elseif(distanceTravalled > 2000) then
	            return false;
	        end;
	
	        origin = origin + direction;
	    end;
	end;
	
	function Utility:getClosestCharacter(rayParams)
	    rayParams = rayParams or RaycastParams.new();
	    rayParams.FilterDescendantsInstances = {}
	
	    local myCharacter = Utility:getCharacter(LocalPlayer);
	    local myHead = myCharacter and findFirstChild(myCharacter, 'Head');
	    if(not myHead) then return end;
	
	    if(rayParams.FilterType == Enum.RaycastFilterType.Blacklist) then
	        table.insert(rayParams.FilterDescendantsInstances, myHead.Parent);
	    end;
	
	    local camera = workspace.CurrentCamera;
	    if(not camera) then return end;
	
	    local mousePos = library.flags.useFOV and getMouseLocation(UserInputService);
	    local lastDistance, lastPlayer = math.huge, {};
	
	    local maxFov = library.flags.useFOV and library.flags.aimbotFOV or math.huge;
	    local whitelistedPlayers = library.options.aimbotWhitelistedPlayers.values;
	
	    for _, player in next, getPlayers(Players) do
	        if(player == LocalPlayer or table.find(whitelistedPlayers, player.Name)) then continue end;
	
	        local character, health = Utility:getCharacter(player);
	
	        if(not character or health <= 0 or findChildIsA(character, 'ForceField')) then continue; end;
	        if(library.flags.checkTeam and Utility:isTeamMate(player)) then continue end;
	
	        local head = character and findFirstChild(character, 'Head');
	        if(not head) then continue end;
	
	        local newDistance = (myHead.Position - head.Position).Magnitude;
	        if(newDistance > lastDistance) then continue end;
	
	        if (mousePos) then
	            local screenPosition, visibleOnScreen = worldToViewportPoint(camera, head.Position);
	            screenPosition = Vector2.new(screenPosition.X, screenPosition.Y);
	
	            if((screenPosition - mousePos).Magnitude > maxFov or not visibleOnScreen) then continue end;
	        end;
	
	        local isBehindWall = library.flags.visibilityCheck and castPlayer(myHead.Position, (head.Position - myHead.Position).Unit * 100, rayParams, head.Parent);
	        if (isBehindWall) then continue end;
	
	        lastPlayer = {Player = player, Character = character, Health = health};
	        lastDistance = newDistance;
	    end;
	
	    return lastPlayer, lastDistance;
	end;
	
	function Utility:getClosestCharacterWithEntityList(entityList, rayParams, options)
	    rayParams = rayParams or RaycastParams.new();
	    rayParams.FilterDescendantsInstances = {}
	
	    options = options or {};
	    options.maxDistance = options.maxDistance or math.huge;
	
	    local myCharacter = Utility:getCharacter(LocalPlayer);
	    local myHead = myCharacter and findFirstChild(myCharacter, 'Head');
	    if(not myHead) then return end;
	
	    if(rayParams.FilterType == Enum.RaycastFilterType.Blacklist) then
	        table.insert(rayParams.FilterDescendantsInstances, myHead.Parent);
	    end;
	
	    local camera = workspace.CurrentCamera;
	    if(not camera) then return end;
	
	    local mousePos = library.flags.useFOV and getMouseLocation(UserInputService);
	    local lastDistance, lastPlayer = math.huge, {};
	    local whitelistedPlayers = library.options.aimbotWhitelistedPlayers.values;
	
	    local maxFov = library.flags.useFOV and library.flags.aimbotFOV or math.huge;
	
	    for _, player in next, entityList do
	        if(player == myCharacter or table.find(whitelistedPlayers, player.Name)) then continue end;
	
	        local humanoid = findChildIsA(player, 'Humanoid');
	        if (not humanoid or humanoid.Health <= 0) then continue end;
	
	        local character = player;
	
	        if(not character or findChildIsA(character, 'ForceField')) then continue; end;
	
	        local head = character and findFirstChild(character, 'Head');
	        if(not head) then continue end;
	
	        local newDistance = (myHead.Position - head.Position).Magnitude;
	        if(newDistance > lastDistance or newDistance > options.maxDistance) then continue end;
	
	        if (mousePos) then
	            local screenPosition, visibleOnScreen = worldToViewportPoint(camera, head.Position);
	            screenPosition = Vector2.new(screenPosition.X, screenPosition.Y);
	
	            if((screenPosition - mousePos).Magnitude > maxFov or not visibleOnScreen) then continue end;
	        end;
	
	        local isBehindWall = library.flags.visibilityCheck and castPlayer(myHead.Position, (head.Position - myHead.Position).Unit * 100, rayParams, head.Parent);
	        if (isBehindWall) then continue end;
	
	        lastPlayer = {Player = player, Character = character, Health = humanoid.Health};
	        lastDistance = newDistance;
	    end;
	
	    return lastPlayer, lastDistance;
	end;
	
	function panic()
	    library:Unload();
	end;
	
	local playersData = {};
	
	local function onCharacterAdded(player)
	    local playerData = playersData[player];
	    if (not playerData) then return end;
	
	    local character = player.Character;
	    if (not character) then return end;
	
	    local localAlive = true;
	
	    table.clear(playerData.parts);
	
	    Utility.listenToChildAdded(character, function(obj)
	        if (obj.Name == 'Humanoid') then
	            playerData.humanoid = obj;
	        elseif (obj.Name == 'HumanoidRootPart') then
	            playerData.rootPart = obj;
	        elseif (obj.Name == 'Head') then
	            playerData.head = obj;
	        end;
	    end);
	
	    if (player == LocalPlayer) then
	        Utility.listenToDescendantAdded(character, function(obj)
	            if (IsA(obj, 'BasePart')) then
	                table.insert(playerData.parts, obj);
	
	                local con;
	                con = obj:GetPropertyChangedSignal('Parent'):Connect(function()
	                    if (obj.Parent) then return end;
	                    con:Disconnect();
	                    table.remove(playerData.parts, table.find(playerData.parts, obj));
	                end);
	            end;
	        end);
	    end;
	
	    local function onPrimaryPartChanged()
	        playerData.primaryPart = character.PrimaryPart;
	        playerData.alive = not not playerData.primaryPart;
	    end
	
	    local hum = character:WaitForChild('Humanoid', 30);
	    playerData.humanoid = hum;
	    if (not playerData.humanoid) then return warn('[Utility] [onCharacterAdded] Player is missing humanoid ' .. player:GetFullName()) end;
	    if (not player.Parent or not character.Parent) then return end;
	
	    character:GetPropertyChangedSignal('PrimaryPart'):Connect(onPrimaryPartChanged);
	
	    if (character.PrimaryPart) then
	        onPrimaryPartChanged();
	    end;
	
	    playerData.character = character;
	    playerData.alive = true;
	    playerData.health = playerData.humanoid.Health;
	    playerData.maxHealth = playerData.humanoid.MaxHealth;
	
	    hum.Destroying:Connect(function()
	        playerData.alive = false;
	        localAlive = false;
	    end);
	
	    hum.Died:Connect(function()
	        playerData.alive = false;
	        localAlive = false;
	    end);
	
	    playerData.humanoid:GetPropertyChangedSignal('Health'):Connect(function()
	        playerData.health = hum.Health;
	    end);
	
	    playerData.humanoid:GetPropertyChangedSignal('MaxHealth'):Connect(function()
	        playerData.maxHealth = hum.MaxHealth;
	    end);
	
	    local function fire()
	        if (not localAlive) then return end;
	        Utility.onCharacterAdded:Fire(playerData);
	
	        if (player == LocalPlayer) then
	            Utility.onLocalCharacterAdded:Fire(playerData);
	        end;
	    end;
	
	    if (library.OnLoad) then
	        library.OnLoad:Connect(fire);
	    else
	        fire();
	    end;
	end;
	
	local function onPlayerAdded(player)
	    local playerData = {};
	
	    playerData.player = player;
	    playerData.team = player.Team;
	    playerData.parts = {};
	
	    playersData[player] = playerData;
	
	    local function fire()
	        Utility.onPlayerAdded:Fire(player);
	    end;
	
	    task.spawn(onCharacterAdded, player);
	
	    player.CharacterAdded:Connect(function()
	        onCharacterAdded(player);
	    end);
	
	    player:GetPropertyChangedSignal('Team'):Connect(function()
	        playerData.team = player.Team;
	    end);
	
	    if (library.OnLoad) then
	        library.OnLoad:Connect(fire);
	    else
	        fire();
	    end;
	end;
	
	function Utility:getPlayerData(player)
	    return playersData[player or LocalPlayer] or {};
	end;
	
	function Utility.listenToChildAdded(folder, listener, options)
	    options = options or {listenToDestroying = false};
	
	    local createListener = typeof(listener) == 'table' and listener.new or listener;
	
	    assert(typeof(folder) == 'Instance', 'listenToChildAdded folder #1 listener has to be an instance');
	    assert(typeof(createListener) == 'function', 'listenToChildAdded #2 listener has to be a function');
	
	    local function onChildAdded(child)
	        local listenerObject = createListener(child);
	
	        if (options.listenToDestroying) then
	            child.Destroying:Connect(function()
	                local removeListener = typeof(listener) == 'table' and (function() local a = (listener.Destroy or listener.Remove); a(listenerObject) end) or listenerObject;
	
	                if (typeof(removeListener) ~= 'function') then
	                    warn('[Utility] removeListener is not definded possible memory leak for', folder);
	                else
	                    removeListener(child);
	                end;
	            end);
	        end;
	    end
	
	    debug.profilebegin(string.format('Utility.listenToChildAdded(%s)', folder:GetFullName()));
	
	    for _, child in next, folder:GetChildren() do
	        task.spawn(onChildAdded, child);
	    end;
	
	    debug.profileend();
	
	    return folder.ChildAdded:Connect(createListener);
	end;
	
	function Utility.listenToChildRemoving(folder, listener)
	    local createListener = typeof(listener) == 'table' and listener.new or listener;
	
	    assert(typeof(folder) == 'Instance', 'listenToChildRemoving folder #1 listener has to be an instance');
	    assert(typeof(createListener) == 'function', 'listenToChildRemoving #2 listener has to be a function');
	
	    return folder.ChildRemoved:Connect(createListener);
	end;
	
	function Utility.listenToDescendantAdded(folder, listener, options)
	    options = options or {listenToDestroying = false};
	
	    local createListener = typeof(listener) == 'table' and listener.new or listener;
	
	    assert(typeof(folder) == 'Instance', 'listenToDescendantAdded folder #1 listener has to be an instance');
	    assert(typeof(createListener) == 'function', 'listenToDescendantAdded #2 listener has to be a function');
	
	    local function onDescendantAdded(child)
	        local listenerObject = createListener(child);
	
	        if (options.listenToDestroying) then
	            child.Destroying:Connect(function()
	                local removeListener = typeof(listener) == 'table' and (listener.Destroy or listener.Remove) or listenerObject;
	
	                if (typeof(removeListener) ~= 'function') then
	                    warn('[Utility] removeListener is not definded possible memory leak for', folder);
	                else
	                    removeListener(child);
	                end;
	            end);
	        end;
	    end
	
	    debug.profilebegin(string.format('Utility.listenToDescendantAdded(%s)', folder:GetFullName()));
	
	    for _, child in next, folder:GetDescendants() do
	        task.spawn(onDescendantAdded, child);
	    end;
	
	    debug.profileend();
	
	    return folder.DescendantAdded:Connect(onDescendantAdded);
	end;
	
	function Utility.listenToDescendantRemoving(folder, listener)
	    local createListener = typeof(listener) == 'table' and listener.new or listener;
	
	    assert(typeof(folder) == 'Instance', 'listenToDescendantRemoving folder #1 listener has to be an instance');
	    assert(typeof(createListener) == 'function', 'listenToDescendantRemoving #2 listener has to be a function');
	
	    return folder.DescendantRemoving:Connect(createListener);
	end;
	
	function Utility.listenToTagAdded(tagName, listener)
	    for _, v in next, CollectionService:GetTagged(tagName) do
	        task.spawn(listener, v);
	    end;
	
	    return CollectionService:GetInstanceAddedSignal(tagName):Connect(listener);
	end;
	
	function Utility.getFunctionHash(f)
	    if (typeof(f) ~= 'function') then return error('getFunctionHash(f) #1 has to be a function') end;
	
	    local constants = getconstants(f);
	    local protos = getprotos(f);
	
	    local total = HttpService:JSONEncode({constants, protos});
	
	    return crypt.hash(total);
	end;
	
	local function onPlayerRemoving(player)
	    playersData[player] = nil;
	end;
	
	for _, player in next, Players:GetPlayers() do
	    task.spawn(onPlayerAdded, player);
	end;
	
	Players.PlayerAdded:Connect(onPlayerAdded);
	Players.PlayerRemoving:Connect(onPlayerRemoving);
	
	function Utility.find(t, c)
	    for i, v in next, t do
	        if (c(v, i)) then
	            return v, i;
	        end;
	    end;
	
	    return nil;
	end;
	
	function Utility.map(t, c)
	    local ret = {};
	
	    for i, v in next, t do
	        local val = c(v, i);
	        if (val) then
	            table.insert(ret, val);
	        end;
	    end;
	
	    return ret;
	end;
	
	return Utility;
end)();

sharedRequires['6037201603f3197c312ecccbded8cdd18de7f32b2f881a4231fdf106ef3fc7eb'] = (function()
	
	
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	
	local RunService, UserInputService, HttpService = Services:Get('RunService', 'UserInputService', 'HttpService');
	
	local EntityESP = {};
	
	local worldToViewportPoint = clonefunction(Instance.new('Camera').WorldToViewportPoint);
	local vectorToWorldSpace = CFrame.new().VectorToWorldSpace;
	local getMouseLocation = clonefunction(UserInputService.GetMouseLocation);
	
	local id = HttpService:GenerateGUID(false);
	local userId = "1234"
	
	local lerp = Color3.new().lerp;
	local flags = library.flags;
	
	local vector3New = Vector3.new;
	local Vector2New = Vector2.new;
	
	local mathFloor = math.floor;
	
	local mathRad = math.rad;
	local mathCos = math.cos;
	local mathSin = math.sin;
	local mathAtan2 = math.atan2;
	
	local showTeam;
	local allyColor;
	local enemyColor;
	local maxEspDistance;
	local toggleBoxes;
	local toggleTracers;
	local unlockTracers;
	local showHealthBar;
	local proximityArrows;
	local maxProximityArrowDistance;
	
	local scalarPointAX, scalarPointAY;
	local scalarPointBX, scalarPointBY;
	
	local labelOffset, tracerOffset;
	local boxOffsetTopRight, boxOffsetBottomLeft;
	
	local healthBarOffsetTopRight, healthBarOffsetBottomLeft;
	local healthBarValueOffsetTopRight, healthBarValueOffsetBottomLeft;
	
	local realGetRPProperty;
	
	local setRP;
	local getRPProperty;
	local destroyRP;
	
	local scalarSize = 20;
	
	local ESP_RED_COLOR, ESP_GREEN_COLOR = Color3.fromRGB(192, 57, 43), Color3.fromRGB(39, 174, 96)
	local TRIANGLE_ANGLE = mathRad(45);
	
	do --// Entity ESP
	    EntityESP = {};
	    EntityESP.__index = EntityESP;
	    EntityESP.__ClassName = 'entityESP';
	
	    EntityESP.id = 0;
	
	    local emptyTable = {};
	
	    function EntityESP.new(player)
	        EntityESP.id += 1;
	
	        local self = setmetatable({}, EntityESP);
	
	        self._id = EntityESP.id;
	        self._player = player;
	        self._playerName = player.Name;
	
	        self._triangle = Drawing.new('Triangle');
	        self._triangle.Visible = true;
	        self._triangle.Thickness = 0;
	        self._triangle.Color = Color3.fromRGB(255, 255, 255);
	        self._triangle.Filled = true;
	
	        self._label = Drawing.new('Text');
	        self._label.Visible = false;
	        self._label.Center = true;
	        self._label.Outline = true;
	        self._label.Text = '';
	        self._label.Font = Drawing.Fonts[library.flags.espFont];
	        self._label.Size = library.flags.textSize;
	        self._label.Color = Color3.fromRGB(255, 255, 255);
	
	        self._box = Drawing.new('Quad');
	        self._box.Visible = false;
	        self._box.Thickness = 1;
	        self._box.Filled = false;
	        self._box.Color = Color3.fromRGB(255, 255, 255);
	
	        self._healthBar = Drawing.new('Quad');
	        self._healthBar.Visible = false;
	        self._healthBar.Thickness = 1;
	        self._healthBar.Filled = false;
	        self._healthBar.Color = Color3.fromRGB(255, 255, 255);
	
	        self._healthBarValue = Drawing.new('Quad');
	        self._healthBarValue.Visible = false;
	        self._healthBarValue.Thickness = 1;
	        self._healthBarValue.Filled = true;
	        self._healthBarValue.Color = Color3.fromRGB(0, 255, 0);
	
	        self._line = Drawing.new('Line');
	        self._line.Visible = false;
	        self._line.Color = Color3.fromRGB(255, 255, 255);
	
	        for i, v in next, self do
	            if (typeof(v) == 'table' and rawget(v, '__OBJECT')) then
	                rawset(v, '_cache', {});
	            end;
	        end;
	
	        self._labelObject = isSynapseV3 and self._label or self._label.__OBJECT;
	
	        return self;
	    end;
	
	    function EntityESP:Plugin()
	        return emptyTable;
	    end;
	
	    function EntityESP:ConvertVector(...)
	        -- if(flags.twoDimensionsESP) then
	            -- return vector3New(...));
	        -- else
	            return vectorToWorldSpace(self._cameraCFrame, vector3New(...));
	        -- end;
	    end;
	
	    function EntityESP:GetOffsetTrianglePosition(closestPoint, radiusOfDegree)
	        local cosOfRadius, sinOfRadius = mathCos(radiusOfDegree), mathSin(radiusOfDegree);
	        local closestPointX, closestPointY = closestPoint.X, closestPoint.Y;
	
	        local sameBCCos = (closestPointX + scalarPointBX * cosOfRadius);
	        local sameBCSin = (closestPointY + scalarPointBX * sinOfRadius);
	
	        local sameACSin = (scalarPointAY * sinOfRadius);
	        local sameACCos = (scalarPointAY * cosOfRadius)
	
	        local pointX1 = (closestPointX + scalarPointAX * cosOfRadius) - sameACSin;
	        local pointY1 = closestPointY + (scalarPointAX * sinOfRadius) + sameACCos;
	
	        local pointX2 = sameBCCos - (scalarPointBY * sinOfRadius);
	        local pointY2 = sameBCSin + (scalarPointBY * cosOfRadius);
	
	        local pointX3 = sameBCCos - sameACSin;
	        local pointY3 = sameBCSin + sameACCos;
	
	        return Vector2New(mathFloor(pointX1), mathFloor(pointY1)), Vector2New(mathFloor(pointX2), mathFloor(pointY2)), Vector2New(mathFloor(pointX3), mathFloor(pointY3));
	    end;
	
	    function EntityESP:Update(t)
	        local camera = self._camera;
	        if(not camera) then return self:Hide() end;
	
	        local character, maxHealth, floatHealth, health, rootPart = Utility:getCharacter(self._player);
	        if(not character) then return self:Hide() end;
	
	        rootPart = rootPart or Utility:getRootPart(self._player);
	        if(not rootPart) then return self:Hide() end;
	
	        local rootPartPosition = rootPart.Position;
	
	        local labelPos, visibleOnScreen = worldToViewportPoint(camera, rootPartPosition + labelOffset);
	        local triangle = self._triangle;
	
	        local isTeamMate = Utility:isTeamMate(self._player);
	        if(isTeamMate and not showTeam) then return self:Hide() end;
	
	        local distance = (rootPartPosition - self._cameraPosition).Magnitude;
	        if(distance > maxEspDistance) then return self:Hide() end;
	
	        local espColor = isTeamMate and allyColor or enemyColor;
	        local canView = false;
	
	        if (proximityArrows and not visibleOnScreen and distance < maxProximityArrowDistance) then
	            local vectorUnit;
	
	            if (labelPos.Z < 0) then
	                vectorUnit = -(Vector2.new(labelPos.X, labelPos.Y) - self._viewportSizeCenter).Unit; --PlayerPos-Center.Unit
	            else
	                vectorUnit = (Vector2.new(labelPos.X, labelPos.Y) - self._viewportSizeCenter).Unit; --PlayerPos-Center.Unit
	            end;
	
	            local degreeOfCorner = -mathAtan2(vectorUnit.X, vectorUnit.Y) - TRIANGLE_ANGLE;
	            local closestPointToPlayer = self._viewportSizeCenter + vectorUnit * scalarSize --screenCenter+unit*scalar (Vector 2)
	
	            local pointA, pointB, pointC = self:GetOffsetTrianglePosition(closestPointToPlayer, degreeOfCorner);
	
	            setRP(triangle, 'PointA', pointA);
	            setRP(triangle, 'PointB', pointB);
	            setRP(triangle, 'PointC', pointC);
	
	            setRP(triangle, 'Color', espColor);
	            canView = true;
	        end;
	
	        setRP(triangle, 'Visible', canView);
	        if (not visibleOnScreen) then return self:Hide(true) end;
	
	        self._visible = visibleOnScreen;
	
	        local label, box, line, healthBar, healthBarValue = self._label, self._box, self._line, self._healthBar, self._healthBarValue;
	        local pluginData = self:Plugin();
	
	        local text = '[' .. (pluginData.playerName or self._playerName) .. '] [' .. mathFloor(distance) .. ']\n[' .. mathFloor(health) .. '/' .. mathFloor(maxHealth) .. '] [' .. mathFloor(floatHealth) .. ' %]' .. (pluginData.text or '') .. ' [' .. userId .. ']';
	
	        setRP(label, 'Visible', visibleOnScreen);
	        setRP(label, 'Position', Vector2New(labelPos.X, labelPos.Y - realGetRPProperty(self._labelObject, 'TextBounds').Y));
	        setRP(label, 'Text', text);
	        setRP(label, 'Color', espColor);
	
	        if(toggleBoxes) then
	            local boxTopRight = worldToViewportPoint(camera, rootPartPosition + boxOffsetTopRight);
	            local boxBottomLeft = worldToViewportPoint(camera, rootPartPosition + boxOffsetBottomLeft);
	
	            local topRightX, topRightY = boxTopRight.X, boxTopRight.Y;
	            local bottomLeftX, bottomLeftY = boxBottomLeft.X, boxBottomLeft.Y;
	
	            setRP(box, 'Visible', visibleOnScreen);
	
	            setRP(box, 'PointA', Vector2New(topRightX, topRightY));
	            setRP(box, 'PointB', Vector2New(bottomLeftX, topRightY));
	            setRP(box, 'PointC', Vector2New(bottomLeftX, bottomLeftY));
	            setRP(box, 'PointD', Vector2New(topRightX, bottomLeftY));
	            setRP(box, 'Color', espColor);
	        else
	            setRP(box, 'Visible', false);
	        end;
	
	        if(toggleTracers) then
	            local linePosition = worldToViewportPoint(camera, rootPartPosition + tracerOffset);
	
	            setRP(line, 'Visible', visibleOnScreen);
	
	            setRP(line, 'From', unlockTracers and getMouseLocation(UserInputService) or self._viewportSize);
	            setRP(line, 'To', Vector2New(linePosition.X, linePosition.Y));
	            setRP(line, 'Color', espColor);
	        else
	            setRP(line, 'Visible', false);
	        end;
	
	        if(showHealthBar) then
	            local healthBarValueHealth = (1 - (floatHealth / 100)) * 7.4;
	
	            local healthBarTopRight = worldToViewportPoint(camera, rootPartPosition + healthBarOffsetTopRight);
	            local healthBarBottomLeft = worldToViewportPoint(camera, rootPartPosition + healthBarOffsetBottomLeft);
	
	            local healthBarTopRightX, healthBarTopRightY = healthBarTopRight.X, healthBarTopRight.Y;
	            local healthBarBottomLeftX, healthBarBottomLeftY = healthBarBottomLeft.X, healthBarBottomLeft.Y;
	
	            local healthBarValueTopRight = worldToViewportPoint(camera, rootPartPosition + healthBarValueOffsetTopRight - self:ConvertVector(0, healthBarValueHealth, 0));
	            local healthBarValueBottomLeft = worldToViewportPoint(camera, rootPartPosition - healthBarValueOffsetBottomLeft);
	
	            local healthBarValueTopRightX, healthBarValueTopRightY = healthBarValueTopRight.X, healthBarValueTopRight.Y;
	            local healthBarValueBottomLeftX, healthBarValueBottomLeftY = healthBarValueBottomLeft.X, healthBarValueBottomLeft.Y;
	
	            setRP(healthBar, 'Visible', visibleOnScreen);
	            setRP(healthBar, 'Color', espColor);
	
	            setRP(healthBar, 'PointA', Vector2New(healthBarTopRightX, healthBarTopRightY));
	            setRP(healthBar, 'PointB', Vector2New(healthBarBottomLeftX, healthBarTopRightY));
	            setRP(healthBar, 'PointC', Vector2New(healthBarBottomLeftX, healthBarBottomLeftY));
	            setRP(healthBar, 'PointD', Vector2New(healthBarTopRightX, healthBarBottomLeftY));
	
	            setRP(healthBarValue, 'Visible', visibleOnScreen);
	            setRP(healthBarValue, 'Color', lerp(ESP_RED_COLOR, ESP_GREEN_COLOR, floatHealth / 100));
	
	            setRP(healthBarValue, 'PointA', Vector2New(healthBarValueTopRightX, healthBarValueTopRightY));
	            setRP(healthBarValue, 'PointB', Vector2New(healthBarValueBottomLeftX, healthBarValueTopRightY));
	            setRP(healthBarValue, 'PointC', Vector2New(healthBarValueBottomLeftX, healthBarValueBottomLeftY));
	            setRP(healthBarValue, 'PointD', Vector2New(healthBarValueTopRightX, healthBarValueBottomLeftY));
	        else
	            setRP(healthBar, 'Visible', false);
	            setRP(healthBarValue, 'Visible', false);
	        end;
	    end;
	
	    function EntityESP:Destroy()
	        if (not self._label) then return end;
	
	        --destroyRP(self._label);
	        self._label = nil;
	
	        --destroyRP(self._box);
	        self._box = nil;
	
	        --destroyRP(self._line);
	        self._line = nil;
	
	       -- destroyRP(self._healthBar);
	        self._healthBar = nil;
	
	        --destroyRP(self._healthBarValue);
	        self._healthBarValue = nil;
	
	       -- destroyRP(self._triangle);
	        self._triangle = nil;
	    end;
	

	    function EntityESP:Hide(bypassTriangle)
	        if (not bypassTriangle) then
	            setRP(self._triangle, 'Visible', false);
	        end;
	
	        if (not self._visible) then return end;
	        self._visible = false;
	
	        setRP(self._label, 'Visible', false);
	        setRP(self._box, 'Visible', false);
	        setRP(self._line, 'Visible', false);
	
	        setRP(self._healthBar, 'Visible', false);
	        setRP(self._healthBarValue, 'Visible', false);
	    end;
	
	    function EntityESP:SetFont(font)
	        setRP(self._label, 'Font', font);
	    end;
	
	    function EntityESP:SetTextSize(textSize)
	        --setRP(self._label, 'Size', textSize);
	    end;
	
	    local function updateESP()
	        local camera = workspace.CurrentCamera;
	        EntityESP._camera = camera;
	        if (not camera) then return end;
	
	        EntityESP._cameraCFrame = EntityESP._camera.CFrame;
	        EntityESP._cameraPosition = EntityESP._cameraCFrame.Position;
	
	        local viewportSize = camera.ViewportSize;
	
	        EntityESP._viewportSize = Vector2New(viewportSize.X / 2, viewportSize.Y - 10);
	        EntityESP._viewportSizeCenter = viewportSize / 2;
	
	        showTeam = flags.showTeam;
	        allyColor = flags.allyColor;
	        enemyColor = flags.enemyColor;
	        maxEspDistance = flags.maxEspDistance;
	        toggleBoxes = flags.toggleBoxes;
	        toggleTracers = flags.toggleTracers;
	        unlockTracers = flags.unlockTracers;
	        showHealthBar = flags.showHealthBar;
	        maxProximityArrowDistance = flags.maxProximityArrowDistance;
	        proximityArrows = flags.proximityArrows;
	
	        scalarSize = library.flags.proximityArrowsSize or 20;
	
	        scalarPointAX, scalarPointAY = scalarSize, scalarSize;
	        scalarPointBX, scalarPointBY = -scalarSize, -scalarSize;
	
	        labelOffset = EntityESP:ConvertVector(0, 3.25, 0);
	        tracerOffset = EntityESP:ConvertVector(0, -4.5, 0);
	
	        boxOffsetTopRight = EntityESP:ConvertVector(2.5, 3, 0);
	        boxOffsetBottomLeft = EntityESP:ConvertVector(-2.5, -4.5, 0);
	
	        healthBarOffsetTopRight = EntityESP:ConvertVector(-3, 3, 0);
	        healthBarOffsetBottomLeft = EntityESP:ConvertVector(-3.5, -4.5, 0);
	
	        healthBarValueOffsetTopRight = EntityESP:ConvertVector(-3.05, 2.95, 0);
	        healthBarValueOffsetBottomLeft = EntityESP:ConvertVector(3.45, 4.45, 0);
	    end;
	
	    updateESP();
	    RunService:BindToRenderStep(id, Enum.RenderPriority.Camera.Value, updateESP);
	end;
	
	return EntityESP;
end)();

sharedRequires['9504c96d496b9bceaf05ec78caa6802370360a6d8d2aa4c967e2b3fad2fe4641'] = (function()
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	
	local RunService = Services:Get('RunService');
	
	local oldVolume = UserSettings().GameSettings.MasterVolume;
	local playingAudios = 0;
	
	UserSettings().GameSettings:GetPropertyChangedSignal('MasterVolume'):Connect(function()
	    local newVolume = UserSettings().GameSettings.MasterVolume;
	
	    if (playingAudios <= 0) then
	        oldVolume = newVolume;
	    end;
	end);
	
	local AudioPlayer = {};
	AudioPlayer.__index = AudioPlayer;
	
	local audioFolder = Instance.new('Folder');
	
	if (not gethui) then
	    --syn.protect_gui(audioFolder);
	end;
	
	audioFolder.Parent = gethui and gethui() or Services:Get('CoreGui');
	if (not isfolder('Aztup Hub V3/sounds')) then
	    makefolder('Aztup Hub V3/sounds');
	end;
	
	function AudioPlayer.new(options)
	    local self = setmetatable({}, AudioPlayer);
	
	    options = options or {};
	    options.forcedAudio = options.forcedAudio;
	
	    self._options = options;
	
	    self._sound = Instance.new('Sound');
	    self._sound.Volume = options.volume or 1;
	    self._sound.Looped = options.looped or false;
	
	    self._sound.Parent = audioFolder;
	
	    self._maid = Maid.new();
	
	    if (options.soundId) then
	        self._sound.SoundId = options.soundId;
	    elseif (options.url) then
	        local fileName = crypt.hash(options.url) .. '.bin';
	        local filePath = string.format('Aztup Hub V3/sounds/%s', fileName);
	
	        if (not isfile(filePath)) then 
	            local success, data = pcall(request, {Url = options.url});
	            if (success) then
	                --writefile(filePath, data.Body);
	            end;
	        end;
	
	        --self._sound.SoundId = getsynasset(filePath);
	    end;
	
	    if (options.autoPlay) then
	        self:Play();
	    end;
	
	    self._maid:GiveTask(self._sound.Ended:Connect(function()
	        playingAudios -= 1;
	        self._maid.loop = nil;
	        if (not self._options.forcedAudio) then return end;
	        UserSettings().GameSettings.MasterVolume = oldVolume;
	    end));
	
	    return self;
	end;
	
	function AudioPlayer:GetSound()
	    return self._sound;
	end;
	
	function AudioPlayer:Play()
	    playingAudios += 1;
	
	    if (self._options.forcedAudio) then
	        self._maid.loop = RunService.Heartbeat:Connect(function()
	            UserSettings().GameSettings.MasterVolume = 10;
	        end);
	    end;
	
	    self._sound:Play();
	end;
	
	function AudioPlayer:Stop()
	    playingAudios -= 1;
	
	    self._maid.loop = nil;
	    UserSettings().GameSettings.MasterVolume = oldVolume;
	
	    self._sound:Stop();
	end;
	
	return AudioPlayer;
end)();

sharedRequires['a3e29534c54ea992e4901bd5905bcd2eaf0da968e55f3206813e3acc65092050'] = (function()
	return [[{"88070565":"Bloxburg","111958650":"Arsenal","113491250":"Phantom Forces","170247232":"Parkour","212154879":"Sword Burst 2","245662005":"Jailbreak","254394801":"KAT","299659045":"Phantom Forces","301252049":"RoBeats","358276974":"Apocalypse Rising 2","380704901":"Ro Ghoul","383310974":"Adopt Me","648454481":"Grand Piece Online","807930589":"Wild West","913400159":"Ace Of Spadez","1087859240":"Rogue Lineage","1168263273":"Bad Business","1180269832":"Arcane Odyssey","1359573625":"DeepWoken","1390601379":"Combat Warriors","1625049715":"AdventureTales","1643537246":"RoBeats CS","1663370770":"Mighty Omega","1946714362":"Bloodlines","2142948266":"Shitty Slayer","3291589472":"Voxl Blade","3525075510":"Project Mugetsu"}]]
end)();

sharedRequires['055b759436afbb00dff7f3d6892eda9b8ef9b685f5abb07e1ecf6fca60f206b9'] = (function()
	return [[
	    local Players = game:GetService('Players');
	    local RunService = game:GetService('RunService');
	    local LocalPlayer = Players.LocalPlayer;
	
	    local camera, rootPart, rootPartPosition;
	
	    local originalCommEvent = ...;
	    local commEvent;
	
	    if (typeof(originalCommEvent) == 'table') then
	        commEvent = {
	            _event = originalCommEvent._event,
	
	            Connect = function(self, f)
	                return self._event.Event:Connect(f)
	            end,
	
	            Fire = function(self, ...)
	                self._event:Fire(...);
	            end
	        };
	    else
	        commEvent = getgenv().syn.get_comm_channel(originalCommEvent);
	    end;
	
	    local flags = {};
	
	    local updateTypes = {};
	
	    local BaseESPParallel = {};
	    BaseESPParallel.__index = BaseESPParallel;
	
	    local container = {};
	    local DEFAULT_ESP_COLOR = Color3.fromRGB(255, 255, 255);
	
	    local mFloor = math.floor;
	    local isSynapseV3 = not not gethui;
	
	    local worldToViewportPoint = Instance.new('Camera').WorldToViewportPoint;
	    local vector2New = Vector2.new;
	
	    local realSetRP;
	    local realDestroyRP;
	    local realGetRPProperty;
	
	
	
	    local updateDrawingQueue = {};
	    local destroyDrawingQueue = {};
	
	    local activeContainer = {};
	    local customInstanceCache = {};
	
	    local gameName;
	    local enableESPSearch = false;
	
	    local sLower = string.lower;
	    local sFind = string.find;
	
	    local findFirstChild = clonefunction(game.FindFirstChild);
	    local getAttribute = clonefunction(game.GetAttribute);

	    function BaseESPParallel.new(data, showESPFlag, customInstance)
	        local self = setmetatable(data, BaseESPParallel);
	
	        if (customInstance) then
	            if (not customInstanceCache[data._code]) then
	                local func = loadstring(data._code);
	                getfenv(func).library = setmetatable({}, {__index = function(self, p) return flags end});
	
	                customInstanceCache[data._code] = func;
	            end;
	            self._instance = customInstanceCache[data._code](unpack(data._vars));
	        end;
	
	        local instance, tag, color, isLazy = self._instance, self._tag, self._color, self._isLazy;
	        self._showFlag2 = showESPFlag;
	
	
			if (isSynapseV3 and typeof(instance) == 'Instance' and false) then
				-- if (typeof(instance) == 'table') then
				-- 	task.spawn(error, instance);
				-- end;
	
				self._label = TextDynamic.new(PointInstance.new(instance));
				self._label.Color = DEFAULT_ESP_COLOR;
				self._label.XAlignment = XAlignment.Center;
				self._label.YAlignment = YAlignment.Center;
				self._label.Outlined = true;
				self._label.Text = string.format('[%s]', tag);
			else
				self._label = Drawing.new('Text');
				self._label.Transparency = 1;
				self._label.Color = color;
				self._label.Text = '[' .. tag .. ']';
				self._label.Center = true;
				self._label.Outline = true;
			end;
	
			local flagValue = flags[self._showFlag];
			-- self._object = isSynapseV3 and self._label or self._label.__OBJECT;
	
			for i, v in next, self do
	            if (typeof(v) == 'table' and rawget(v, '__OBJECT')) then
	                rawset(v, '_cache', {});
	            end;
	        end;
	
			container[self._id] = self;
	
			if (isLazy) then
				self._instancePosition = instance.Position;
			end;
	
	        self:UpdateContainer();
	        return self;
	    end;
	
		function BaseESPParallel:Destroy()
			container[self._id] = nil;
	        if (table.find(activeContainer, self)) then
	            table.remove(activeContainer, table.find(activeContainer, self));
	        end;
	        table.insert(destroyDrawingQueue, self._label);
	    end;
	
	    function BaseESPParallel:Unload()
	        table.insert(updateDrawingQueue, {
	            label = self._label,
	            visible = false
	        });
	    end;
	
		function BaseESPParallel:BaseUpdate(espSearch)
			local instancePosition = self._instancePosition or self._instance.Position;
			if (not instancePosition) then return self:Unload() end;
	
			local distance = (rootPartPosition - instancePosition).Magnitude;
			local maxDist = flags[self._maxDistanceFlag] or 10000;
			if(distance >= maxDist and maxDist ~= 10000) then return self:Unload(); end;
	
			local visibleState = flags[self._showFlag];
			local label, text = self._label, self._text;
	
			if(visibleState == nil) then
				visibleState = true;
			elseif (not visibleState) then
				return self:Unload();
			end;
	
			-- if (isSynapseV3) then return end;
	
			local position, visible = worldToViewportPoint(camera, instancePosition);
			if(not visible) then return self:Unload(); end;
	
			local newPos = vector2New(position.X, position.Y);
	
			local labelText = '';
	
			if (flags[self._showHealthFlag]) then
	            -- Custom instance do not touch they have custom funcs
	            local humanoid = self._instance:FindFirstChildWhichIsA('Humanoid') or self._instance.Parent and self._instance.Parent:FindFirstChild('Humanoid');
	
	            if (not humanoid) then
	                if (gameName == 'Arcane Odyssey') then
	                    local attributes = findFirstChild(self._instance.Parent, 'Attributes');
	                    if (attributes) then
	                        humanoid = {
	                            Health = attributes.Health.Value,
	                            MaxHealth = attributes.MaxHealth.Value,
	                        }
	                    end
	                elseif (gameName == 'Voxl Blade') then
	                    humanoid = {
	                        Health = getAttribute(self._instance, 'HP'),
	                        MaxHealth = getAttribute(self._instance, 'MAXHP'),
	                    }
	                end;
	            end;
	
				if (humanoid) then
					local health = mFloor(humanoid.Health);
					local maxHealth = mFloor(humanoid.MaxHealth);
	
					labelText = labelText .. '[' .. health .. '/' .. maxHealth ..']';
				end;
			end;
	
			labelText = labelText .. '[' .. text .. ']';
	
	        local visible = true;
	
	        if (enableESPSearch and espSearch and not sFind(sLower(labelText), espSearch)) then
	            visible = false;
	        end;
	
			local newColor = flags[self._colorFlag] or flags[self._colorFlag2] or DEFAULT_ESP_COLOR;
	
			if (flags[self._showDistanceFlag]) then
				labelText = labelText .. ' [' .. mFloor(distance) .. ']';
			end;
	
	        table.insert(updateDrawingQueue, {
	            position = newPos,
	            color = newColor,
	            text = labelText,
	            label = label,
	            visible = visible
	        });
		end;
	
	    function BaseESPParallel:UpdateContainer()
	        local showFlag, showFlag2 = self._showFlag, self._showFlag2;
	
	        if (flags[showFlag] == false or not flags[showFlag2]) then
	            local exists = table.find(activeContainer, self);
	            if (exists) then table.remove(activeContainer, exists); end;
	            self:Unload();
	        elseif (not table.find(activeContainer, self)) then
	            table.insert(activeContainer, self);
	        end;
	    end;
	
	    function updateTypes.new(data)
	        local showESPFlag = data.showFlag;
	        local isCustomInstance = data.isCustomInstance;
	        data = data.data;
	
	        BaseESPParallel.new(data, showESPFlag, isCustomInstance);
	    end;
	
	    function updateTypes.destroy(data)
	        task.desynchronize();
	        local id = data.id;
	
	        for _, v in next, container do
	            if (v._id == id) then
	                v:Destroy();
	            end;
	        end;
	    end;
	
	    local event;
	    local flagChanged;
	
	    local containerUpdated = false;
	
	    function updateTypes.giveEvent(data)
	        event = data.event;
	        gameName = data.gameName;
	
	        enableESPSearch = gameName == 'Voxl Blade' or gameName == 'DeepWoken' or gameName == 'Rogue Lineage';
	
	        event.Event:Connect(function(data)
	            if (data.type == 'color') then
	                flags[data.flag] = data.color;
	            elseif (data.type == 'slider') then
	                flags[data.flag] = data.value;
	            elseif (data.type == 'toggle') then
	                flags[data.flag] = data.state;
	            elseif (data.type == 'box') then
	                flags[data.flag] = data.value;
	            end;
	    
	            if (data.type ~= 'toggle' or containerUpdated) then return end;
	            containerUpdated = true;
	    
	            task.defer(function()
	                debug.profilebegin('containerUpdates');
	                for _, v in next, container do
	                    v:UpdateContainer();
	                end;
	                debug.profileend();
	    
	                containerUpdated = false;
	            end);
	        end);
	    end;
	
	    commEvent:Connect(function(data)
	        local f = updateTypes[data.updateType];
	        if (not f) then return end;
	        f(data);
	    end);
	
	    commEvent:Fire({updateType = 'ready'});
	
	    RunService.Heartbeat:Connect(function(deltaTime)
	        task.desynchronize();
	
	        camera = workspace.CurrentCamera;
	        rootPart = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart;
	        rootPartPosition = rootPart and rootPart.Position;
	
			if(not camera or not rootPart) then return; end;
	
	        local espSearch = enableESPSearch and flags.espSearch;
	
	        if (espSearch and espSearch ~= '') then
	            espSearch = sLower(espSearch);
	        end;
	
	        for i = 1, #activeContainer do
	            activeContainer[i]:BaseUpdate(espSearch);
	        end;
	
	        local goSerial = #updateDrawingQueue ~= 0 or #destroyDrawingQueue ~= 0;
	        if (goSerial) then task.synchronize(); end;
	        debug.profilebegin('updateDrawingQueue');
	
	        for i = 1, #updateDrawingQueue do
	            local v = updateDrawingQueue[i];
	            local label, position, visible, color, text = v.label, v.position, v.visible, v.color, v.text;
	
	            if (isSynapseV3) then
	                if (position) then
	                    label.Position = position;
	                end;
	    
	                if (visible ~= nil) then
	                    label.Visible = visible;
	                end;
	    
	                if (color) then
	                    label.Color = color;
	                end;
	    
	                if (text) then
	                    label.Text = text;
	                end;
	            else                
	                if (position) then
	                    setRP(label, 'Position', position);
	                end;
	    
	                if (visible ~= nil) then
	                    setRP(label, 'Visible', visible);
	                end;
	    
	                if (color) then
	                    setRP(label, 'Color', color);
	                end;
	    
	                if (text) then
	                    setRP(label, 'Text', text);
	                end;
	            end;
	        end;
	
	        debug.profileend();
	        debug.profilebegin('destroyDrawingQueue');
	
	        for i = 1, #destroyDrawingQueue do
	            destroyDrawingQueue[i]:Remove();
	        end;
	
	        debug.profileend();
	        debug.profilebegin('table clear');
	
	        updateDrawingQueue = {};
	        destroyDrawingQueue = {};
	
	        debug.profileend();
	    end);
	]];
end)();

sharedRequires['f3d8f3d0569e6d29485406017419e8d35feb6914555d4054e0c78fadf56bd350'] = (function()
	
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	
	local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	
	local Players, CorePackages, HttpService = Services:Get('Players', 'CorePackages', 'HttpService');
	local LocalPlayer = Players.LocalPlayer;
	
	local NUM_ACTORS = 8;
	
	--[[
		We'll add an example cuz I have no brain
	
		local chestsESP = createBaseESP('chests'); -- This is the base ESP it returns a class with .new, .Destroy, :UpdateAll, :UnloadAll, and some other stuff
	
		-- Listen to chests childAdded through Utility.listenToChildAdded and then create an espObject for that chest
		-- chestsESP.new only accepts BasePart or CFrame
		-- It has a lazy parameter allowing it to not update the get the position everyframe only get the screen position
		-- Also a color parameter
	
		Utility.listenToChildAdded(workspace.Chests, function(obj)
			local espObject = chestsESP.new(obj, 'Normal Chest', color, isLazy);
	
			obj.Destroying:Connect(function()
				espObject:Destroy();
			end);
		end);
	
		local function updateChestESP(toggle)
			if (not toggle) then
				maid.chestESP = nil;
				chestsESP:UnloadAll();
				return;
			end;
	
			maid.chestESP = RunService.Stepped:Connect(function()
				chestsESP:UpdateAll();
			end);
		end;
	
		-- UI Lib functions
		:AddToggle({text = 'Enable', flag = 'chests', callback = updateChestESP});
		:AddToggle({text = 'Show Distance', textpos = 2, flag = 'Chests Show Distance'});
		:AddToggle({text = 'Show Normal Chest'}):AddColor({text = 'Normal Chest Color'}); -- Filer for if you want to see that chest and select the color of it
	]]
	
	local playerScripts = LocalPlayer:WaitForChild('PlayerScripts')
	
	local playerScriptsLoader = playerScripts:FindFirstChild('PlayerScriptsLoader');
	local actors = {};
	
	local readyCount = 0;
	local broadcastEvent = Instance.new('BindableEvent');
	
	local supportedGamesList = HttpService:JSONDecode(sharedRequires['a3e29534c54ea992e4901bd5905bcd2eaf0da968e55f3206813e3acc65092050']);
	local gameName = supportedGamesList[tostring(game.GameId)];
	
	if (not playerScriptsLoader and gameName == 'Apocalypse Rising 2') then
		playerScriptsLoader = playerScripts:FindFirstChild('FreecamDelete');
	end;
	
	local count = 1;
	
	local function createBaseEsp(flag, container)
		container = container or {};
		local BaseEsp = {};
	
		BaseEsp.ClassName = 'BaseEsp';
		BaseEsp.Flag = flag;
		BaseEsp.Container = container;
		BaseEsp.__index = BaseEsp;
	
		local whiteColor = Color3.new(1, 1, 1);
	
		local maxDistanceFlag = BaseEsp.Flag .. 'MaxDistance';
		local showHealthFlag = BaseEsp.Flag .. 'ShowHealth';
		local showESPFlag = BaseEsp.Flag;
	
		function BaseEsp.new(instance, tag, color, isLazy)
			assert(instance, '#1 instance expected');
			assert(tag, '#2 tag expected');
	
			local isCustomInstance = false;
	
			if (typeof(instance) == 'table' and rawget(instance, 'code')) then
				isCustomInstance = true;
			end;
	
			color = color or whiteColor;
	
			local self = setmetatable({}, BaseEsp);
			self._tag = tag;
	
			local displayName = tag;
	
			if (typeof(tag) == 'table') then
				displayName = tag.displayName;
				self._tag = tag.tag;
			end;
	
			self._instance = instance;
			self._text = displayName;
			self._color = color;
			self._showFlag = toCamelCase('Show ' .. self._tag);
			self._colorFlag = toCamelCase(self._tag .. ' Color');
			self._colorFlag2 = BaseEsp.Flag .. 'Color';
			self._showDistanceFlag = BaseEsp.Flag .. 'ShowDistance';
			self._isLazy = isLazy;
			self._actor = actors[(count % readyCount) + 1];
			self._id = count;
			self._maid = Maid.new();
	
			count += 1;
	
			if (isLazy and not isCustomInstance) then
				self._instancePosition = instance.Position;
			end;
	
			self._maxDistanceFlag = maxDistanceFlag;
			self._showHealthFlag = showHealthFlag;
	
			if (isCustomInstance) then
				self._isCustomInstance = true;
				self._code = instance.code;
				self._vars = instance.vars;
			end;
	
			local smallData = table.clone(self);
			smallData._actor = nil;
			
	
	
			return self;
		end;
	
		function BaseEsp:Unload() end;
		function BaseEsp:BaseUpdate() end;
		function BaseEsp:UpdateAll() end;
		function BaseEsp:Update() end;
		function BaseEsp:UnloadAll() end;
		function BaseEsp:Disable() end;
	
		function BaseEsp:Destroy()
			self._maid:Destroy();
			
		end;
	
		return BaseEsp;
	end;
	
	library.OnFlagChanged:Connect(function(data)
		broadcastEvent:Fire({
			type = data.type,
			flag = data.flag,
			color = data.color,
			state = data.state,
			value = data.value
		});
	end);
	
	return createBaseEsp;
end)();
--debu123
sharedRequires['f097a02efa5d0d2551acb25d09e0e0368b1698a1e0209de8fa7bbff606ee1273'] = (function()
	local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];
	local createBaseESP = sharedRequires['f3d8f3d0569e6d29485406017419e8d35feb6914555d4054e0c78fadf56bd350'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];
	
	local sectionIndex = 1;
	local addedESPSearch = false;
	local function makeEsp(options)
	    options = options or {};
	
	    local tag = toCamelCase(options.sectionName);
	
	    assert(options.sectionName, 'options.sectionName is required');
	    assert(options.callback, 'options.callback is required');
	    assert(options.args, 'options.args is required');
	    assert(options.type, 'options.type is required');
	
	    sectionIndex = (sectionIndex % 2) + 1;
	
	    local espSections = Utility:getESPSection();
	    local espSection = espSections['column' .. sectionIndex]:AddSection(options.sectionName);
	
	    if (not addedESPSearch) then
	        addedESPSearch = true;
	        espSections.espSettings:AddBox({
	            text = 'ESP Search',
	            skipflag = true,
	            noload = true
	        });
	    end;
	
	    local enableToggle = espSection:AddToggle({
	        text = 'Enable',
	        flag = options.sectionName
	    });
	
	    if (not options.noColorPicker) then
	        enableToggle:AddColor({
	            flag = string.format('%s Color', options.sectionName)
	        });
	    end;
	
	    local showDistance = espSection:AddToggle({
	        text = 'Show Distance',
	        flag = options.sectionName .. ' Show Distance'
	    })
	
	    showDistance:AddSlider({
	        text = 'Max Distance',
	        flag = options.sectionName .. ' Max Distance',
	        min = 100,
	        value = 100000,
	        max = 100000,
	        float = 100,
	        textpos = 2
	    });
	
	    local espConstructor = createBaseESP(tag);
	
	    -- If arg is not a table turn arg into a table
	    options.args = typeof(options.args) == 'table' and options.args or {options.args};
	
	    local descOrChild = options.type == 'childAdded' or options.type == 'descendantAdded';
	    local watcherFunc;
	
	    if (descOrChild) then
	        watcherFunc = Utility[options.type == 'childAdded' and 'listenToChildAdded' or 'listenToDescendantAdded'];
	    elseif (options.type == 'tagAdded') then
	        watcherFunc = Utility.listenToTagAdded;
	    end;
	
	    if (not watcherFunc) then
	        return error(options.tag .. ' is not being watched!');
	    end;
	
	    for _, parent in next, options.args do
	        library.unloadMaid:GiveTask(watcherFunc(parent, function(obj)
	            options.callback(obj, espConstructor);
	        end));
	    end;
	
	    local loadedData = options.onLoaded and options.onLoaded(espSection);
	
	    library.OnLoad:Connect(function()
	        local onStateChanged = enableToggle.onStateChanged;
	
	        onStateChanged:Connect(function(state)
	            showDistance.main.Visible = state;
	        end);
	
	        if (not loadedData) then return; end;
	
	        onStateChanged:Connect(function(state)
	            for _, listItem in next, loadedData.list do
	                listItem.main.Visible = state;
	            end;
	        end);
	    end);
	end;
	
	--[[
	    Example usage:
	
	    local section = makeEsp({
	        sectionName = 'Mobs',
	
	        type = 'childAdded',
	        args = {workspace},
	
	        callback = function(obj, esp)
	            esp.new(obj, obj:GetAttribute('MobName') or mob.Name, nil, true); -- Simple args from createBaseESP
	        end,
	
	        onLoaded = function(section)
	            section:AddToggle({
	                text = 'Show Health'
	            });
	
	            -- You can also return a list for esp that require toggle for each obj
	            return {
	                list = arrayOfToggles
	            };
	        end
	    });
	]]
	
	-- This is required cause we want the script to finish loading before we setup esp
	return function (options)
	    task.spawn(makeEsp, options);
	end;
	
end)();

sharedRequires['793f930ecb181c0adaed99b639258b9f609c01a7c4fec27d268ac7a909248f6d'] = (function()
	local HttpService = game:GetService('HttpService');
	
	local Analytics = {}
	Analytics.__index = Analytics;
	
	do
	    function Analytics.new(id)
	        local self = setmetatable({}, Analytics);
	
	        self._id = id;
	
	        return self;
	    end;
	
	    function Analytics:Report(Category, Action, Value)
	        local Label = string.format('AH:%s', "lol");
			--[[
	        task.spawn(syn.request, {
	            Url = 'http://www.google-analytics.com/collect',
	            Method = 'POST',
	            Body = string.format('v=1&t=event&sc=start&tid=%s&cid=%s&ec=%s&ea=%s&el=%s&ev=%s', self._id, accountData.uuid, HttpService:UrlEncode(Category), HttpService:UrlEncode(Action), HttpService:UrlEncode(Label), HttpService:UrlEncode(Value)),
	            Headers = {
	                ['Content-Type'] = 'application/x-www-form-urlencoded'
	            }
	        })]]
	    end;
	end;
	
	return Analytics;
end)();

sharedRequires['a5aab7a81f59849e7c2e50d0ecd43092d80b0aaa025889a2d0219df4023d863d'] = (function()
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local ContextActionService, HttpService = Services:Get('ContextActionService', 'HttpService');
	
	local ControlModule = {};
	
	do
	    ControlModule.__index = ControlModule
	
	    function ControlModule.new()
	        local self = {
	            forwardValue = 0,
	            backwardValue = 0,
	            leftValue = 0,
	            rightValue = 0
	        }
	
	        setmetatable(self, ControlModule)
	        self:init()
	        return self
	    end
	
	    function ControlModule:init()
	        local handleMoveForward = function(actionName, inputState, inputObject)
	            self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveBackward = function(actionName, inputState, inputObject)
	            self.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveLeft = function(actionName, inputState, inputObject)
	            self.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveRight = function(actionName, inputState, inputObject)
	            self.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveForward, false, Enum.KeyCode.W);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveBackward, false, Enum.KeyCode.S);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveLeft, false, Enum.KeyCode.A);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveRight, false, Enum.KeyCode.D);
	    end
	
	    function ControlModule:GetMoveVector()
	        return Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
	    end
	end
	
	return ControlModule.new();
end)();

sharedRequires['7c9714eaa13891b0bf7915d3b5cda22448de203a05b2dee268b670959ff8efe1'] = (function()
	-- DOCUMENTATION: https://ic3w0lf22.gitbook.io/roblox-account-manager/
	
	local Account = {} Account.__index = Account
	
	local WebserverSettings = {
	    Port = '7963',
	    Password = ''
	}
	
	function WebserverSettings:SetPort(Port) self.Port = Port end
	function WebserverSettings:SetPassword(Password) self.Password = Password end
	
	local HttpService = game:GetService'HttpService'
	local Request = request;
	
	local function GET(Method, Account, ...)
	    local Arguments = {...}
	    local Url = 'http://localhost:' .. WebserverSettings.Port .. '/' .. Method .. '?Account=' .. Account
	
	    for Index, Parameter in pairs(Arguments) do
	        Url = Url .. '&' .. Parameter
	    end
	
	    if WebserverSettings.Password and #WebserverSettings.Password >= 6 then
	        Url = Url .. '&Password=' .. WebserverSettings.Password
	    end
	    
	    local Response = Request {
	        Method = 'GET',
	        Url = Url
	    }
	
	    if Response.StatusCode ~= 200 then return false end
	
	    return Response.Body
	end
	
	local function POST(Method, Account, Body, ...)
	    local Arguments = {...}
	    local Url = 'http://localhost:' .. WebserverSettings.Port .. '/' .. Method .. '?Account=' .. Account
	
	    for Index, Parameter in pairs(Arguments) do
	        Url = '&' .. Url .. Parameter
	    end
	
	    if WebserverSettings.Password and #WebserverSettings.Password >= 6 then
	        Url = Url .. '&Password=' .. WebserverSettings.Password
	    end
	    
	    local Response = Request {
	        Method = 'POST',
	        Url = Url,
	        Body = Body
	    }
	
	    if Response.StatusCode ~= 200 then return false end
	
	    return Response.Body
	end
	
	function Account.new(Username, SkipValidation)
	    local self = {} setmetatable(self, Account)
	
	    local IsValid = SkipValidation or GET('GetCSRFToken', Username)
	
	    if not IsValid or IsValid == 'Invalid Account' then return false end
	
	    self.Username = Username
	
	    return self
	end
	
	function Account:GetCSRFToken() return GET('GetCSRFToken', self.Username) end
	
	function Account:BlockUser(Argument)
	    if typeof(Argument) == 'string' then
	        return GET('BlockUser', self.Username, 'UserId=' .. Argument)
	    elseif typeof(Argument) == 'Instance' and Argument:IsA'Player' then
	        return self:BlockUser(tostring(Argument.UserId))
	    elseif typeof(Argument) == 'number' then
	        return self:BlockUser(tostring(Argument))
	    end
	end
	function Account:UnblockUser(Argument)
	    if typeof(Argument) == 'string' then
	        return GET('UnblockUser', self.Username, 'UserId=' .. Argument)
	    elseif typeof(Argument) == 'Instance' and Argument:IsA'Player' then
	        return self:BlockUser(tostring(Argument.UserId))
	    elseif typeof(Argument) == 'number' then
	        return self:BlockUser(tostring(Argument))
	    end
	end
	function Account:GetBlockedList() return GET('GetBlockedList', self.Username) end
	function Account:UnblockEveryone() return GET('UnblockEveryone', self.Username) end
	
	function Account:GetAlias() return GET('GetAlias', self.Username) end
	function Account:GetDescription() return GET('GetDescription', self.Username) end
	function Account:SetAlias(Alias) return POST('SetAlias', self.Username, Alias) end
	function Account:SetDescription(Description) return POST('SetDescription', self.Username, Description) end
	function Account:AppendDescription(Description) return POST('AppendDescription', self.Username, Description) end
	
	function Account:GetField(Field) return GET('GetField', self.Username, 'Field=' .. HttpService:UrlEncode(Field)) end
	function Account:SetField(Field, Value) return GET('SetField', self.Username, 'Field=' .. HttpService:UrlEncode(Field), 'Value=' .. HttpService:UrlEncode(tostring(Value))) end
	function Account:RemoveField(Field) return GET('RemoveField', self.Username, 'Field=' .. HttpService:UrlEncode(Field)) end
	
	function Account:SetServer(PlaceId, JobId) return GET('SetServer', self.Username, 'PlaceId=' .. PlaceId, 'JobId=' .. JobId) end
	function Account:SetRecommendedServer(PlaceId) return GET('SetServer', self.Username, 'PlaceId=' .. PlaceId) end
	
	function Account:ImportCookie(Token) return GET('ImportCookie', 'Cookie=' .. Token) end
	function Account:GetCookie() return GET('GetCookie', self.Username) end
	function Account:LaunchAccount(PlaceId, JobId, FollowUser, JoinVip) -- if you want to follow someone, PlaceId must be their user id
	    return GET('LaunchAccount', self.Username, 'PlaceId=' .. PlaceId, JobId and ('JobId=' .. JobId), FollowUser and 'FollowUser=true', JoinVip and 'JoinVIP=true')
	end
	
	return Account, WebserverSettings
end)();
print("ok2")
sharedRequires['4888b6d494562c836ecb9bcf6094407bf4f08cdb14133dcafa68d80825b1c714'] = (function()
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local AltManagerAPI = sharedRequires['7c9714eaa13891b0bf7915d3b5cda22448de203a05b2dee268b670959ff8efe1'];
	local Players, GuiService, HttpService, StarterGui, VirtualInputManager, CoreGui = Services:Get('Players', 'GuiService', 'HttpService', 'StarterGui', 'VirtualInputManager', 'CoreGui');
	local LocalPlayer = Players.LocalPlayer;
	
	local BlockUtils = {};
	local IsFriendWith = LocalPlayer.IsFriendsWith;
	
	local apiAccount;
	
	task.spawn(function()
	    --apiAccount = AltManagerAPI.new(LocalPlayer.Name);
	end);
	
	local function isFriendWith(userId)
	    local suc, data = pcall(IsFriendWith, LocalPlayer, userId);
	
	    if (suc) then
	        return data;
	    end;
	
	    return true;
	end;
	
	function BlockUtils:BlockUser(userId)
	    if(library.flags.useAltManagerToBlock and apiAccount) then
	        apiAccount:BlockUser(userId);
	
	        local blockedListRetrieved, blockList = pcall(HttpService.JSONDecode, HttpService, apiAccount:GetBlockedList());
	        if(blockedListRetrieved and typeof(blockList) == 'table' and blockList.success and blockList.total >= 20) then
	            apiAccount:UnblockEveryone();
	        end;
	    else
	        library.base.Enabled = false;
	
	        local blockedUserIds = StarterGui:GetCore('GetBlockedUserIds');
	        local playerToBlock = Instance.new('Player');
	        playerToBlock.UserId = tonumber(userId);
	
	        local lastList = #blockedUserIds;
	        GuiService:ClearError();
	
	        repeat
	            StarterGui:SetCore('PromptBlockPlayer', playerToBlock);
	
	            local confirmButton = CoreGui.RobloxGui.PromptDialog.ContainerFrame:FindFirstChild('ConfirmButton');
	            if (not confirmButton) then break end;
	
	            local btnPosition = confirmButton.AbsolutePosition + Vector2.new(40, 40);
	
	            VirtualInputManager:SendMouseButtonEvent(btnPosition.X, btnPosition.Y, 0, false, game, 1);
	            task.wait();
	            VirtualInputManager:SendMouseButtonEvent(btnPosition.X, btnPosition.Y, 0, true, game, 1);
	            task.wait();
	        until #StarterGui:GetCore('GetBlockedUserIds') ~= lastList;
	
	        task.wait(0.2);
	
	        library.base.Enabled = true;
	    end;
	end;
	
	function BlockUtils:UnblockUser()
	
	end;
	
	function BlockUtils:BlockRandomUser()
	    for _, v in next, Players:GetPlayers() do
	        if (v ~= LocalPlayer and not isFriendWith(v.UserId)) then
	            self:BlockUser(v.UserId);
	            break;
	        end;
	    end;
	end;
	
	return BlockUtils;
end)();

sharedRequires['f1f475b5c3b4b14a174922964057fc8810955a390da10f669347f69062faa5ae'] = (function()
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local HttpService = Services:Get('HttpService');
	
	local Webhook = {};
	Webhook.__index = Webhook;
	
	function Webhook.new(url)
	    local self = setmetatable({}, Webhook);
	
	    self._url = url;
	
	    return self;
	end;
	
	function Webhook:Send(data, yields)
	    if (typeof(data) == 'string') then
	        data = {content = data};
	    end;
	
	    local function send()
	        request({
	            Url = self._url,
	            Method = 'POST',
	            Headers = {['Content-Type'] = 'application/json'},
	            Body = originalFunctions.jsonEncode(HttpService, data)
	        });
	    end;
	
	    if (yields) then
	        pcall(send);
	    else
	        task.spawn(send);
	    end;
	end;
	
	return Webhook;
end)();

sharedRequires['1b66bf97aa5a58914cadf4fb26437d4f41af93aa1067c3eeca682f353984bdb1'] = (function()
	local Webhook = sharedRequires['f1f475b5c3b4b14a174922964057fc8810955a390da10f669347f69062faa5ae'];
	local WEBHOOK_URL = '';
	
	local Security = {};
	
	-- TODO: Use our own backend logic rather than discord for logging the users infraction
	function Security:LogInfraction(infraction)
		
	   -- Webhook.new(WEBHOOK_URL):Send({
	     --   content = string.format('%s - %s', accountData.uuid, infraction)
	   -- }, true);
	
	    --return SX_CRASH();
	end
	
	return Security;
end)();

sharedRequires['7384d776692018050bf4de397fa761b48e15a71d1164cf9bf941d3f0c4e20040'] = (function()
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	local ToastNotif = sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'];
	local Security = sharedRequires['1b66bf97aa5a58914cadf4fb26437d4f41af93aa1067c3eeca682f353984bdb1'];
	
	local UserInputService, TweenService, TextService, ReplicatedStorage, Players, HttpService = Services:Get('UserInputService', 'TweenService', 'TextService', 'ReplicatedStorage', 'Players', 'HttpService');
	local LocalPlayer = Players.LocalPlayer;
	
	local TextLogger = {};
	TextLogger.__index = TextLogger;
	
	TextLogger.Colors = {};
	TextLogger.Colors.Background = Color3.fromRGB(30, 30, 30);
	TextLogger.Colors.Border = Color3.fromRGB(155, 155, 155);
	TextLogger.Colors.TitleColor = Color3.fromRGB(255, 255, 255);
	
	local Text = {};
	
	-- // Text
	do
	    Text.__index = Text;
	
	    function Text.new(options)
	        local self = setmetatable(options, Text);
	        self._originalText = options.originalText or options.text;
	
	        self.label = library:Create('TextLabel', {
	            BackgroundTransparency = 1,
	            Parent = self._parent._logs,
	            Size = UDim2.new(1, 0, 0, 25),
	            Font = Enum.Font.Roboto,
	            TextColor3 = options.color or Color3.fromRGB(255, 255, 255),
	            TextSize = 20,
	            RichText = true,
	            TextWrapped = true,
	            TextXAlignment = Enum.TextXAlignment.Left,
	            TextYAlignment = Enum.TextYAlignment.Top,
	            Text = self.text;
	        });
	
	        self:SetText(options.text);
	
	        self.OnMouseEnter = Signal.new();
	        self.OnMouseLeave = Signal.new();
	
	        local index = #self._parent.logs + 1;
	        local mouseButton2 = Enum.UserInputType.MouseButton2;
	        local mouseHover = Enum.UserInputType.MouseMovement;
	
	        self.label.InputBegan:Connect(function(inputObject, gpe)
	            if (inputObject.UserInputType == mouseButton2 and not gpe) then
	                local toolTip = self._parent._toolTip;
	
	                self._parent._currentToolTip = self;
	                self._parent._currentToolTipIndex = index;
	
	                toolTip.Visible = true;
	                toolTip:TweenSize(UDim2.fromOffset(150, #self._parent.params.buttons * 30), 'Out', 'Quad', 0.1, true);
	
	                local mouse = UserInputService:GetMouseLocation();
	                toolTip.Position = UDim2.fromOffset(mouse.X, mouse.Y);
	            elseif (inputObject.UserInputType == mouseHover) then
	                self.OnMouseEnter:Fire();
	            end;
	        end);
	
	        self.label.InputEnded:Connect(function(inputObject)
	            if (inputObject.UserInputType == mouseHover) then
	                self.OnMouseLeave:Fire();
	            end;
	        end);
	
	        table.insert(self._parent.logs, self);
	        table.insert(self._parent.allLogs, {
	            _originalText = self._originalText
	        });
	
	        local contentSize = self._parent._layout.AbsoluteContentSize;
	        self._parent._logs.CanvasSize = UDim2.fromOffset(0, contentSize.Y);
	
	        if (library.flags.chatLoggerAutoScroll) then
	            self._parent._logs.CanvasPosition = Vector2.new(0, contentSize.Y);
	        end;
	
	        return self;
	    end;
	
	    function Text:Destroy()
	        local logs = self._parent.logs;
	        table.remove(logs, table.find(logs, self));
	        self.label:Destroy();
	    end;
	
	    function Text:SetText(text)
	        self.label.Text = text;
	        local textSize = TextService:GetTextSize(self.label.ContentText, 20, Enum.Font.Roboto, Vector2.new(self._parent._logs.AbsoluteSize.X, math.huge));
	
	        self.label.Size = UDim2.new(1, 0, 0, textSize.Y);
	        self._parent:UpdateCanvas();
	    end;
	end;
	
	local function setCameraSubject(subject)
	    workspace.CurrentCamera.CameraSubject = subject;
	end;
	
	local function initChatLoggerPreset(chatLogger)
		library.unloadMaid:GiveTask(ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
	        for i = 2, 10 do
	            local l, s, n, f, a = debug.info(i, 'lsnfa');
	
	            if (l or s or n or f or a) then
	                task.spawn(function() Security:LogInfraction('omdf'); end);
	                return;
	            end;
	        end;
	
			--local player, message = originalFunctions.findFirstChild(Players, messageData.FromSpeaker), messageData.Message;
			if (not player or not message) then return end;
	
			chatLogger.OnPlayerChatted:Fire(player, message);
		end));
	
		local reported = {};
	
		chatLogger.OnClick:Connect(function(btnType, textData, textIndex)
			if (btnType == 'Copy Text') then
				setclipboard(textData.text);
			elseif (btnType == 'Copy Username') then
				setclipboard(textData.player.Name);
			elseif (btnType == 'Copy User Id') then
				setclipboard(tostring(textData.player.UserId));
			elseif (btnType == 'Spectate') then
				setCameraSubject(textData.player.Character);
				textData.tooltip.Text = 'Unspectate';
			elseif (btnType == 'Unspectate') then
				setCameraSubject(LocalPlayer.Character);
				textData.tooltip.Text = 'Spectate';
			elseif (btnType == 'Report User') then
				
			end;
		end);
	
		chatLogger.OnUpdate:Connect(function(updateType, vector)
			library.configVars['chatLogger' .. updateType] = tostring(vector);
		end);
	
		library.OnLoad:Connect(function()
			local chatLoggerSize = library.configVars.chatLoggerSize;
			chatLoggerSize = chatLoggerSize and Vector2.new(unpack(chatLoggerSize:split(',')));
	
			local chatLoggerPosition = library.configVars.chatLoggerPosition;
			chatLoggerPosition = chatLoggerPosition and Vector2.new(unpack(chatLoggerPosition:split(',')));
	
			if (chatLoggerSize) then
				chatLogger:SetSize(UDim2.fromOffset(chatLoggerSize.X, chatLoggerSize.Y));
			end;
	
			if (chatLoggerPosition) then
				chatLogger:SetPosition(UDim2.fromOffset(chatLoggerPosition.X, chatLoggerPosition.Y));
			end;
	
			chatLogger:UpdateCanvas();
		end);
	end;
	
	function TextLogger.new(params)
	    params = params or {};
	    params.buttons = params.buttons or {};
	    params.title = params.title or 'No Title';
	
	    local self = setmetatable({}, TextLogger);
	    local screenGui = library:Create('ScreenGui', {IgnoreGuiInset = true, Enabled = false, AutoLocalize = false});
	
	    self.params = params;
	    self._gui = screenGui;
	    self.logs = {};
	    self.allLogs = {};
	
	    self.OnPlayerChatted = Signal.new();
	    self.OnClick = Signal.new();
	    self.OnUpdate = Signal.new();
	
	    local main = library:Create('Frame', {
	        Name = 'Main',
	        Active = true,
	        Visible = true,
	        Size = UDim2.new(0, 500, 0, 300),
	        Position = UDim2.new(0.5, -250, 0.5, -150),
	        BackgroundTransparency = 0.3,
	        BackgroundColor3 = TextLogger.Colors.Background,
	        Parent = screenGui
	    });
	
	    self._main = main;
	
	    local dragger = library:Create('Frame', {
	        Parent = main,
	        Active = true,
	        BackgroundTransparency = 1,
	        Size = UDim2.new(0, 50, 0, 50),
	        Position = UDim2.new(1, 10, 1, 10),
	        AnchorPoint = Vector2.new(1, 1)
	    });
	
	    library:Create('UICorner', {
	        Parent = main,
	        CornerRadius = UDim.new(0, 4),
	    });
	
	    library:Create('UIStroke', {
	        Parent = main,
	        Color = TextLogger.Colors.Border
	    });
	
	    local title = library:Create('TextButton', {
	        Parent = main,
	        Size = UDim2.new(1, 0, 0, 30),
	        BackgroundTransparency = 1,
	        TextColor3 = TextLogger.Colors.TitleColor,
	        Font = Enum.Font.Roboto,
	        Text = params.title,
	        TextSize = 20
	    });
	
	    local dragStart;
	    local startPos;
	    local dragging;
	
	    dragger.InputBegan:Connect(function(inputObject, gpe)
	        if (inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
	            local dragStart = inputObject.Position;
	            dragStart = Vector2.new(dragStart.X, dragStart.Y);
	
	            local startPos = main.Size;
	
	            repeat
	                local mousePosition = UserInputService:GetMouseLocation();
	                local delta = mousePosition - dragStart;
	
	                main.Size = UDim2.new(0, startPos.X.Offset + delta.X, 0, (startPos.Y.Offset + delta.Y) - 36);
	
	                task.wait();
	            until (inputObject.UserInputState == Enum.UserInputState.End);
	
	            self:UpdateCanvas();
	            self.OnUpdate:Fire('Size', main.AbsoluteSize);
	        end;
	    end);
	
	    title.InputBegan:Connect(function(inputObject, gpe)
	        if (inputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return end;
	
	        dragging = true;
	
	        dragStart = inputObject.Position;
	        startPos = main.Position;
	
	        repeat
	            task.wait();
	        until inputObject.UserInputState == Enum.UserInputState.End;
	
	        self.OnUpdate:Fire('Position', main.AbsolutePosition);
	        dragging = false;
	
	        self:UpdateCanvas();
	    end);
	
	    UserInputService.InputChanged:Connect(function(input, gpe)
	        if (not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end;
	
	        local delta = input.Position - dragStart;
	        local yPos = startPos.Y.Offset + delta.Y;
	        main:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), 'Out', 'Quint', 0.1, true);
	    end);
	
	    local titleBorder = library:Create('Frame', {
	        Parent = title,
	        Size = UDim2.new(1, 0, 1, 0),
	        BackgroundTransparency = 1,
	    });
	
	    library:Create('UICorner', {
	        Parent = titleBorder,
	        CornerRadius = UDim.new(0, 4),
	    });
	
	    library:Create('UIStroke', {
	        Parent = titleBorder,
	        Color = TextLogger.Colors.Border
	    });
	
	    local logsContainer = library:Create('Frame', {
	        Parent = main,
	        BackgroundTransparency = 1,
	        Size = UDim2.new(1, 0, 1, -35),
	        Position = UDim2.fromOffset(0, 35)
	    });
	
	    library:Create('UIPadding', {
	        Parent = logsContainer,
	        PaddingBottom = UDim.new(0, 10),
	        PaddingLeft = UDim.new(0, 10),
	        PaddingRight = UDim.new(0, 10),
	        PaddingTop = UDim.new(0, 10),
	    });
	
	    local logs = library:Create('ScrollingFrame', {
	        Parent = logsContainer,
	        ClipsDescendants = true,
	        BorderSizePixel = 0,
	        Size = UDim2.fromScale(1, 1),
	        BackgroundTransparency = 1,
	        BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	        MidImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	        TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
	        ScrollBarThickness = 5,
	        CanvasSize = UDim2.new(0, 0, 0, 0),
	        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	    });
	
	    self._layout = library:Create('UIListLayout', {
	        Parent = logs,
	        Padding = UDim.new(0, 5),
	        FillDirection = Enum.FillDirection.Vertical,
	        HorizontalAlignment = Enum.HorizontalAlignment.Left,
	        SortOrder = Enum.SortOrder.LayoutOrder,
	        VerticalAlignment = Enum.VerticalAlignment.Top,
	    });
	
	    local toolTip = library:Create('Frame', {
	        Parent = screenGui,
	        BackgroundColor3 = TextLogger.Colors.Background,
	        Size = UDim2.new(0, 150, 0, 0),
	        ZIndex = 100,
	        ClipsDescendants = true,
	        Visible = false,
	    });
	
	    library:Create('UICorner', {
	        Parent = toolTip,
	        CornerRadius = UDim.new(0, 8),
	    });
	
	    library:Create('UIStroke', {
	        Parent = toolTip,
	        Color = TextLogger.Colors.Border,
	    });
	
	    library:Create('UIListLayout', {
	        Parent = toolTip,
	        Padding = UDim.new(0, 0),
	        FillDirection = Enum.FillDirection.Vertical,
	        HorizontalAlignment = Enum.HorizontalAlignment.Left,
	        SortOrder = Enum.SortOrder.LayoutOrder,
	        VerticalAlignment = Enum.VerticalAlignment.Top,
	    });
	
	    self._toolTip = toolTip;
	
	    local function makeButton(btnName)
	        local button = library:Create('TextButton', {
	            Parent = toolTip,
	            Size = UDim2.new(1, 0, 0, 30),
	            BackgroundTransparency = 1,
	            Font = Enum.Font.Roboto,
	            Text = btnName,
	            TextSize = 15,
	            TextColor3 = TextLogger.Colors.TitleColor,
	            ZIndex = 100
	        });
	
	        local textTweenIn = TweenService:Create(button, TweenInfo.new(0.1), {
	            TextColor3 = Color3.fromRGB(200, 200, 200)
	        });
	
	        local textTweenOut = TweenService:Create(button, TweenInfo.new(0.1), {
	            TextColor3 = Color3.fromRGB(255, 255, 255)
	        });
	
	        button.MouseEnter:Connect(function()
	            textTweenIn:Play();
	        end);
	
	        button.MouseLeave:Connect(function()
	            textTweenOut:Play();
	        end);
	
	        button.InputBegan:Connect(function(inputObject, gpe)
	            if (gpe or inputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return end;
	
	            self._currentToolTip.tooltip = button;
	            self.OnClick:Fire(button.Text, self._currentToolTip, self._currentToolTipIndex);
	        end);
	    end;
	
	    self._logs = logs;
	
	    --syn.protect_gui(screenGui);
	    screenGui.Parent = game.CoreGui;
	
	    UserInputService.InputBegan:Connect(function(input)
	        local userInputType = input.UserInputType;
	
	        if (userInputType == Enum.UserInputType.MouseButton1) then
	            self._toolTip:TweenSize(UDim2.new(0, 150, 0, 0), 'Out', 'Quad', 0.1, true, function()
	                self._toolTip.Visible = false;
	            end);
	
	            self._currentToolTip = nil;
	            self._currentToolTipIndex = nil;
	        end;
	    end);
	
	    for _, v in next, params.buttons do
	        makeButton(v);
	    end;
	
	    if (params.preset == 'chatLogger') then
	        initChatLoggerPreset(self);
	    end;
	
	    return self;
	end;
	
	function TextLogger:AddText(textData)
	    textData._parent = self;
	    local textObject = Text.new(textData);
	
	    return textObject;
	end;
	
	function TextLogger:SetVisible(state)
	    self._gui.Enabled = state;
	end;
	
	function TextLogger:UpdateCanvas()
	    for _, v in next, self.logs do
	        local textSize = TextService:GetTextSize(v.label.ContentText, 20, Enum.Font.Roboto, Vector2.new(self._logs.AbsoluteSize.X, math.huge));
	        v.label.Size = UDim2.new(1, 0, 0, textSize.Y);
	    end;
	
	    local contentSize = self._layout.AbsoluteContentSize;
	
	    self._logs.CanvasSize = UDim2.fromOffset(0, contentSize.Y);
	
	    if (library.flags.chatLoggerAutoScroll) then
	        self._logs.CanvasPosition = Vector2.new(0, contentSize.Y);
	    end;
	end;
	
	function TextLogger:SetSize(size)
	    self._main.Size = size;
	    self:UpdateCanvas();
	end;
	
	function TextLogger:SetPosition(position)
	    self._main.Position = position;
	    self:UpdateCanvas();
	end;
	
	return TextLogger;
end)();

sharedRequires['0ba0bfea44d06894aff3f290e6bea37c2898b4ef7a13374f47b1ff040bc352ef'] = (function()
	local function fromHex(str)
	    return (string.gsub(str, '..', function (cc)
	        return string.char(tonumber(cc, 16));
	    end));
	end;
	
	return fromHex;
end)();
print("ok4")
sharedRequires['c83ce6a4e7b2a57431226bcf42132062a87d15e0887c9580ba22afdca872839f'] = (function()
	return [[{"2637545558":"Silver Ring","5069102444":"Stick","7808606344":"Green Adventurer Coat","6448694082":"Herbalist's Hat","7808436873":"Guard's Kabuto","7808435817":"Red Royal Guard","7032469171":"Spark Gland","5842121293":"Ranger's Boots","8700290376":"Smoke Ministry Cloak","4673673233":"Messer","8765495788":"Flamekeeper Cestus","8700292068":"Purple Royal Duelist","7808426095":"Black Adventurer Coat","6448695746":"Crescent Cleaver","10944864312":"Kyrscleave","8700297246":"Red Justicar Defender","7837367316":"Dawn Scarf","5405133671":"Gremorian Longspear","7819487839":"Aristocrat Glasses","11493419845":"Rifle Spear","5799297150":"Ten-gallon Hat","9337204134":"Bounder Claw","6429369728":"Seafood Boil","5855133355":"Vigil Hood","7036471589":"Reversal Spark","7836919224":"Forest Scarf","7013706647":"Silver Ring","5799298101":"Novice Brace","9969347036":"Ironsinger Heavy Plate","7837621224":"Black Shrouded Cape","5907307871":"Brilliant Cape","5842120234":"Hunter's Brace","7808436633":"Captain's Kabuto","5405135270":"Falchion","8270698605":"Iron Cestus","7013402708":"Isshin's Ring","6448728441":"Star Duster","5705963126":"Blacksteel Pauldrons","8700281529":"Sage Pathfinder Elite","11491707869":"Kyrstreza","8280107937":"The Path's Defender","6448742964":"Razor Cutlass","10431523243":"Gran Sudaruska","5405136068":"Vigil Longsword","8700640454":"Umber First Ranger Duster","5405134593":"Gilded Knife","5842122844":"Imperial Boots","7032715026":"Gale Stone","9960339048":"Phalanx Helm","5054802060":"Broken Gatling Gun","7837370563":"White Scarf","7808431912":"Shattered Katana","5842122594":"Autumn Boots","6132543079":"Bloodfeather Cowl","5842969006":"Worshipper's Shield","5842121371":"Redsteel Boots","11123380641":"Browncap","4653682385":"Mace","6419942986":"Calamari","7808435621":"Hivelord Mask","5405134478":"Whaling Knife","6448697951":"Azure Royal Guard","5894739497":"Apprentice Rapier","4665676177":"Plumfruit","6436226661":"Crystal Pendant Earrings","5405134330":"Adretian Axe","5799300555":"Black Fur Pauldrons","8700291659":"Green Royal Duelist","5799299766":"Imperial Pauldrons","7819487052":"Red Aristocrat Glasses","6249271537":"Flintlock","9960340205":"Mercenary's Garb","7808435989":"Blue Royal Guard","11508432095":"Enforcer's Axe","6012236150":"Kite Shield","6436226327":"Ruby Drop Earrings","6424915152":"Scallop","6448694267":"Herbalist's Hat","6424915468":"Urchin","5405138402":"Hero Blade Of Shadow","7650051743":"Sword","5799297636":"Feathertop Helm","5799300308":"Bluesteel Pauldrons","5799295812":"Black Deepwoken Cloak","13002269112":"Flareblood Kamas","8121417213":"Tanto","6489268160":"Rosen's Peacemaker","6448694802":"Vagabond's Bicorn","5714510638":"Blacksteel Helm","6448702481":"Grand Boots","6419750949":"Sea Bass","5799297250":"Black Blindfold","7666186674":"White Gumshoe Longcoat","7837370225":"Black Scarf","6669315144":"Authority Helm","8764565495":"Canor Fang","5799295080":"Investigator's Hat","8138184965":"Champion's Sword","8699695290":"First Light","9960336716":"Sandrunner Scarf","6429530863":"Demon Mask","5405134819":"Silver Dagger","6448698418":"Azure Royal Guards","7673608398":"Beige Aristocrat Coat","8700289279":"Red Ministry Cloak","7808427062":"Brown Adventurer Coat","8700287249":"Green Megalodaunt Coat","6022452972":"Khan Shield","5705963429":"Canticlysm Pendant","5049245745":"Wheat","5799302611":"Nomad Pendant","5628707607":"Strange Claw","7837621530":"Midnight Shrouded Cape","8700357191":"Magenta Elite Pathfinder","8700640450":"Azure First Ranger Duster","5817301154":"Vanguard Brace","5805397315":"Smith's Gloves","5850589846":"Legate Helm","9960339470":"Phalanx Heavy Boots","5051248589":"Calabash","9048865551":"Railblade","5705976072":"Moonlit Earrings","5542033067":"Leather Boots","8700290825":"Peach Ministry Cloak","7837620789":"Red Shrouded Cape","8700640449":"Lavender First Ranger Duster","8700292776":"Rose Royal Duelist","5405133451":"Ritual Spear","9752895127":"Inquisitor's Thorn","5405135891":"Officer Saber","6448694628":"Alchemist Hat","5842122067":"Black Fur Boots","5799303918":"Emerald Tusk Earrings","7808431156":"Pale Assassin's Cloak","7837360302":"Tundra Scarf","9960341323":"Celtorian Sabatons","11468956988":"Petra's Anchor","7666184050":"Grey Gumshoe Longcoat","6448696178":"Darksteel Greatsword","4673703249":"Iron Spear","9960338123":"Bulwark Helm","7666186063":"Black Gumshoe Longcoat","8699695169":"Night Axe","5799296946":"Brigand's Bicorn","5799303611":"Pendant Earrings","12868100519":"Crypt Blade","5705963723":"Old Blood Earrings","6334456831":"Hivelord Hubris","5706119518":"Gladiator Pauldrons","10374163255":"Hive Scourge Cuirass","7819486539":"Polarized Eyeglasses","8700640465":"Jade First Ranger Duster","5606047864":"Schematic","11122387292":"Dentifilo","6448698795":"Iron Pauldrons","5405138500":"Krulian Knife","9594272549":"Megurger","6132703115":"Bloodfeather Mask","10374055286":"Etrean Siege Sabatons","6448700096":"Enforcer Plate","7666184629":"Gumshoe Hat","6448692964":"Blindfold","5048774760":"Coral","10857130088":"Iron Birch","7771927612":"Worn Cog","6498239550":"Konga's Clutch Ring","4673700644":"Stiletto","5849612301":"Leather Pauldrons","8230193135":"Dark Feather","5842122480":"Bluesteel Boots","5405135657":"Officer Saber","5799301768":"Woodland Pauldrons","6448693907":"Glassdancer Wraps","5799298923":"White Parka","5405134045":"Forge Greathammer","6424914992":"Chum","5799301251":"Redsteel Pauldrons","5610004726":"Master Thief Earrings","6436226803":"Dew Drop Earrings","6424318342":"Fish Omelette","5849601024":"Halberd","12500495992":"Akira's Ring","10374148323":"Winter Corps Parka","8275365134":"Ethiron Curseshield","7038529675":"Aeon Logstone","10653583718":"Light's Final Toll","5799300026":"Autumn Pauldrons","9960335808":"Dark Owl Cloak","6274335402":"Black Hood","8699695073":"Acheron's Warspear","5707321653":"Confessor's Charm","9960341166":"Celtor Commander Plate","9960340839":"Celtor Helm","5799302078":"Flameguard Pauldrons","12900346985":"Curved Blade Of Winds","5714510949":"Gladiator Helmet","6436226542":"Amethyst Pendant Earrings","5877374213":"Black Cape","8700291376":"Red Royal Duelist","5907308073":"Brilliant Pauldrons","6448695545":"Knight's Helm","10649431674":"Iron Blunderbuss","5799299115":"Black Parka","8700296939":"Black Justicar Defender","7013783109":"Silver Ring","5106910210":"Megalodaunt Coral","8229693222":"Thresher Spine","8700281646":"Ash Pathfinder Elite","7032332910":"Frigid Prism","6022452674":"Khan Boots","6349514972":"Targe","5842122238":"White Fur Boots","8700281155":"Black Pathfinder Elite","10374052860":"Etrean Siege Cuirass","5799303085":"Red Eye Pendant","10374149549":"Winter Corps Boots","9960337717":"Grand Authority Plate","8280463944":"Old World Greatshield","5405134185":"Canorian Axe","5805397758":"Smith Bandana","5405135397":"Zweihander","7808435506":"Duelist's Mask","7666184486":"Ochre Gumshoe Longcoat","8700290043":"Yellow Ministry Cloak","8700289897":"Verdant Ministry Cloak","9995290481":"Frozen Membrane","5799301536":"Ranger's Brace","5405133921":"Steel Maul","7837363369":"Crimson Scarf","8699695168":"Relic Axe","7808436350":"Royal Guard's Kabuto","6424318416":"Mushroom Omelette","5043681225":"Mushroom Soup","10374079308":"Ministry Operative Cloak","11237117285":"Enforcer's Blade","5405136314":"Pale Morning","5058929875":"Ongo","5799297023":"Eyeglasses","5799297369":"Strapped Hat","5557731080":"Barrel Helm","5069092985":"Wood","6448699922":"Enforcer Boots","8700282599":"Crimson Pathfinder Elite","8700297896":"Purple Justicar Defender","5805397989":"Smith's Goggles","6424318273":"Fish Meat","10944864020":"Kyrstear","9960336308":"Dark Owl Chapeau","5842120380":"Vanguard Boots","8700289423":"Onyx Ministry Cloak","5799295189":"Polarized Eyeglasses","6022452767":"Khan Pauldrons","5799295349":"Dark Cowl","5058784034":"Spider Egg","6448697007":"Warden Ceremonial Sword","8700287002":"Red Megalodaunt Coat","6448696838":"Iron Mask","8700286805":"Blue Megalodaunt Coat","5714510810":"Guardian Helm","5705962526":"Guardian Pauldrons","8699695269":"Inquisitor's Straight Sword","5922042274":"Cloth","4673718281":"Battleaxe","7837617108":"White Shrouded Cape","7836920551":"Desert Scarf","4673679440":"Katana","8700291113":"Faded Royal Duelist","5045088863":"Bamboo Bundle","9960337519":"Grand Authority Sabatons","5799296265":"Brown Parka","8699695180":"True Seraph's Spear","5842121006":"Woodland Boots","10944863839":"Kyrsblade","5842123154":"Tracker's Boots","8699695052":"Evanspear Handaxe","11398158868":"Enforcer Hammer","4673686878":"Scimitar","6448694456":"Alchemist's Hat","8700287472":"Blue Megalodaunt Coat","5558108814":"Silver Ring","8274858821":"Legion Cestus","6448696405":"Shotel","5799302810":"Varicosa Medallion","5799302952":"Bloodcurse Pendant","5907308163":"Brilliant Boots","6424318562":"Sushi","8700297663":"Faded Justicar Defender","9960338845":"Legion Phalanx Plate","6448701754":"Grand Pauldrons","6436226440":"Practicioner's Earrings","6695910473":"Enforcer Eye","8700288111":"Peach Megalodaunt Coat","6448694964":"Crimson Blindfold","8699695126":"Sacred Hammer","8700292481":"Dark Royal Duelist","8700298677":"Orange Justicar Defender","8700287807":"Brown Megalodaunt Coat","5799295446":"Red Headband","5799297882":"Silver Pauldrons","5850573360":"Simple Pauldrons","8699695031":"Serrated Warspear","9960340613":"Mercenary's Boots","8699695191":"Great Maul","5799304203":"Seafarer Pendant","11491707780":"Kyrsedge","7837361566":"Desert Scarf","6419942901":"Egg","6448695134":"Investigator's Hat","5799300695":"White Fur Pauldrons","8700640458":"Cloud First Ranger Duster","8699695246":"Forgotten Gladius","7808435294":"Assassin's Hood","5842123537":"Silver Sabatons","8215631291":"Thresher Talon","5799297473":"Ten-gallon Bandana","5842123345":"Novice Boots","9960336983":"Sandrunner Wraps","6448728622":"Star Boots","6448698967":"Iron Boots","7023923881":"Dying Embers","5052282912":"Beeswax","6471674350":"Dragoon","6448695350":"Blackleaf Helm","5799296847":"Brigand Cloak","6448695945":"Serpent's Edge","5058929959":"Redd","4665615318":"Pomar","10944864619":"Kyrsglaive","7036671370":"Umbral Obsidian","5557731910":"Steel Pauldrons","5842120635":"Woodland Boots","9752893846":"Crucible Rapier","7808426565":"White Deepwoken Cloak","8700298453":"Pink Justicar Defender","6022467997":"Khan Helmet","6481418019":"Revolver","9960336188":"Dark Owl Cape","5799472140":"Black Parka","6406423250":"Providence Coat","11122306597":"Gobletto","9971524012":"Old World Sun Pendant","5405135049":"Worshipper Longsword","7808425864":"Royal Pathfinder","8764565306":"Nemit's Sickle","8699695303":"Markor's Inheritor","5405133802":"Trident Spear"}]]
end)();

sharedRequires['86ff59a72aa0134033a45a2517ab434d34ec44d886554adb2efc1b5600868d9b'] = (function()
	local LocalPlayer = game:GetService('Players').LocalPlayer;
	local ReplicatedStorage = game:GetService('ReplicatedStorage');
	
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local ToastNotif = sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'];
	
	local function createCirclet(parent, weldPart, cframe, color)
	    local circlet = game:GetObjects('rbxassetid://12562484379')[1]:Clone();
	    circlet.Size = Vector3.new(1.372, 0.198, 1.396);
	    circlet.Parent = parent;
	
	    if (color) then
	        circlet.Color = color;
	    end;
	
	    local weld = Instance.new('Weld', circlet);
	    weld.Part0 = weldPart;
	    weld.Part1 = circlet;
	    weld.C0 = cframe;
	
	    return circlet;
	end;
	
	return function (misc)
	    local functions = {};
	    local globalMaid = Maid.new();
	
	    local function makeToggle(name, parts, offset)
	        local maid = Maid.new();
	        local currentColor;
	
	        misc:AddToggle({
	            text = name,
	            callback = function(t)
	                if (not t) then
	                    maid:DoCleaning();
	                    return;
	                end;
	
	                local function onCharacterAdded(character)
	                    if (not character) then return end;
	
	                    for i, partName in next, parts do
	                        task.spawn(function()
	                            local partObject = character:WaitForChild(partName, 5);
	                            if (not partObject) then return end;
	
	                            maid[name .. i] = createCirclet(character, partObject, offset, currentColor);
	                        end);
	                    end;
	                end;
	
	                onCharacterAdded(LocalPlayer.Character);
	                maid:GiveTask(LocalPlayer.CharacterAdded:Connect(onCharacterAdded));
	            end
	        }):AddColor({
	            text = name,
	            callback = function(color)
	                for i = 1, #parts do
	                    if (not maid[name..i]) then continue end;
	                    maid[name .. i].Color = color;
	                end;
	
	                currentColor = color;
	            end
	        });
	    end;
	
	    local turnedOn = false;
	
	    function functions.lightbornSkinColor(t)
	        if (not t) then
	            globalMaid.lightbornSkinColor = nil;
	            if (turnedOn) then
	                turnedOn = false;
	                ToastNotif.new({text = 'Respawn to get back old skin color'});
	            end;
	            return;
	        end;
	
	        turnedOn = true;
	
	        globalMaid.lightbornSkinColor = task.spawn(function()
	            while true do
	                task.wait(0.1);
	                if (not LocalPlayer.Character) then continue end;
	                pcall(function()
	                    LocalPlayer.Character.Head.FaceMount.DGFace.Texture = "rbxassetid://6466188578"
	                end);
	                for _, v in next, LocalPlayer.Character:GetChildren() do
	                    if (v.Name == 'LightbornCirclet') then continue end;
	                    if (v:FindFirstChild('MarkingMount')) then
	                        v.MarkingMount.Color = Color3.fromRGB(253, 234, 141);
	                    elseif (v:IsA('BasePart')) then
	                        v.Color = Color3.fromRGB(253, 234, 141);
	                    end;
	                end;
	            end;
	        end);
	    end;
	
	    local function contractorToggle(t)
	        if (not t) then
	            globalMaid.contractorCharAdded = nil;
	            globalMaid.contractorParts = nil;
	            return;
	        end;
	
	        local function onCharacterAdded(character)
	            if (not character) then return end;
	            local char = LocalPlayer.Character;
	            local hrp = char:WaitForChild('HumanoidRootPart', 10);
	            if (not hrp) then return end;
	
	            local string = ReplicatedStorage.Assets.Effects.ContractorString;
	            local clone1, clone2, clone3, clone4;
	
	            do
	                clone1 = string:Clone();
	                clone1.Parent = hrp;
	
	                local attachment1 = Instance.new("Attachment",hrp);
	                attachment1.Position = Vector3.new(1,5,0);
	                attachment1.Name = "StringAttach1";--AboveHrp
	
	                local attachment2 = Instance.new("Attachment",char.RightHand);
	                attachment2.Position = Vector3.new(0.5,0,0);
	                attachment2.Name = "StringAttach2";--RightHand
	
	                clone1.Attachment1 = attachment1;
	                clone1.Attachment0 = attachment2;
	
	
	                clone2 = string:Clone();
	                clone2.Parent = hrp;
	
	                local attachment3 = Instance.new("Attachment",hrp);
	                attachment3.Position = Vector3.new(-1,5,0);
	                attachment3.Name = "StringAttach3";--AboveHrp
	
	                local attachment4 = Instance.new("Attachment",char.LeftHand);
	                attachment4.Position = Vector3.new(-0.5,0,0);
	                attachment4.Name = "StringAttach4";--LeftHand
	
	                clone2.Attachment1 = attachment3;
	                clone2.Attachment0 = attachment4;
	            end
	
	            do
	                clone3 = string:Clone();
	                clone3.Parent = hrp;
	
	                local attachment3 = Instance.new("Attachment",hrp);
	                attachment3.Position = Vector3.new(0.5,5,0);
	                attachment3.Name = "StringAttach3";--RightShoulder
	
	                clone3.Attachment1 = attachment3;
	                clone3.Attachment0 = char.Torso.RightCollarAttachment;
	
	                clone4 = string:Clone();
	                clone4.Parent = hrp;
	
	                local attachment4 = Instance.new("Attachment",hrp);
	                attachment4.Position = Vector3.new(-1,5,0);
	                attachment4.Name = "StringAttach4"; --LeftShoulder
	
	                clone4.Attachment1 = attachment4;
	                clone4.Attachment0 = char.Torso.LeftCollarAttachment;
	            end
	
	            globalMaid.contractorParts = function()
	                clone1:Destroy();
	                clone2:Destroy();
	                clone3:Destroy();
	                clone4:Destroy();
	            end;
	        end
	
	        onCharacterAdded(LocalPlayer.Character);
	        globalMaid.contractorCharAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded);
	    end
	
	    misc:AddToggle({text = 'Lightborn Skin Color', callback = functions.lightbornSkinColor})
	
	    makeToggle('Lightborn (Variant 1)', {'Head'}, CFrame.new(-0.001, 0.754, -0.002));
	    makeToggle('Lightborn (Variant 2)', {'Head'}, CFrame.new(-0.001, -0.35, -0.002));
	    makeToggle('Lightborn (Variant 3)', {'Right Arm', 'Left Arm'}, CFrame.new(-0.001, -0.5, -0.002));
	
	    misc:AddToggle({
	        text = 'Contractor',
	        callback = contractorToggle
	    })
	end;
end)();

sharedRequires['eae9c687aef93e970b60014156f3fb7370d92bf90fdcca844a55da79bf23dc2c'] = (function()
	-- Thanks corewave
	type = typeof or type
	local str_types = {
	    ['boolean'] = true,
	    ['userdata'] = true,
	    ['table'] = true,
	    ['function'] = true,
	    ['number'] = true,
	    ['nil'] = true
	}
	
	local function count_table(t)
	    local c = 0
	    for i, v in next, t do
	        c = c + 1
	    end
	
	    return c
	end
	
	local function string_ret(o, typ)
	    local ret, mt, old_func
	    if not (typ == 'table' or typ == 'userdata') then
	        return tostring(o)
	    end
	    mt = (getrawmetatable or getmetatable)(o)
	    if not mt then 
	        return tostring(o)
	    end
	
	    old_func = rawget(mt, '__tostring')
	    rawset(mt, '__tostring', nil)
	    ret = tostring(o)
	    rawset(mt, '__tostring', old_func)
	    return ret
	end
	
	local function format_value(v)
	    local typ = type(v)
	
	    if str_types[typ] then
	        return string_ret(v, typ)
	    elseif typ == 'string' then
	        return '"'..v..'"'
	    elseif typ == 'Instance' then
	        return v.GetFullName(v)
	    else
	        return typ..'.new(' .. tostring(v) .. ')'
	    end
	end
	
	local function serialize_table(t, p, c, s)
	    local str = ""
	    local n = count_table(t)
	    local ti = 1
	    local e = n > 0
	
	    c = c or {}
	    p = p or 1
	    s = s or string.rep
	
	    local function localized_format(v, is_table)
	        return is_table and (c[v][2] >= p) and serialize_table(v, p + 1, c, s) or format_value(v)
	    end
	
	    c[t] = {t, 0}
	
	    for i, v in next, t do
	        local typ_i, typ_v = type(i) == 'table', type(v) == 'table'
	        c[i], c[v] = (not c[i] and typ_i) and {i, p} or c[i], (not c[v] and typ_v) and {v, p} or c[v]
	        str = str .. s('  ', p) .. '[' .. localized_format(i, typ_i) .. '] = '  .. localized_format(v, typ_v) .. (ti < n and ',' or '') .. '\n'
	        ti = ti + 1
	    end
	
	    return ('{' .. (e and '\n' or '')) .. str .. (e and s('  ', p - 1) or '') .. '}'
	end
	
	if (debugMode) then
	    getgenv().prettyPrint = serialize_table;
	end;
	
	return serialize_table
end)();
if (not accountData) then
    accountData = {
        uuid = 'test',
        createdAt = 0,
        flags = {},
        roles = {'AnimeAdventuresScript'},
        username = 'test'
    }
end;

local debugMode = true;
_G = debugMode and _G or {};

local scriptLoadAt = tick();
local websiteScriptKey, scriptKey = getgenv().websiteKey, getgenv().scriptKey;
local silentLaunch = not not getgenv().silentLaunch;

local function printf() end;

if (not game:IsLoaded()) then
    game.Loaded:Wait();
end;
print("ok5")
local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];

local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];

local ToastNotif = sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'];
local AnalayticsAPI = sharedRequires['793f930ecb181c0adaed99b639258b9f609c01a7c4fec27d268ac7a909248f6d'];
local errorAnalytics = AnalayticsAPI.new("UA-187309782-1");
local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];

local _ = sharedRequires['eae9c687aef93e970b60014156f3fb7370d92bf90fdcca844a55da79bf23dc2c'];

local Players, TeleportService, ScriptContext, MemStorageService, HttpService, ReplicatedStorage = Services:Get("Players", 'TeleportService', 'ScriptContext', 'MemStorageService', 'HttpService', 'ReplicatedStorage');

local BLOODLINES_MAIN_PLACE = 10266164381;
local BLOODLINES = 1946714362;

-- If script ran for more than 60 sec and game is rogue lineage then go back to teleporter
if(tick() - scriptLoadAt >= 60) then
    if((game.PlaceId == 3541987450 or game.PlaceId == 3016661674 or game.PlaceId == 5208655184)) then
        TeleportService:Teleport(3016661674);
        return;
    elseif (game.GameId == BLOODLINES) then
        TeleportService:Teleport(BLOODLINES_MAIN_PLACE);
    end;
end;

do -- //Hook print debug
    if (debugMode) then
        local oldPrint = print;
        local oldWarn = warn;
        function print(...)
            return oldPrint('[DEBUG]', ...);
        end;

        function warn(...)
            return oldWarn('[DEBUG]', ...);
        end;

        function printf(msg, ...)
            return oldPrint(string.format('[DEBUG] ' .. msg, ...));
        end;
    else
        function print() end;
        function warn() end;
        function printf() end;
    end;
end;

local LocalPlayer = Players.LocalPlayer
local executed = false;


    getgenv().debugMode = debugMode;

    getgenv().originalFunctions = {
        fireServer = Instance.new('RemoteEvent').FireServer,
        invokeServer = Instance.new('RemoteFunction').InvokeServer,
        getRankInGroup = LocalPlayer.GetRankInGroup,
        index = getrawmetatable(game).__index,
        jsonEncode = HttpService.JSONEncode,
        jsonDecode = HttpService.JSONDecode,
        findFirstChild = game.FindFirstChild,
        --runOnActor = syn.run_on_actor,
       --getCommChannel = syn.get_comm_channel
    }


LocalPlayer.OnTeleport:Connect(function(state)
    if (executed or state ~= Enum.TeleportState.InProgress) then return end;
    executed = true;

    if(not debugMode) then
    	
    end;
end);

local supportedGamesList = HttpService:JSONDecode(sharedRequires['a3e29534c54ea992e4901bd5905bcd2eaf0da968e55f3206813e3acc65092050']);
local gameName = supportedGamesList[tostring(game.GameId)];

--//Base library

for _, v in next, getconnections(LocalPlayer.Idled) do
    if (v.Function) then continue end;
    v:Disable();
end;

--//Load special game Hub

local window;
local column1;
local column2;

if(debugMode) then
    ToastNotif.new({
        text = 'Hub running in debug mode'
    });
end;

if (gameName) then
    window = library:AddTab(gameName);
    column1 = window:AddColumn();
    column2 = window:AddColumn();

    library.columns = {
        column1,
        column2
    };

    library.gameName = gameName;
    library.window = window;
end;

local myScriptId = debug.info(1, 's');
local seenErrors = {};

local hubVersion = typeof(ah_metadata) == 'table' and rawget(ah_metadata, 'version') or '';
if (typeof(hubVersion) ~= "string") then return SX_CRASH() end;

local function onScriptError(message)
    if (table.find(seenErrors, message)) then
        return;
    end;

    if (message:find(myScriptId)) then
        table.insert(seenErrors, message);
        local reportMessage = 'aztuphub_v_' .. hubVersion .. message;
        errorAnalytics:Report(gameName, reportMessage, 1);
    end;
end

if (not debugMode) then
    ScriptContext.ErrorDetailed:Connect(onScriptError);
    if (gameName) then
        errorAnalytics:Report('Loaded', gameName, 1);

        if (not MemStorageService:HasItem('AnalyticsGame')) then
            MemStorageService:SetItem('AnalyticsGame', true);
            errorAnalytics:Report('RealLoaded', gameName, 1);
        end;
    end;
end;

--//Loads universal part

local universalLoadAt = tick();

(function()
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local EntityESP = sharedRequires['6037201603f3197c312ecccbded8cdd18de7f32b2f881a4231fdf106ef3fc7eb'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];
	
	local Players, RunService = Services:Get("Players", "RunService");
	local LocalPlayer = Players.LocalPlayer;
	
	local maid = Maid.new();
	local entityEspList = {};
	
	local function onPlayerAdded(player)
	    if (player == LocalPlayer) then return end;
	    local espEntity = EntityESP.new(player);
	
	    library.unloadMaid[player] = function()
	        table.remove(entityEspList, table.find(entityEspList, espEntity));
	        espEntity:Destroy();
	    end;
	
	    table.insert(entityEspList, espEntity);
	end;
	
	local function onPlayerRemoving(player)
	    library.unloadMaid[player] = nil;
	end;
	
	library.OnLoad:Connect(function()
	    Players.PlayerAdded:Connect(onPlayerAdded);
	    Players.PlayerRemoving:Connect(onPlayerRemoving);
	
	    for i, v in next, Players:GetPlayers() do
	        task.spawn(onPlayerAdded, v);
	    end;
	end);
	
	local function updateEspState(toggle)
	    if (not toggle) then
	        maid.updateEsp = nil;
	        for _, entity in next, entityEspList do
	            --entity:Hide();
	        end;
	
	        return;
	    end;
	
	    local lastUpdateAt = 0;
	    local ESP_UPDATE_RATE = 10/1000;
	
	    maid.updateEsp = RunService.RenderStepped:Connect(function()
	        if (tick() - lastUpdateAt < ESP_UPDATE_RATE) then return end;
	        lastUpdateAt = tick();
	
	        debug.profilebegin('Full Entity Update');
	
	        for _, entity in next, entityEspList do
	            debug.profilebegin('Single Entity Update ' .. entity._playerName);
	            entity:Update();
	            debug.profileend();
	        end;
	
	        debug.profileend();
	    end);
	end;
	
	local function toggleRainbowEsp(flag)
	    return function(toggle)
	        if(not toggle) then
	            maid['rainbow' .. flag] = nil;
	            return;
	        end;
	
	        maid['rainbow' .. flag] = RunService.RenderStepped:Connect(function()
	            library.options[flag]:SetColor(library.chromaColor, false, true);
	        end);
	    end;
	end;
	
	local esp = library:AddTab('ESP');
	local column1 = esp:AddColumn();
	local column2 = esp:AddColumn();
	local espSettings = column1:AddSection("Esp Settings");
	local espCustomisation = column2:AddSection("Esp Customisation");
	local proximityArrows = column1:AddSection("a8165694dfdfaa22d8d3a7160261a637");
	
	espSettings:AddToggle({
	    text = 'Toggle Esp',
	    callback = updateEspState
	}):AddSlider({
	    text = 'Max Esp Distance',
	    value = 10000,
	    min = 50,
	    max = 10000,
	    callback = function(value)
	        if (value == 10000) then
	            value = math.huge;
	        end;
	
	        library.flags.maxEspDistance = value;
	    end,
	});
	
	espSettings:AddList({
	    text = 'Esp Font',
	    flag = 'Esp Font',
	    values = {'UI', 'System', 'Plex', 'Monospace'},
	    callback = function(font)
	        font = Drawing.Fonts[font];
	        for i, v in next, entityEspList do
	           -- v:SetFont(font);
	        end;
	    end,
	});
	
	espSettings:AddSlider({
	    text = 'Text Size',
	    textpos = 2,
	    max = 100,
	    min = 16,
	    callback = function(textSize)
	        for i, v in next, entityEspList do
	           -- v:SetTextSize(textSize);
	        end;
	    end;
	});
	
	espSettings:AddToggle({
	    text = 'Toggle Tracers',
	});
	
	proximityArrows:AddToggle({
	    text = 'Proximity Arrows',
	}):AddSlider({text = 'Arrows Size', flag = 'Proximity Arrows Size', min = 10, max = 25, value = 20, textpos = 2});
	
	proximityArrows:AddSlider({
	    text = 'Max Distance',
	    flag = 'Max Proximity Arrow Distance',
	    min = 0,
	    max = 2000,
	    value = 1000
	});
	
	espSettings:AddToggle({
	    text = 'Toggle Boxes',
	});
	
	-- espSettings:AddToggle({
	--     text = '2D Esp',
	--     flag = 'Two Dimensions E S P'
	-- });
	
	espSettings:AddToggle({
	    text = 'Show Health Bar'
	});
	
	espSettings:AddToggle({
	    text = 'Show Team',
	});
	
	espCustomisation:AddToggle({
	    text = 'Rainbow Enemy Color',
	    callback = toggleRainbowEsp('enemyColor')
	});
	
	espCustomisation:AddToggle({
	    text = 'Rainbow Ally Color',
	    callback = toggleRainbowEsp('allyColor')
	});
	
	espCustomisation:AddToggle({
	    text = 'Unlock Tracers',
	});
	
	espCustomisation:AddColor({
	    text = 'Ally Color',
	})
	
	espCustomisation:AddColor({
	    text = 'Enemy Color',
	});
	
	function Utility:getESPSection()
	    return {
	        espCustomisation = espCustomisation,
	        espSettings = espSettings,
	        column1 = column1,
	        column2 = column2
	    };
	end;
	
	Utility.setupRenderOverload = function()
	    Utility:renderOverload({
	        espCustomisation = espCustomisation,
	        espSettings = espSettings,
	        column1 = column1,
	        column2 = column2
	    });
	end;
end)();
(function()
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];
	
	local RunService, UserInputService = Services:Get('RunService', 'UserInputService');
	local UserService = game:GetService('UserService');
	
	local maid = Maid.new();
	
	local Circle = Drawing.new('Circle');
	local targetLine = Drawing.new('Line');
	
	Circle.Transparency = 1;
	Circle.Visible = false;
	Circle.Color = Color3.fromRGB(255, 255, 255);
	Circle.Radius = 100;
	Circle.Thickness = 1;
	
	targetLine = Drawing.new('Line');
	targetLine.Visible = true;
	targetLine.Transparency = 1;
	targetLine.Thickness = 1;
	targetLine.Color = Color3.fromRGB(255, 255, 255);
	
	local function Aimbot(ended)
	    if (ended) then
	        maid.aimbot = nil;
	        return;
	    end;
	
	    maid.aimbot = RunService.RenderStepped:Connect(function()
	        if(not library) then
	            maid.aimbot = nil;
	            return;
	        end;
	
	        local Character = Utility:getClosestCharacter()
	        Character = Character and Character.Character;
	        if(not Character) then return end;
	
	        local head = Character:FindFirstChild('Head');
	        local hitPos = head and head.CFrame.Position;
	
	        local Camera = workspace.CurrentCamera;
	        if(not Camera) then return end;
	
	        local aimPart = library.flags.aimPart;
	        if(aimPart == 'Torso') then
	            hitPos = hitPos - Vector3.new(0, 1.5, 0);
	        elseif(aimPart == 'Leg') then
	            hitPos = hitPos - Vector3.new(0, 3, 0);
	        end;
	
	        local hitPosition2D, visible = Camera:WorldToViewportPoint(hitPos);
	        if (not visible) then return end;
	
	        hitPosition2D = Vector2.new(hitPosition2D.X, hitPosition2D.Y);
	
	        local mousePosition = UserInputService:GetMouseLocation();
	        local final = (hitPosition2D - mousePosition) / (_G.test or 10);
	        mousemoverel(final.X, final.Y);
	    end);
	end;
	
	local function updateCircleProp(property)
	    return function(value)
	        if (property == "NumSides" and value == 50) then
	            value = 500;
	        elseif (property == "Filled" and library.flags.circleTransparency == 1) then
	            library.flags.circleTransparency = 0.9;
	            Circle.Transparency = 0.9;
	        end
	        Circle[property] = value;
	    end;
	end;
	
	local function toggleRainbowCircle(toggle)
	    if(not toggle) then
	        maid.toggleRainbowCircle = nil;
	        return;
	    end;
	
	    local circleColor = library.options.circleColor;
	
	    maid.toggleRainbowCircle = RunService.RenderStepped:Connect(function()
	        circleColor:SetColor(library.chromaColor);
	    end);
	end;
	
	local function showCircle(toggle)
	    Circle.Visible = toggle;
	
	    if(not toggle) then
	        maid.updateCirclePosition = nil;
	        return;
	    end;
	
	    maid.updateCirclePosition = RunService.Heartbeat:Connect(function()
	        -- if(library.flags.unlockCircle) then
	            if(Circle) then
	                Circle.Position = UserInputService:GetMouseLocation()
	            end;
	        -- else
	        --     local camera = workspace.CurrentCamera;
	        --     if(not camera) then return end;
	
	        --     local cameraViewPortSize = camera.ViewportSize;
	        --     local x = cameraViewPortSize.X / 2;
	        --     local y = cameraViewPortSize.Y / 2;
	
	        --     Circle.Position = Vector2.new(x, y);
	        -- end;
	    end);
	end;
	
	local Window = library:AddTab('Aimbot');
	local section1 = Window:AddColumn();
	local section2 = Window:AddColumn();
	local aimbotSettings = section1:AddSection('Aimbot Settings');
	local circleSettings = section2:AddSection('Circle Settings');
	local aimbotWhitelist = section1:AddSection('Aimbot Whitelist');
	
	do -- Render gui
	    do -- // Circle Settings
	        circleSettings:AddToggle({
	            text = 'Show Circle',
	            callback = showCircle
	        }):AddColor({
	            color = Color3.fromRGB(255, 0, 0),
	            trans = 1,
	            flag = 'Circle Color',
	            calltrans = updateCircleProp('Transparency'),
	            callback = updateCircleProp('Color')
	        })
	
	        circleSettings:AddToggle({
	            text = 'Rainbow Circle',
	            callback = toggleRainbowCircle
	        })
	
	        circleSettings:AddToggle({
	            text = 'Fill Circle',
	            callback = updateCircleProp('Filled')
	        })
	
	        circleSettings:AddSlider({
	            text = 'Circle Shape',
	            value = 50,
	            min = 4,
	            max = 50,
	            float = 2,
	            callback = updateCircleProp('NumSides')
	        })
	
	        circleSettings:AddSlider({
	            text = 'Circle Thickness',
	            value = 1,
	            max = 50,
	            callback = updateCircleProp('Thickness')
	        });
	    end;
	
	    do -- // Aimbot Settings
	        aimbotSettings:AddBind({
	            text = 'Enable',
	            flag = 'Toggle Aimbot',
	            mode = 'hold',
	            callback = Aimbot
	        })
	
	        aimbotSettings:AddSlider({
	            text = 'Field Of View',
	            flag = 'Aimbot F O V',
	            min = 0,
	            value = 100,
	            max = 800,
	            callback = updateCircleProp('Radius')
	        })
	
	        aimbotSettings:AddList({
	            text = 'Aim Part',
	            values = {'Head', 'Torso', 'Leg'}
	        })
	
	        aimbotSettings:AddToggle({
	            text = 'Use Field Of View',
	            flag = 'use F O V'
	        })
	
	        aimbotSettings:AddToggle({
	            text = 'Visibility Check',
	        })
	
	        aimbotSettings:AddToggle({
	            text = 'Check Team',
	            state = true
	        })
	    end;
	
	    do -- // Aimbot Whitelist
	        local usersInfosByName = {};
	
	        local function addPlayer(userId, isTextBox)
	            if (not isTextBox) then
	                userId = library.flags.aimbotWhitelistPlayers;
	                userId = userId and userId.UserId;
	            end;
	
	            if (not userId) then return print('no user id', userId, isTextBox); end;
	
	            local suc, userInfos = pcall(function()
	                return UserService:GetUserInfosByUserIdsAsync({userId});
	            end);
	
	            if (not suc) then
	                return warn(userInfos);
	            end;
	
	            local userInfo = userInfos[1];
	            if (not userInfo) then return end;
	            library.options.aimbotWhitelistedPlayers:AddValue(userInfo.Username);
	
	            local aimbotWhitelistedPlayers = library.configVars.aimbotWhitelistedPlayers;
	
	            if (not aimbotWhitelistedPlayers) then
	                aimbotWhitelistedPlayers = {};
	                library.configVars.aimbotWhitelistedPlayers = aimbotWhitelistedPlayers;
	            end;
	
	            if (not table.find(aimbotWhitelistedPlayers, userInfo.Id)) then
	                table.insert(aimbotWhitelistedPlayers, userInfo.Id);
	                usersInfosByName[userInfo.Username] = userInfo;
	            end;
	        end;
	
	        local function removePlayer()
	            local userInfo = usersInfosByName[library.flags.aimbotWhitelistedPlayers];
	            if (not userInfo) then return end;
	
	            library.options.aimbotWhitelistedPlayers:RemoveValue(userInfo.Username);
	            local whitelistedPlayers = library.configVars.aimbotWhitelistedPlayers;
	
	            table.remove(whitelistedPlayers, table.find(whitelistedPlayers, userInfo.Id));
	        end;
	
	        library.OnLoad:Connect(function()
	            local whitelistedPlayers = library.configVars.aimbotWhitelistedPlayers or {};
	            local userInfos = UserService:GetUserInfosByUserIdsAsync(whitelistedPlayers);
	
	            for _, userInfo in next, userInfos do
	                library.options.aimbotWhitelistedPlayers:AddValue(userInfo.Username);
	                usersInfosByName[userInfo.Username] = userInfo;
	            end;
	        end);
	
	        aimbotWhitelist:AddDivider('Add Player');
	        aimbotWhitelist:AddList({text = 'Players', flag = 'Aimbot Whitelist Players', playerOnly = true, noSave = true});
	        aimbotWhitelist:AddButton({text = 'Add Player', callback = addPlayer});
	
	        aimbotWhitelist:AddDivider('Remove Player');
	        aimbotWhitelist:AddList({text = 'Whitelisted Players', flag = 'Aimbot Whitelisted Players'});
	        aimbotWhitelist:AddButton({text = 'Remove Player', callback = removePlayer});
	
	        aimbotWhitelist:AddDivider('Advanced Whitelist');
	        aimbotWhitelist:AddBox({text = 'Player UserId', flag = 'Aimbot Whitelist Player Box'});
	        aimbotWhitelist:AddButton({text = 'Add Player By User Id', callback = function() addPlayer(tonumber(library.flags.aimbotWhitelistPlayerBox), true) end});
	    end;
	end;
end)();

printf('[Script] [Universal] Took %.02f to load', tick() - universalLoadAt);

local loadingGameStart = tick();


if (gameName == 'DeepWoken') then (function()

	local library = sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64ff4744ee588da3340de8ca770740cc981'];
	
	local AudioPlayer = sharedRequires['9504c96d496b9bceaf05ec78caa6802370360a6d8d2aa4c967e2b3fad2fe4641'];
	local makeESP = sharedRequires['f097a02efa5d0d2551acb25d09e0e0368b1698a1e0209de8fa7bbff606ee1273'];
	
	local Utility = sharedRequires['9cb70a2854a5995c42972a2e611898569dc41217a6fd4214156e8261045bac0f'];
	local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2f'];
	local AnalyticsAPI = sharedRequires['793f930ecb181c0adaed99b639258b9f609c01a7c4fec27d268ac7a909248f6d'];
	
	local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
	local createBaseESP = sharedRequires['f3d8f3d0569e6d29485406017419e8d35feb6914555d4054e0c78fadf56bd350'];
	
	local EntityESP = sharedRequires['6037201603f3197c312ecccbded8cdd18de7f32b2f881a4231fdf106ef3fc7eb'];
	local ControlModule = sharedRequires['a5aab7a81f59849e7c2e50d0ecd43092d80b0aaa025889a2d0219df4023d863d'];
	local ToastNotif = sharedRequires['4b3575bb802d037e1467e3e0d70cc114df4f2b3172e38a83fe349c17b0b61878'];
	
	local BlockUtils = sharedRequires['4888b6d494562c836ecb9bcf6094407bf4f08cdb14133dcafa68d80825b1c714'];
	local TextLogger = sharedRequires['7384d776692018050bf4de397fa761b48e15a71d1164cf9bf941d3f0c4e20040'];
	local fromHex = sharedRequires['0ba0bfea44d06894aff3f290e6bea37c2898b4ef7a13374f47b1ff040bc352ef'];
	local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];
	local Webhook = sharedRequires['f1f475b5c3b4b14a174922964057fc8810955a390da10f669347f69062faa5ae'];
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	
	local column1, column2 = unpack(library.columns);
	
	local ReplicatedStorage, Players, RunService, CollectionService, Lighting, UserInputService, VirtualInputManager, TeleportService, MemStorageService, TweenService, HttpService, Stats, NetworkClient, GuiService = Services:Get(
		'ReplicatedStorage',
		'Players',
		'RunService',
		'CollectionService',
		'Lighting',
		'UserInputService',
		"VirtualInputManager",
		'TeleportService',
		'MemStorageService',
		'TweenService',
		'HttpService',
		'Stats',
		'NetworkClient',
		'GuiService'
	);
	
	local droppedItemsNames = HttpService:JSONDecode( sharedRequires['c83ce6a4e7b2a57431226bcf42132062a87d15e0887c9580ba22afdca872839f'])
	
	local LocalPlayer = Players.LocalPlayer;
	local playerMouse = LocalPlayer:GetMouse();
	
	local functions = {};
	
	local myRootPart;
	
	local IsA = game.IsA;
	local FindFirstChild = game.FindFirstChild;
	local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA;
	local IsDescendantOf = game.IsDescendantOf;
	
	local blockRemote;
	local unblockRemote;
	
	local dodgeRemote;
	local stopDodgeRemote;
	local rightClickRemote;
	local dialogueRemote;
	local leftClickRemote;
	local dropToolRemote;
	local serverSwimRemote;
	local fallRemote;
	





	local maid = Maid.new();
	
	-- Player is server hopping
	
	if (game.PlaceId == 4111023553) then
		if (MemStorageService:HasItem('DataSlot')) then
			ToastNotif.new({
				text = 'Server hopping...'
			});
	
			ReplicatedStorage.Requests.StartMenu.Start:FireServer(MemStorageService:GetItem('DataSlot'), {
				PrivateTest = false
			});
	
			task.wait(0.3);
	
			ReplicatedStorage.Requests.StartMenu.PickServer:FireServer('none');
			MemStorageService:RemoveItem('DataSlot');
		else
			ToastNotif.new({
				text = 'Script will not run in lobby'
			});
		end;
	
		return task.wait(9e9);
	end;
	
	local remoteEvent = Instance.new('RemoteEvent');
	local onParryRequest = function() warn('onParryRequest not implemented'); end;
	
	local inputClient;
	
	local function logError(msg)
		
	end;
	
	local debugWebhook = Webhook.new('');
	
	do -- // Hooks
		local oldNamecall;
		local oldNewIndex;
	
		local oldFireserver;
		local oldDestroy;
	
		local characterHandler;
		local atmosphere;
	
		task.spawn(function()
			atmosphere = Lighting:WaitForChild('Atmosphere', math.huge);
		end)
	
		local getMouse = ReplicatedStorage.Requests.GetMouse;
		local getCameraToMouse = ReplicatedStorage.Requests.GetCameraToMouse;
	
		local GET_KEY_FUNCTION_HASH = 'dfdcd587cdc8368a9afd04160251e5d69caaa1e6eb19504ddbe0d6243322d035e5b408a2ef283e35dab5be48cdee7f98';
	
		local getKeyFunction = (function(o)
			
	
			for _, v in next, getgc() do
				if (typeof(v) == "function" and not is_synapse_function(v) and islclosure(v) and debug.info(v, 'n') == "gk" and debug.info(v, 's'):find('InputClient') and typeof(getupvalues(v)[1]) == 'table' and (isSynapseV3 or Utility.getFunctionHash(v) == GET_KEY_FUNCTION_HASH)) then
					return v;
				end;
			end;
		end);
	
		local getKey;
	
		if (not LocalPlayer.Character) then
			if (MemStorageService:HasItem('oresFarm') or MemStorageService:HasItem('doWipe')) then
				ReplicatedStorage.Requests.StartMenu.Start:FireServer();
			end;
		end;
	
		-- If we are in a dungeon instance we wait for the game to fully load cause some stuff could be missing
		if (game.PlaceId == 8668476218) then
			repeat
				if (workspace:FindFirstChild('One') and workspace.One:FindFirstChild('TrialOfOne')) then break end;
				print('Waiting for get getkey func');
				getKey = getKeyFunction();
				task.wait(1);
			until getKey;
		end;
	
		local setscriptes = function() end
	
		local function isRemoteInvalid(remote)
			
	
			if (not remote) then return true; end;
			return not IsDescendantOf(remote, game);
		end;
	
		local sent = false;
	
		local function onCharacterAdded(character)
			local humanoid = character:WaitForChild('Humanoid');
			local currentHealth = humanoid.Health;
	
			humanoid.HealthChanged:Connect(function(newHealth)
				if (newHealth < currentHealth) then
					warn('[Player] Took damage!', tick());
				end;
	
				currentHealth = newHealth;
			end);
	
			myRootPart = character:WaitForChild('HumanoidRootPart', math.huge);
			characterHandler = character:WaitForChild('CharacterHandler', math.huge);
			inputClient = characterHandler:WaitForChild('InputClient', math.huge);
	
			if (not getKey) then
				repeat
					print('Waiting for get getkey func');
					getKey = getKeyFunction();
					task.wait(1);
				until getKey;
			end;
	
			if (debugMode) then
				getgenv().myRootPart = myRootPart;
			end;
	
			local oldGetKey = getKey;
	
			local getKey = getKey
	
			local function safeGetKey(...)
				setscriptes(inputClient);
				setthreadidentity(2);
	
				-- Call keyhandler
	
				local remote = getKey(...);
				local hasErrored = false;
	
				if (not remote or not IsDescendantOf(remote, game)) then
					repeat
						task.wait(0.1);
						if (typeof(getupvalue(getKey, 1)) ~= 'table') then
							if (not hasErrored) then
								hasErrored = true;
								logError('failed to get it', typeof(getupvalue(getKey, 1)));
							end;
	
							continue;
						end;
	
						remote = getKey(...);
					until remote and IsDescendantOf(remote, game);
				end;
	
				if (hasErrored) then
					logError('actually got it omg!');
				end;
	
				setthreadidentity(7);
				setscriptes();
	
				print('We returned', remote:GetFullName());
				return remote;
			end;
	
			fallRemote = safeGetKey('FallDamage', 'plum');
			dialogueRemote = safeGetKey('SendDialogue', 'plum');
			blockRemote = safeGetKey('Block', 'plum');
			unblockRemote = safeGetKey('Unblock', 'plum');
			dodgeRemote = safeGetKey('Dodge', 'plum');
			leftClickRemote = safeGetKey('LeftClick', 'plum');
			rightClickRemote = safeGetKey('RightClick', 'plum');
			stopDodgeRemote = safeGetKey('StopDodge', 'plum');
			dropToolRemote = safeGetKey('DropTool', 'plum');
			serverSwimRemote = safeGetKey('ServerSwim','plum');
	
			getgenv().remotes = {
				fallRemote = fallRemote,
				dialogueRemote = dialogueRemote,
				leftClickRemote = leftClickRemote,
				blockRemote = blockRemote,
				dodgeRemote = dodgeRemote,
				rightClickRemote = rightClickRemote,
				stopDodgeRemote = stopDodgeRemote,
				unblockRemote = unblockRemote,
				dropToolRemote = dropToolRemote,
				serverSwimRemote = serverSwimRemote
			};
	
			if ((not blockRemote or not IsDescendantOf(blockRemote, game)) and not sent) then
				sent = true;
				task.spawn(function()
					logError('NO FALLR EMOTE?????')
					print(fallRemote);
				end);
			end;
	
			-- This is an old check and shouldn't fail because of safeGetKey
			if (isRemoteInvalid(fallRemote) or isRemoteInvalid(dialogueRemote) or isRemoteInvalid(blockRemote) or isRemoteInvalid(dodgeRemote) or isRemoteInvalid(leftClickRemote) or isRemoteInvalid(unblockRemote) or isRemoteInvalid(stopDodgeRemote) or isRemoteInvalid(rightClickRemote)) then
				print('failed to grab remotes!');
				error('oh no 0x01');
				task.delay(1, function()
					print('[Anti Cheat Bypass] Failed to grab remotes!');
				end);
			else
				print('[Anti Cheat Bypass] Got remotes!', dodgeRemote);
			end;
		end;
	
		if (LocalPlayer.Character) then
			task.spawn(onCharacterAdded, LocalPlayer.Character);
		end;
	
		LocalPlayer.CharacterAdded:Connect(onCharacterAdded);
	
		local gestureAnims = {};
		local gestures = ReplicatedStorage.Assets.Anims.Gestures;
	
		for _, v in next, gestures:GetChildren() do
			if not v:FindFirstChild('Pack1') and not v:FindFirstChild('MetalPromo') then continue; end;
			gestureAnims[v.Name] = v;
		end;
	
		local function onNamecall(self, ...)
			
	
			if (checkcaller()) then return oldNamecall(self, ...) end;
	
			local method = getnamecallmethod();
	
			if (method == 'FireServer' and IsA(self, "RemoteEvent")) then
				if (self.Name == "AcidCheck" and library.flags.antiAcid) then
					return;
				elseif (self == fallRemote and library.flags.noFallDamage and not checkcaller()) then
					return;
				elseif (self.Name == 'Gesture' and library.flags.giveAnimGamepass) then
					local args = {...};
					local animName = args[1];
	
					if (gestureAnims[animName]) then
						args[1] = 'Lean Back';
	
						task.spawn(function()
							local playerData = Utility:getPlayerData();
							local humanoid = playerData.humanoid;
							local animator = humanoid and humanoid:FindFirstChild('Animator');
							if (not animator) then return end;
	
							local onAnimationPlayed;
							local timeoutTask;
							local loadedAnim = animator:LoadAnimation(gestureAnims[animName]);
	
							onAnimationPlayed = animator.AnimationPlayed:Connect(function(animTrack)
								local animId = animTrack.Animation.AnimationId;
								if (animId ~= 'rbxassetid://6380990210') then return end;
	
								animTrack:Stop();
								loadedAnim:Play();
	
								humanoid:GetPropertyChangedSignal('MoveDirection'):Once(function()
									loadedAnim:Stop();
									onAnimationPlayed:Disconnect();
									task.cancel(timeoutTask);
								end);
							end);
	
							timeoutTask = task.delay(5, function()
								print('TIMED OUT!');
								onAnimationPlayed:Disconnect();
							end);
						end);
	
						return oldNamecall(self, unpack(args));
					end;
				end;
			elseif (method == 'Play' and IsA(self, "Tween") and self.Instance == atmosphere and library.flags.noFog) then
				return;
			end;
	
			return oldNamecall(self, ...);
		end;
	
		local function onNewIndex(self, p, v)
			
	
			if (self == characterHandler and p == 'Parent') then
				warn('[Anti Cheat Bypass] Got a ban attempt from charHandler.Parent = nil');
				return;
			elseif (self == Lighting and p == 'Ambient' and library.flags.fullBright) then
				local value = library.flags.fullBrightValue * 10;
				value += 100;
	
				v = Color3.fromRGB(value, value, value);
			elseif (self == atmosphere and p == 'Density' and library.flags.noFog) then
				v = 0;
			elseif (p == 'BackgroundColor3' and IsA(self, 'TextButton') and typeof(v) == 'Color3') then
				local s, l = debug.info(isSynapseV3 and 2 or 3, 'sl');
				if (l == 25 and s:find('ChoiceClient')) then
					return oldNewIndex(self,"AutoButtonColor", true);
				end;
			end;
	
			return oldNewIndex(self, p, v);
		end;
	
		local function onFireserver(self, ...)
			
	
			if (leftClickRemote and self == leftClickRemote and library.flags.blockInput and not _G.canAttack) then
				return;
			end;
	
			if (blockRemote and self == blockRemote) then
				task.spawn(onParryRequest);
			end;
	
			return oldFireserver(self, ...);
		end;
	
		local function onDestroy(self)
			
	
			if (characterHandler and self == characterHandler) then
				warn('[Anti Cheat Bypass] Got a ban attempt from characterhandler.destroy');
				return;
			end;
	
			return oldDestroy(self);
		end;
	
		warn('[Anti Cheat Bypass] Hooking game functions ...');
	
		oldNamecall = hookmetamethod(game, '__namecall', onNamecall);
		oldNewIndex = hookmetamethod(game, '__newindex', onNewIndex);
	
		oldFireserver = hookfunction(remoteEvent.FireServer, onFireserver);
		oldDestroy = hookfunction(game.Destroy, onDestroy);
	
		local stepped = game.RunService.Stepped;
	
		local function checkName(name)
			if (name and (name:find('InputClient') or name:find('ClientEffects') or name:find('EffectsClient') or name:find('WorldClient'))) then
				return true;
			end;
		end;
	
		local rayParams = RaycastParams.new();
		rayParams.FilterDescendantsInstances = {
			workspace.NPCs,
			workspace.Thrown,
			workspace.SnowSurfaces
		};
	
		local worldToViewportPoint = workspace.CurrentCamera.WorldToViewportPoint;
		local wiewportPointToRay = workspace.CurrentCamera.ViewportPointToRay;
	
		do -- // Silent Aim
			local function onCharacterAdded(character)
				if (not character) then return end;
				local getMouseFunction;
	
				repeat task.wait(); until character.Parent == workspace.Live or not character.Parent;
				if (not character.Parent) then return end;
	
				repeat
					debug.profilebegin('this is slow 2!');
					for _, v in next, getgc() do
						if (typeof(v) == 'function' and not is_synapse_function(v) and islclosure(v) and debug.info(v, 's'):find('InputClient')) then
							local constants = getconstants(v);
	
							if (table.find(constants, 'MouseTracker')) then
								getMouseFunction = v;
								break;
							end;
						end;
					end;
					debug.profileend();
					task.wait(1);
				until getMouseFunction;
	
				print('Got get mouse function!');
	
				getMouse.OnClientInvoke = function()
					setscriptes(inputClient);
					setthreadidentity(2);
	
					local mouse, keys = getMouseFunction();
	
					if (library.flags.silentAim) then
						local target = Utility:getClosestCharacterWithEntityList(workspace.Live:GetChildren(), rayParams, {maxDistance = 500});
						target = target and target.Character;
	
						local cam = workspace.CurrentCamera;
	
						if (target and target.PrimaryPart) then
							local pos = worldToViewportPoint(cam, target.PrimaryPart.Position);
	
							mouse.Hit = target.PrimaryPart.CFrame;
							mouse.Target = target.PrimaryPart;
							mouse.X = pos.X;
							mouse.Y = pos.Y;
							mouse.UnitRay = wiewportPointToRay(cam, pos.X, pos.Y, 1)
							mouse.Hit = target.PrimaryPart.CFrame;
						end;
					end;
	
					return mouse, keys;
				end;
	
				getCameraToMouse.OnClientInvoke = function()
					if (library.flags.silentAim) then
						local target = Utility:getClosestCharacterWithEntityList(workspace.Live:GetChildren(), rayParams, {maxDistance = 500});
						target = target and target.Character;
	
						if (target and target.PrimaryPart) then
							return CFrame.new(workspace.CurrentCamera.CFrame.Position, target.PrimaryPart.Position);
						end;
					end;
	
					return CFrame.new(workspace.CurrentCamera.CFrame.Position, getMouseFunction().Hit.p);
				end;
			end;
	
			LocalPlayer.CharacterAdded:Connect(onCharacterAdded);
			task.spawn(onCharacterAdded, LocalPlayer.Character);
		end;
	
		do -- // Optimize backpack
			local function updateBackpackHook(character)
				if (not character) then return end;
	
				repeat task.wait(); until character.Parent == workspace.Live or not character.Parent;
				if (not character.Parent) then return end;
	
				local wasCalled;
				local renderFunction;
				local backpackClient;
	
				if (isSynapseV3) then return warn('warning: we do not hook renderbackpack on syn v3!'); end;
	
				repeat
					debug.profilebegin('this is slow!');
					for _, v in next, getgc() do
						if (typeof(v) == 'function' and debug.info(v, 'n') == 'render' and debug.info(v, 's'):find('BackpackClient')) then
							local scr = rawget(getfenv(v), 'script');
	
							if (typeof(scr) == 'Instance' and string.find(scr:GetFullName(), 'BackpackGui.BackpackClient')) then
								backpackClient = scr;
								print('we hooked', scr);
								local originalFunc = hookfunction(v, function() wasCalled = true; end);
								if (not renderFunction) then
									renderFunction = originalFunc;
								end;
							end;
						end;
					end;
					debug.profileend();
					task.wait(1);
				until renderFunction;
	
				maid.backpackHookTask = task.spawn(function()
					while task.wait(1 / 20) do
						if (not wasCalled) then continue end;
						wasCalled = false;
						setscriptes(backpackClient);
						setthreadidentity(2);
						-- debug.profilebegin('renderFunction()');
						renderFunction();
						-- debug.profileend();
					end;
				end);
			end;
	
			LocalPlayer.CharacterAdded:Connect(updateBackpackHook);
			task.spawn(updateBackpackHook, LocalPlayer.Character);
		end;
	
		do -- // FPS Boost
			local fpsBoostMaid = Maid.new();
			local hooked = {};
	
			function functions.fpsBoost(t)
				table.clear(hooked);
			end;
	
			
		end;
	
		warn('[Anti Cheat Bypass] game functions hooked and destroyed maid');
	end;
	
	local myChatLogs = {};
	
	local chatLogger = TextLogger.new({
		title = 'Chat Logger',
		preset = 'chatLogger',
		buttons = {'Spectate', 'Copy Username', 'Copy User Id', 'Copy Text', 'Report User'}
	});
	
	local autoParryHelperLogger = TextLogger.new({
		title = 'Auto Parry Helper Logger',
		buttons = {'Copy Animation Id', 'Add To Ignore List', 'Delete Log', 'Clear All'}
	});
	
	local assetsList = {'ModeratorJoin.mp3', 'ModeratorLeft.mp3'};
	local audios = {};
	
	local apiEndpoint = USE_INSECURE_ENDPOINT and 'http://test.aztupscripts.xyz/' or 'https://aztupscripts.xyz/';
	
	for i, v in next, assetsList do
		audios[v] = AudioPlayer.new({
			url = string.format('%s%s', apiEndpoint, v),
			volume = 10,
			forcedAudio = true
		});
	end;
	
	local function loadSound(soundName)
		if ((soundName == 'ModeratorJoin.mp3' or soundName == 'ModeratorLeft.mp3') and not library.flags.modNotifier) then
			return;
		end;
	
		audios[soundName]:Play();
	end;
	
	_G.loadSound = loadSound;
	
	local setCameraSubject;
	local isInDanger;
	
	local moderators = {};
	
	do -- // Mod Logs and chat logger
		-- Y am I hardcoding this?
	
		local apiEndpoint = USE_INSECURE_ENDPOINT and 'http://test.aztupscripts.xyz/api/v1/' or 'https://aztupscripts.xyz/api/v1/';
	
		
	
		if (not suc) then
			if (debugMode) then
				task.spawn(error, err);
			end;
	
			if (not moderatorIds) then
				ToastNotif.new({text = 'Script has failed to setup moderator detection. Error Code 1'});
			else
				ToastNotif.new({text = 'Script has failed to setup moderator detection. Error Code 2.' .. (moderatorIds.StatusCode or -1)});
			end;
	
			moderatorIds = {};
		end;
	
		local function isInGroup(player, groupId)
			local suc, err = pcall(player.IsInGroup, player, groupId);
	
			if(not suc) then return false end;
			return err;
		end;
	
		local function onPlayerChatted(player, message)
			local timeText = DateTime.now():FormatLocalTime('H:mm:ss', 'en-us');
			local playerName = player.Name;
			local playerIngName = player:GetAttribute('CharacterName') or 'N/A';
	
			message = ('[%s] [%s] [%s] %s'):format(timeText, playerName, playerIngName, message);
	
			local textData = chatLogger:AddText({
				text = message,
				player = player
			});
	
			if (player == LocalPlayer) then
				table.insert(myChatLogs, textData);
				functions.streamerMode(library.flags.streamerMode);
			end;
		end;
	
		local function onPlayerAdded(player)
			if (player == LocalPlayer) then return end;
	
			local userId = player.UserId;
	
			if library.flags.modNotifier and (table.find(moderatorIds, tostring(userId)) or isInGroup(player, 5212858)) then
				moderators[player] = true;
	
				loadSound('ModeratorJoin.mp3');
				ToastNotif.new({
					text = ('Moderator Detected [%s]'):format(player.Name),
				});
			end;
		end;
	
		local function onPlayerRemoving(player)
			if (player == LocalPlayer) then return end;
	
			if (moderators[player]) then
				ToastNotif.new({
					text = ('Moderator Left [%s]'):format(player.Name),
				});
	
				loadSound('ModeratorLeft.mp3');
				moderators[player] = nil;
			end;
		end;
	
		library.OnLoad:Connect(function()
			local chatLoggerSize = library.configVars.chatLoggerSize;
			chatLoggerSize = chatLoggerSize and Vector2.new(unpack(chatLoggerSize:split(',')));
	
			local chatLoggerPosition = library.configVars.chatLoggerPosition;
			chatLoggerPosition = chatLoggerPosition and Vector2.new(unpack(chatLoggerPosition:split(',')));
	
			if (chatLoggerSize) then
				chatLogger:SetSize(UDim2.fromOffset(chatLoggerSize.X, chatLoggerSize.Y));
			end;
	
			if (chatLoggerPosition) then
				chatLogger:SetPosition(UDim2.fromOffset(chatLoggerPosition.X, chatLoggerPosition.Y));
			end;
	
			chatLogger:UpdateCanvas();
		end);
	
		library.OnLoad:Connect(function()
			Utility.listenToChildAdded(Players, onPlayerAdded);
			Utility.listenToChildRemoving(Players, onPlayerRemoving);
		end);
	
		chatLogger.OnPlayerChatted:Connect(onPlayerChatted);
	end;
	
	local function formatMobName(mobName)
		if (not mobName:match('%.(.-)%d+')) then return mobName end;
		local allMobLetters = mobName:match('%.(.-)%d+'):gsub('_', ' '):split(' ');
	
		for i, v in next, allMobLetters do
			local partialLetters = v:split('');
			partialLetters[1] = partialLetters[1]:upper();
	
			allMobLetters[i] = table.concat(partialLetters);
		end;
	
		return table.concat(allMobLetters, ' ');
	end;
	
	-- // Entity esp overwrite
	do
		local playersStats = {};
		local seenPerm = {};
	
		local function getPlayerLevel(character)
			if (not character) then return 0; end;
			local attributes = character:GetAttributes();
			local count = 0;
	
			for i,v in next, attributes do
				if (not string.match(i, 'Stat_')) then continue; end;
				count += v;
			end;
	
			return math.clamp(math.floor(count / 315 * 20), 1, 20);
		end;
	
		local function onBackpackAdded(player, backpack)
			task.wait();
	
			local seen = {};
			local seenJSON = {};
			local seenObj = {};
	
			local function onChildAdded(obj)
				local name = obj.Name;
	
				if (not seenObj[obj]) then
					seenObj[obj] = true;
	
					if (not seenPerm[player] and name:lower():find('grasp of eylis') and library.flags.voidWalkerNotifier) then
						seenPerm[player] = true;
						local t = ToastNotif.new({text = string.format('%s is a void walker.', player.Name)});
						local con;
						con = player:GetPropertyChangedSignal('Parent'):Connect(function()
							if (player.Parent) then return end;
							seenPerm[player] = nil;
							ToastNotif.new({text = string.format('[Void Walker Notif] %s left the game.', player.Name), duration = 10});
							t:Destroy();
							con:Disconnect();
						end);
					end;
				end;
	
				local weaponData = obj:FindFirstChild('WeaponData');
				local rarity = obj:FindFirstChild('Rarity');
				local foundWeaponData = weaponData;
	
				if (library.flags.mythicItemNotifier and weaponData and not seenJSON[weaponData] and rarity.Value == 'Mythic' and rarity) then
					xpcall(function()
						weaponData = seenJSON[weaponData] or HttpService:JSONDecode(weaponData.Value);
					end, function()
						weaponData = crypt.base64decode(weaponData.Value);
						weaponData = weaponData:sub(1, #weaponData - 2);
	
						weaponData = HttpService:JSONDecode(weaponData);
					end);
	
					if (foundWeaponData and not weaponData and debugMode) then
						task.spawn(error, 'Invalid Weapon Data');
					end;
	
					if (weaponData) then
						seenJSON[weaponData] = true;
					end;
	
					if (typeof(weaponData) == 'table' and not weaponData.Enchant and not (weaponData.SoulBound or weaponData.Soulbound) and not seen[obj]) then
						seen[obj] = true;
	
						ToastNotif.new({
							text = ('%s has %s'):format(player.Name, obj.Name:match('(.-)%$')),
						});
					end;
				end;
	
				playersStats[player] = {
					level = getPlayerLevel(player.Character)
				};
	
				return function()
					playersStats[player] = {
						level = getPlayerLevel(player.Character)
					};
				end;
			end;
	
			Utility.listenToChildAdded(backpack, onChildAdded, {listenToDestroying = true});
		end;
	
		local function onPlayerAdded(player)
			if (player == LocalPlayer) then return end;
			player.ChildAdded:Connect(function(obj)
				if (not IsA(obj, 'Backpack')) then return end;
	
				onBackpackAdded(player, obj);
			end);
	
			local backpack = player:FindFirstChildWhichIsA('Backpack');
	
			if (backpack) then
				task.spawn(onBackpackAdded, player, backpack);
			end;
		end;
	
		local function onPlayerRemoving(player)
			playersStats[player] = nil;
		end;
	
		library.OnLoad:Connect(function()
			Players.PlayerRemoving:Connect(onPlayerRemoving);
			Utility.listenToChildAdded(Players, onPlayerAdded);
		end);
	
		function EntityESP:Plugin()
			
	
			local playerStats = playersStats[self._player] or {level = 1};
			local shouldSpoofName = library.flags.streamerMode and library.flags.hideEspNames;
	
			if (shouldSpoofName and not self._fakeName) then
				self._fakeName = string.format('%s %s', BrickColor.random().Name, self._id);
			end;
	
			local dangerText = '';
	
			if (library.flags.showDangerTimer) then
				local humanoid = Utility:getPlayerData(self._player).humanoid;
				local expirationTime = humanoid and humanoid:GetAttribute('DangerExpiration')
	
				if (expirationTime and expirationTime ~= -1) then
					dangerText = string.format(' [%ds]', expirationTime - workspace:GetServerTimeNow());
				end;
			end;
	
			return {
				text = string.format('\n[Level: %d]%s', playerStats.level, dangerText),
				playerName = shouldSpoofName and self._fakeName or self._playerName,
			}
		end;
	end;
	
	local markerWorkspace = ReplicatedStorage:WaitForChild('MarkerWorkspace');
	local isLayer2 = ReplicatedStorage:FindFirstChild('LAYER2_DUNGEON');
	
	do -- // Functions
		function functions.speedHack(toggle)
			if (not toggle) then
				maid.speedHack = nil;
				maid.speedHackBv = nil;
	
				return;
			end;
	
			maid.speedHack = RunService.Heartbeat:Connect(function()
				local playerData = Utility:getPlayerData();
				local humanoid, rootPart = playerData.humanoid, playerData.primaryPart;
				if (not humanoid or not rootPart) then return end;
	
				if (library.flags.fly) then
					maid.speedHackBv = nil;
					return;
				end;
	
				maid.speedHackBv = maid.speedHackBv or Instance.new('BodyVelocity');
				maid.speedHackBv.MaxForce = Vector3.new(100000, 0, 100000);
	
				if (not CollectionService:HasTag(maid.speedHackBv, 'AllowedBM')) then
					CollectionService:AddTag(maid.speedHackBv, 'AllowedBM');
				end;
	
				maid.speedHackBv.Parent = not library.flags.fly and rootPart or nil;
				maid.speedHackBv.Velocity = (humanoid.MoveDirection.Magnitude ~= 0 and humanoid.MoveDirection or gethiddenproperty(humanoid, 'WalkDirection')) * library.flags.speedHackValue;
			end);
		end;
	
		function functions.fly(toggle)
			if (not toggle) then
				maid.flyHack = nil;
				maid.flyBv = nil;
	
				return;
			end;
	
			maid.flyBv = Instance.new('BodyVelocity');
			maid.flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
	
			maid.flyHack = RunService.Heartbeat:Connect(function()
				local playerData = Utility:getPlayerData();
				local rootPart, camera = playerData.rootPart, workspace.CurrentCamera;
				if (not rootPart or not camera) then return end;
	
				if (not CollectionService:HasTag(maid.flyBv, 'AllowedBM')) then
					CollectionService:AddTag(maid.flyBv, 'AllowedBM');
				end;
	
				maid.flyBv.Parent = rootPart;
				maid.flyBv.Velocity = camera.CFrame:VectorToWorldSpace(ControlModule:GetMoveVector() * library.flags.flyHackValue);
			end);
		end;
	
		local depthOfField = Lighting:WaitForChild('DepthOfField', math.huge);
		local effectReplicator = require(ReplicatedStorage:WaitForChild('EffectReplicator', math.huge));
	
		local playerBlindFold;
		local lastBlurValue = 0;
	
		function functions.noFog(toggle)
			if (not toggle) then
				maid.noFog = nil;
				depthOfField.Enabled = true;
	
				return;
			end;
	
			depthOfField.Enabled = false;
	
			maid.noFog = RunService.RenderStepped:Connect(function()
				Lighting.FogEnd = 1000000;
	
				local atmosphere = Lighting:FindFirstChild('Atmosphere');
				if (not atmosphere) then return end;
	
				atmosphere.Density = 0;
			end);
		end;
	
		function functions.noBlind(toggle)
			if (not toggle) then
				maid.noBlind = nil;
	
				if (playerBlindFold) then
					playerBlindFold.Parent = LocalPlayer.Backpack;
					playerBlindFold = nil;
				end;
	
				return;
			end;
	
			maid.noBlind = RunService.Heartbeat:Connect(function()
				local backpack = LocalPlayer:FindFirstChild('Backpack');
				if (not backpack) then return end;
	
				local blindFold = backpack:FindFirstChild('Talent:Blinded') or backpack:FindFirstChild('Flaw:Blind');
				if (not blindFold) then return end;
	
				blindFold.Parent = nil;
				playerBlindFold = blindFold;
			end);
		end;
	
		function functions.noBlur(toggle)
			if (not toggle) then
				maid.noBlur = nil;
				Lighting.GenericBlur.Size = lastBlurValue;
				lastBlurValue = 0;
	
				return;
			end;
	
			lastBlurValue = Lighting.GenericBlur.Size;
	
			maid.noBlur = RunService.Heartbeat:Connect(function()
				Lighting.GenericBlur.Size = 0;
			end);
		end;
	
		-- NoClip
		do
			function functions.noClip(toggle)
				if (not toggle) then
					maid.noClip = nil;
	
					local humanoid = Utility:getPlayerData().humanoid;
					if (not humanoid) then return end;
	
					humanoid:ChangeState('Physics');
					task.wait();
					humanoid:ChangeState('RunningNoPhysics');
	
					return;
				end;
	
				maid.noClip = RunService.Stepped:Connect(function()
					debug.profilebegin('noclip');
	
					local myCharacterParts = Utility:getPlayerData().parts;
					local isKnocked = effectReplicator:FindEffect('Knocked');
					local disableNoClipWhenKnocked = library.flags.disableNoClipWhenKnocked;
	
					for _, v in next, myCharacterParts do
						if (disableNoClipWhenKnocked) then
							v.CanCollide = not not isKnocked;
						else
							v.CanCollide = false;
						end;
					end;
					debug.profileend();
				end);
			end;
		end;
	
		function functions.clickDestroy(toggle)
			if (not toggle) then
				maid.clickDestroy = nil;
				return;
			end;
	
			maid.clickDestroy = UserInputService.InputBegan:Connect(function(input, gpe)
				if (input.UserInputType ~= Enum.UserInputType.MouseButton1 or gpe) then return end;
	
				local target = playerMouse.Target;
				if (not target or target:IsA('Terrain')) then return end;
	
				target:Destroy();
			end)
		end;
	
		function functions.serverHop(bypass)
			if(bypass or library:ShowConfirm('Are you sure you want to switch server?')) then
				library:UpdateConfig();
				local dataSlot = LocalPlayer:GetAttribute('DataSlot');
				MemStorageService:SetItem('DataSlot', dataSlot);
	
				BlockUtils:BlockRandomUser();
				TeleportService:Teleport(4111023553);
			end;
		end;
	
		local function tweenTeleport(rootPart, position, noWait)
			local distance = (rootPart.Position - position).Magnitude;
			local tween = TweenService:Create(rootPart, TweenInfo.new(distance / 120, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(position)
			});
	
			tween:Play();
	
			if (not noWait) then
				tween.Completed:Wait();
			end;
	
			return tween;
		end;
	
		do -- // Bots
	
			local function findFortMeritNPC(rootPart)
				for _, v in next, workspace.Live:GetChildren() do
					local mobRoot = v:FindFirstChild('HumanoidRootPart');
					if (not CollectionService:HasTag(v, 'Mob') or not mobRoot or formatMobName(v.Name) ~= 'Hostage Etrean' or (mobRoot.Position - rootPart.Position).Magnitude > 500) then continue end;
	
					return v;
				end;
			end
	
			function functions.fortMeritFarm(toggle)
				if (not toggle) then
					maid.fortMeritBv = nil;
					return
				end;
	
				-- // Check if player is near fort merit boat
				local fortMeritBoatLocation = Vector3.new(-9725.6982421875, 3.9712052345276, 2617.1892089844);
				local fortMeritPrisonLocation = Vector3.new(-9318.13671875, 423.30514526367, 2772.7346191406);
				local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
	
				if (not rootPart) then return warn('[Fort Merit Bot] HumanoidRootPart not found') end;
	
				while true do
					if (not library.flags.fortMeritFarm) then return end;
					if (rootPart.Position - fortMeritBoatLocation).Magnitude > 200 then
						ToastNotif.new({
							text = 'You are too far away from fort merit boat.',
							duration = 5
						});
					else
						break;
					end;
	
					task.wait(1);
				end;
	
				local bodyVelocity = Instance.new('BodyVelocity');
				bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
				bodyVelocity.Velocity = Vector3.new();
	
				maid.fortMeritBv = bodyVelocity;
	
				CollectionService:AddTag(bodyVelocity, 'AllowedBM');
				bodyVelocity.Parent = LocalPlayer.Character:FindFirstChild('Head');
	
				while (library.flags.fortMeritFarm) do
					tweenTeleport(rootPart, fortMeritPrisonLocation);
	
					local fortMeritNPC;
					local startedAt = tick();
	
					repeat
						fortMeritNPC = findFortMeritNPC(rootPart);
						task.wait(0.5);
					until fortMeritNPC or tick() - startedAt > 30 or not library.flags.fortMeritFarm;
	
					if (not fortMeritNPC) then
						task.wait(5);
						continue;
					end;
	
					local mobRoot = fortMeritNPC:FindFirstChild('HumanoidRootPart');
	
					tweenTeleport(rootPart, mobRoot.Position);
					task.wait(0.5);
					LocalPlayer.Character.CharacterHandler.Requests.Carry:FireServer();
	
					startedAt = tick();
	
					repeat
						task.wait();
					until effectReplicator:FindEffect('Carrying') or tick() - startedAt > 2.5;
	
					task.wait(0.5);
					tweenTeleport(rootPart, fortMeritPrisonLocation);
					task.wait(0.5);
					tweenTeleport(rootPart, fortMeritBoatLocation);
					task.wait(0.5);
	
					fireproximityprompt(workspace.NPCs['Etrean Guardmaster'].InteractPrompt);
					task.wait(1);
	
					dialogueRemote:FireServer({exit = true});
					task.wait(1);
	
					for _, v in next, workspace.Thrown:GetChildren() do
						if (not CollectionService:HasTag(v, 'ClosedChest')) then continue end;
						local chestRoot = v.PrimaryPart;
	
						if (chestRoot and (chestRoot.Position - rootPart.Position).Magnitude < 25) then
							local interact = v:FindFirstChild('InteractPrompt');
							if (interact) then
								fireproximityprompt(interact);
								task.wait(5);
							end;
						end;
					end;
				end;
			end;
	
			local ORE_FARM_MAX_RANGE = 500;
			local PLAYER_DIST_CHECK_MAX_RANGE = 200;
			local MOB_DIST_CHECK_MAX_RANGE = 100;
	
			local wantedOres = {'Astruline', 'Umbrite'};
			local forceKick = false;
	
			function functions.oresFarm(toggle)
				if (not toggle) then return end;
				MemStorageService:SetItem('oresFarm', 'true');
	
				if (not library.configVars.oresFarmPosition) then
					ToastNotif.new({text = 'Please set your position first!'});
					library.options.oresFarm:SetState(false);
					return;
				end;
	
				local notif = Webhook.new(library.flags.oresFarmWebhookNotifier);
	
				while (library.flags.oresFarm) do
					task.wait();
	
					local originalPosition = Vector3.new(unpack(library.configVars.oresFarmPosition:split(',')));
	
					if (not LocalPlayer.Character) then
						print('Attempt to spawn in');
						firesignal(UserInputService.InputBegan, {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.Unknown});
						task.wait(1);
						continue;
					end;
	
					local rootPart = LocalPlayer.Character:WaitForChild('HumanoidRootPart', 2);
					local humanoid = LocalPlayer.Character:WaitForChild('Humanoid', 2);
					local backpack = LocalPlayer:WaitForChild('Backpack', 2);
	
					if (not rootPart or not humanoid or not backpack) then
						-- Abort the bot
						warn('no root part / humanoid / backpack');
						continue;
					end;
	
					-- Wait for game to spawn in character
					repeat task.wait(); until CollectionService:HasTag(backpack, 'Loaded');
	
					if ((rootPart.Position - originalPosition).Magnitude > 500) then
						forceKick = true;
						LocalPlayer:Kick();
						GuiService:ClearError();
						ToastNotif.new({text = '[Ores Farm] You were too far from your last pos please click on the set location btn to reset your position and then rejoin the server.'});
						return;
					end;
	
					print('player spawned in!');
	
					local function isEntityNearby()
						if (Utility:countTable(moderators) > 0) then return true end;
						for _, entity in next, workspace.Live:GetChildren() do
							local root = entity:FindFirstChild('HumanoidRootPart');
							local isMob = CollectionService:HasTag(entity, 'Mob');
							if (not root or root == rootPart) then continue end;
							if ((root.Position - rootPart.Position).Magnitude <= (isMob and MOB_DIST_CHECK_MAX_RANGE or PLAYER_DIST_CHECK_MAX_RANGE)) then
								ToastNotif.new({text = string.format('too close %s %s', entity.Name, (root.Position - rootPart.Position).Magnitude)});
								return true;
							end;
						end;
	
						return false;
					end;
	
					task.spawn(function()
						while true do
							if (isEntityNearby()) then
								print('someone is nearby!!!');
								repeat task.wait(); until not effectReplicator:FindEffect('Danger');
								LocalPlayer:Kick('');
								functions.serverHop(true);
	
								return;
							elseif (not NetworkClient:FindFirstChild('ClientReplicator') and not forceKick) then
								functions.serverHop(true);
							end;
	
							task.wait();
						end;
					end);
	
					-- run player checks ere
	
					if ((rootPart.Position - originalPosition).Magnitude > 10) then
						tweenTeleport(rootPart, originalPosition);
						task.wait(5);
					end;
	
					local ores = {};
					local myPosition = rootPart.Position;
	
					local function onIngredientAdded(obj)
						if (table.find(wantedOres, obj.Name) and (obj.Position - myPosition).Magnitude <= ORE_FARM_MAX_RANGE) then
							table.insert(ores, obj);
						end;
					end;
	
					Utility.listenToChildAdded(workspace.Ingredients, onIngredientAdded);
					local maxCarryLoad = false;
	
					for _, ore in next, ores do
						if((humanoid:GetAttribute('CarryMax') or 100) * 1.2 <= humanoid:GetAttribute('CarryLoad')) then maxCarryLoad = true; break end;
						if (not library.flags.oresFarm) then break; end;
						tweenTeleport(rootPart, ore.Position);
						local prompt = ore:WaitForChild('InteractPrompt', 5);
						if (not prompt) then continue end;
						task.wait(0.2);
	
						local miningStartedAt = tick();
						fireproximityprompt(prompt);
						repeat task.wait(); until not ore.Parent or tick() - miningStartedAt > 10;
					end;
	
					if (maxCarryLoad) then
						ToastNotif.new({text = 'Max carry load!'});
						notif:Send(string.format('@everyone | %s | You are on max carry load', LocalPlayer.Name));
						task.wait(5);
					end;
	
					tweenTeleport(rootPart, originalPosition);
					task.wait(1);
	
					local astruline = LocalPlayer.Backpack:FindFirstChild('Astruline');
	
					if (astruline) then
						dropToolRemote:FireServer(astruline, true);
					end;
	
					task.wait(1);
	
					repeat task.wait(); until not effectReplicator:FindEffect('Danger');
					LocalPlayer:Kick('');
					functions.serverHop(true);
	
					break;
				end;
			end;
	
			function functions.setOresFarmPosition()
				local rootPart = Utility:getPlayerData().rootPart;
				if (not rootPart) then return end;
	
				library.configVars.oresFarmPosition = tostring(rootPart.Position);
				ToastNotif.new({text = 'Location set!'});
			end;
	
			local function isCharacterLoaded()
				local backpack = LocalPlayer:FindFirstChild('Backpack');
				if (not backpack) then return false end;
	
				return CollectionService:HasTag(backpack, 'Loaded');
			end;
	
			do -- Temp Farms
				do -- Echoes Farm
					local Requests = ReplicatedStorage:WaitForChild("Requests");
					local modifiers = require(ReplicatedStorage.Info.MetaData).Modifiers;
					local weaponData = require(ReplicatedStorage.Info.WeaponData).weapon_classes;
	
					local craft = Requests.Craft;
					local finishCreation = Requests.CharacterCreator.FinishCreation;
					local pickSpawn = Requests.CharacterCreator.PickSpawn;
					local modifyRemote = Requests.MetaModifier;
					local updateMeta = Requests.UpdateMeta;
					local increaseAttribute = Requests.IncreaseAttribute;
	
					local inDepths = game.PlaceId == 5735553160;
	
					local function startEchoFarm()
						if (not MemStorageService:HasItem('serverHop')) then
							pickSpawn:InvokeServer("Etris");
	
							for i in next, modifiers do --Enables all modifiers
								local waiting = true;
	
								local con;
								con = updateMeta.OnClientEvent:Connect(function(tab)
									if not string.find(tab.Modifiers,i) then return; end
									print('go');
									waiting = false;
								end)
	
								modifyRemote:FireServer(i);
	
								repeat
									task.wait(0.1);
									if not waiting then break; end;
									modifyRemote:FireServer(i);
								until not waiting;
								con:Disconnect();
							end
	
							finishCreation:InvokeServer();
						else
							MemStorageService:RemoveItem('serverHop');
						end;
	
						repeat task.wait(); until LocalPlayer.Character and (LocalPlayer.Character.Parent == workspace.Live);
	
						local rootPart = LocalPlayer.Character:WaitForChild('HumanoidRootPart', 10);
						local backpack = LocalPlayer:WaitForChild('Backpack', 10);
	
						repeat task.wait(); until CollectionService:HasTag(backpack, 'Loaded'); --Wait for us to spawn in
	
						--Make sure that a browncap and dentifilo is near and Y: 401 is below it
	
						--Toggle Noclip
						library.options.noClip:SetState(true);
						--Toggly Fly
						library.options.fly:SetState(true);
	
						local function pickupIngredients()
							local closests = {};
							local closestsParts = {};
	
							if (getgenv().breakPickup) then
								return false;
							end;
	
							for _, ingredient in next, workspace.Ingredients:GetChildren() do
								-- Make sure ingredient name is valid
								if (ingredient.Name == 'Dentifilo' or ingredient.Name == 'Browncap') then
									local interactPrompt = ingredient:FindFirstChild('InteractPrompt');
									if (not interactPrompt) then continue end;
	
									if (not closests[ingredient.Name]) then
										closests[ingredient.Name] = math.huge;
									end;
	
									local distance = (myRootPart.Position - ingredient.Position).Magnitude;
	
									if (distance < closests[ingredient.Name] and distance <= 250) then
										closests[ingredient.Name] = distance;
										closestsParts[ingredient.Name] = ingredient;
									end;
								end;
							end;
	
							-- Find closest ingredient and returns them
	
							if (not closestsParts.Dentifilo or not closestsParts.Browncap) then return false end;
	
							for _, ingredient in next, closestsParts do
								local ingPos = ingredient.Position;
	
								LocalPlayer.Character:PivotTo(CFrame.new(rootPart.Position.X,401.5,rootPart.Position.Z)); --Teleporting them below the Inn
								tweenTeleport(myRootPart, Vector3.new(ingPos.X, 401.5, ingPos.Z));
	
								-- Pickup the ingredient
	
								local startedAt = tick();
								local interactPrompt = ingredient:FindFirstChild('InteractPrompt');
	
								repeat
									if (not interactPrompt) then return false end;
									fireproximityprompt(interactPrompt);
									task.wait(1);
								until not ingredient.Parent or tick() - startedAt > 5;
	
								if (tick() - startedAt > 5) then
									-- We couldn't pick up the ingredient
									return false;
								end;
							end;
	
							return true;
						end;
	
						if (not pickupIngredients()) then
							-- If there is no mushroom then we wait to get new mushroom
	
							local startedAt = tick();
	
							repeat
								print('no browncap/dentifilo :(');
								task.wait(1);
							until pickupIngredients() or tick() - startedAt > 20;
	
							if (tick() - startedAt > 20) then
								MemStorageService:SetItem('serverHop', 'true');
								functions.serverHop(true);
								return;
							end;
						end;
	
						--Tween to the campfire
						tweenTeleport(myRootPart, Vector3.new(2509.039, 401.5, -5562.163));
	
						repeat
							task.wait(0.1);
						until craft:InvokeServer({Dentifilo = true, Browncap = true}); --Craft the Mushroom Soup
	
						originalFunctions.fireServer(fallRemote, math.random(900,1000),false);
						MemStorageService:SetItem('doWipe', 'true');
					end;
	
					local function fireChoices(choices, responseChoices)
						--There might be a debounce on these gotta test later
						for i, v in next, choices do -- Run Through Choices
							local completed = false;
	
							local con;
							con = dialogueRemote.OnClientEvent:Connect(function(tab)
								local text = tab.text;
	
								if (text ~= responseChoices[i] and not tab.exit) then
									-- Invalid data?
									return;
								end;
	
								completed = true;
							end);
	
							local waitTime = 0.25;
	
							repeat
								dialogueRemote:FireServer(v);
								task.wait(waitTime);
								waitTime += math.min(waitTime + 0.25, 1); -- Increase wait time for each failed attempts incase of a debounce or idk
							until completed;
	
							con:Disconnect();
						end;
					end;
	
					local function doWipe()
						local choices = {{["choice"] = "What do you mean?"}, {["choice"] = "But I don't want to go."}, {["choice"] = "Isn't there something we can do?"}, {["choice"] = "What is all this?"}, {["choice"] = "So, is this really the end?"}, {["exit"] = true}};
						local responseChoices = {
							'You know what I mean. You\'re me, after all. This is where we as a person end.',
							'[i]*Sigh.*[/i] There was so much left for us to do, wasn\'t there?',
	
							'[i]*You see your face racked with a pained expression.*[/i] No. You know there isn\'t.',
							'This... All of this around us... Is all our mind is able to make sense of right now. It\'s just holding on to all it can still remember.',
							'Yeah, I suppose it is. Come speak to me again when you want to... Well... You know.',
						};
	
						repeat task.wait(); until fallRemote and isCharacterLoaded(); --Wait for us to spawn in
						LocalPlayer.Character:PivotTo(myRootPart.CFrame * CFrame.new(0, -100, 0));
	
						--Remove ForceField
						local myChar = LocalPlayer.Character;
	
						library.options.noKillBricks:SetState(false);
	
						print('wiating');
						repeat
							local pos = LocalPlayer.Character:GetPivot().Position;
							LocalPlayer.Character:PivotTo(CFrame.new(pos.X, -2871, pos.Z));
							task.wait(0.5);
						until LocalPlayer.Character ~= myChar and LocalPlayer.Character ~= nil;
						print('ok');
	
						repeat task.wait(); until isCharacterLoaded(); --Wait for us to spawn in
						task.wait(2); -- 2 seem to be the fastest we can
	
						local dialogueUI = LocalPlayer.PlayerGui:WaitForChild('DialogueGui'):WaitForChild('DialogueFrame');
	
						local npcSelf = workspace:WaitForChild('NPCs'):WaitForChild('Self');
						local selfInteract = npcSelf.InteractPrompt;
	
						local npcSelfCF = npcSelf:GetPivot() * CFrame.new(0, -5, 0);
						local lastProximityPromptFire = 0;
						local stages = {};
	
						local function talkToSelf()
							repeat
								LocalPlayer.Character:PivotTo(npcSelfCF); --Teleport under Self
								if (tick() - lastProximityPromptFire > 0.5) then
									fireproximityprompt(selfInteract);
									lastProximityPromptFire = tick();
								end;
								task.wait();
							until dialogueUI.Visible;
						end;
	
						task.delay(60, function()
							if (not LocalPlayer.Character or not LocalPlayer.Character.Parent) then return end;
							debugWebhook:Send('Took more than 60 seconds ' .. table.concat(stages, ', '));
	
							while true do
								debugWebhook:Send(LocalPlayer.Character and LocalPlayer.Character.Parent and 'char found' or 'no char');
								task.wait(10);
							end;
						end);
	
						dialogueRemote.OnClientEvent:Connect(function(tab)
							if (not tab.text) then return; end;
							table.insert(stages,tab.text..'\n');
						end)
	
						-- Talk to self 1st part
						talkToSelf();
						fireChoices(choices, responseChoices);
	
						-- Talk to self 2nd part
						task.spawn(function()
							while true do
								talkToSelf();
								fireChoices({
									{choice = '[The End]'},
								}, {});
							end;
						end);
	
						while true do
							ReplicatedStorage.Requests.GetScore:FireServer();
							task.wait(0.1);
						end;
					end;
	
					function functions.echoFarm(t)
						if (not t) then return end;
						-- Don't enable echo farm in to1
						if (game.PlaceId == 8668476218) then return end;
	
						repeat
							ReplicatedStorage.Requests.StartMenu.Start:FireServer();
							task.wait(1);
						until LocalPlayer.Character;
	
						if (inDepths) then
							if (not MemStorageService:HasItem('doWipe')) then
								return ToastNotif.new({text = 'Echo farm is turned on but echo farm did not pass first stage so it wont wipe you.'});
							end;
	
							MemStorageService:RemoveItem('doWipe')
							doWipe();
						else
							if (not MemStorageService:HasItem('serverHop')) then
								local ran = false;
								task.delay(5, function()
									if (ran) then return end;
									ToastNotif.new({text = 'You must be in character creation menu to use the echo farm'});
								end);
	
								repeat task.wait(); until LocalPlayer.PlayerGui:FindFirstChild('CharacterCreator');
								ran = true;
							end;
	
							startEchoFarm();
						end;
					end;
	
					local animalKingFarmRan = false;
	
					function functions.animalKingFarm(t)
						if (not t) then return end;
	
						repeat
							ReplicatedStorage.Requests.StartMenu.Start:FireServer();
							task.wait(1);
						until LocalPlayer.Character;
	
						if (inDepths) then
							if (not MemStorageService:HasItem('doWipe')) then return end;
							MemStorageService:RemoveItem('doWipe')
							doWipe();
							return;
						end;
	
						if (animalKingFarmRan) then return; end;
						animalKingFarmRan = true;
	
						-- Toggle noclip
						library.options.noClip:SetState(true);
						--Toggly Fly
						library.options.fly:SetState(true);
						-- Disable echof arm
						library.options.echoFarm:SetState(false);
	
						-- Select minityrsa and spawn
						if (game.PlaceId ~= 8668476218) then
							repeat task.wait(); until LocalPlayer.PlayerGui:FindFirstChild('CharacterCreator');
	
							local ran = false;
							task.delay(5, function()
								if (ran) then return end;
								ToastNotif.new({text = 'You must be in character creation menu to use the animal king farm'});
							end);
	
							repeat task.wait(); until LocalPlayer.PlayerGui:FindFirstChild('CharacterCreator');
							ran = true;
	
							if (not pickSpawn:InvokeServer('Minityrsa')) then
								ToastNotif.new({text = 'You must have lone warrior origin to use the animal king farm'});
								return;
							end;
	
							finishCreation:InvokeServer();
							return;
						end;
	
						repeat task.wait(); until isCharacterLoaded();
	
						local startPosition = myRootPart.Position;
						local dialogueUI = LocalPlayer.PlayerGui:WaitForChild('DialogueGui'):WaitForChild('DialogueFrame');
	
						local oneModel = workspace:WaitForChild('One');
						local startTrialOfOne = oneModel.OneTrigger;
						local campfire = oneModel.Campfire.CampfirePart;
	
						-- Do first stage of trial of one (orbs)
						tweenTeleport(myRootPart, startTrialOfOne.Position);
						repeat task.wait() until dialogueUI.Visible;
						tweenTeleport(myRootPart, startPosition);
	
						-- Wait until campfire goes back down
						repeat task.wait(); until campfire.Position.Y <= 1178;
	
						-- Tp to campfire
						tweenTeleport(myRootPart, Vector3.new(campfire.Position.X, 1140, campfire.Position.Z));
	
						-- Spend points
						local weapon = LocalPlayer.Backpack:FindFirstChild('Weapon');
						local weaponType = weaponData[weapon:GetAttribute('DisplayName')] or weapon:GetAttribute('DisplayName');
	
						if (weaponType == 'Gun') then
							weaponType = 'WeaponLight'
						else
							weaponType = 'Weapon' .. weaponType:match('(.-)Weapon');
						end;
	
						local sharkoController;
						repeat
							task.wait(0.5);
							increaseAttribute:InvokeServer(weaponType, true, true);
							sharkoController = workspace.Live:FindFirstChild('MegalodauntController', true)
						until sharkoController;
						-- Spend attribute points until sharko spawns
	
						local sharko = sharkoController.Parent;
						local sharkoTarget = sharko:WaitForChild('Target');
	
						local startedAt = tick();
	
						-- Wait until sharko target is us or timeout reached
						repeat
							task.wait();
						until sharkoTarget.Value == LocalPlayer.Character or tick() - startedAt > 20;
	
						-- If timeout reached then we have animal king otherwsie we wipe
						if (tick() - startedAt > 20 or not sharkoTarget.Value) then
							print('OMG LE ANIMAL KING');
							logError(string.format('%s someone got animal king?', LocalPlayer.Name));
							Webhook.new(library.flags.animalKingWebhookNotifier):Send(string.format('@everyone | %s got animal king', LocalPlayer.Name));
							repeat task.wait(); until not isInDanger();
							LocalPlayer:Kick('Animal King!');
						else
							MemStorageService:SetItem('doWipe', 'true');
							originalFunctions.fireServer(fallRemote, math.random(900,1000),false);
						end;
					end;
				end;
			end;
		end;
	
		function functions.charismaFarm(toggle)
			if (not toggle) then
				maid.charismaFarm = nil;
				return;
			end;
	
			local lastFarmRanAt = 0;
	
			maid.charismaFarm = RunService.Heartbeat:Connect(function()
				if (tick() - lastFarmRanAt < 1) then return end;
	
				lastFarmRanAt = tick();
	
				local tool = LocalPlayer.Backpack:FindFirstChild('How to Make Friends') or LocalPlayer.Character:FindFirstChild('How to Make Friends');
				if (not tool) then
					return ToastNotif.new({
						text = 'You need to have How to Make Friends in your inventory for the farm to work',
						duration = 1
					});
				end;
	
				tool.Parent = LocalPlayer.Character;
	
				tool:Activate();
	
				local singlePrompt = LocalPlayer.PlayerGui:FindFirstChild('SimplePrompt');
				if (not singlePrompt) then return end;
	
				local chatText = singlePrompt.Prompt.Text:match('\'(.+)\'');
				if (not chatText) then return end;
	
				warn('should say', chatText);
	
				library.dummyBox:SetTextFromInput(chatText);
				Players:Chat(chatText);
			end);
		end;
	
		function functions.intelligenceFarm(toggle)
			if (not toggle) then
				maid.intelligenceFarm = nil;
				return;
			end;
	
			local lastFarmRanAt = 0;
	
			maid.intelligenceFarm = RunService.Heartbeat:Connect(function()
				if (tick() - lastFarmRanAt < 1) then return end;
				lastFarmRanAt = tick();
	
				local tool = LocalPlayer.Backpack:FindFirstChild('Math Textbook') or LocalPlayer.Character:FindFirstChild('Math Textbook');
				if (not tool) then
					return ToastNotif.new({
						text = 'You need to have Math Textbook in your inventory for the farm to work',
						duration = 1
					});
				end;
	
				tool.Parent = LocalPlayer.Character;
	
				tool:Activate();
	
				local choicePrompt = LocalPlayer.PlayerGui:FindFirstChild('ChoicePrompt');
				if (not choicePrompt) then return end;
	
				local question = choicePrompt.ChoiceFrame.DescSheet.Desc.Text:gsub('[^%w%p%s]', '');
				local operationType = question:match('%d+ (.-) ');
	
				local number1 = question:match('What is (.-) ');
				local number2 = question:match(operationType .. ' (.-)%?');
	
				number2 = number2:gsub('by', '');
				number1 = tonumber(number1);
				number2 = tonumber(number2);
	
				local result = 0;
	
				if (operationType == 'minus') then
					result = number1 - number2;
				elseif (operationType == 'divided') then
					result = number1 / number2;
				elseif (operationType == 'plus') then
					result = number1 + number2;
				elseif (operationType == 'times') then
					result = number1 * number2;
				end;
	
				for i, v in next, choicePrompt.ChoiceFrame.Options:GetChildren() do
					if (not v:IsA('TextButton')) then continue end;
	
					print(math.abs(tonumber(v.Name)-result));
					if (math.abs(tonumber(v.Name)-result)<=1) then
						choicePrompt.Choice:FireServer(v.Name);
						break;
					end;
				end;
			end);
		end;
	
		function functions.fishFarm(toggle)
			if (not toggle) then
				maid.fishFarmAutoClicker = nil;
				maid.fishFarmAutoPull = nil;
				return;
			end;
	
			if (not LocalPlayer.Character or not LocalPlayer:FindFirstChildWhichIsA('Backpack')) then
				return ToastNotif.new({
					text = 'Error trying to run fish farm, please try again.',
					duration = 1
				});
			end;
	
			local fishingRod = LocalPlayer.Backpack:FindFirstChild('Fishing Rod') or LocalPlayer.Character:FindFirstChild('Fishing Rod');
			local rootPart = LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
			local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid');
	
			if (not fishingRod or not rootPart) then
				ToastNotif.new({
					text = 'You need a fishing rod to use the fish farm.',
					duration = 5,
				});
				return;
			end;
	
			fishingRod.Parent = LocalPlayer.Character;
			task.wait(1);
	
			local reelLongSong = fishingRod.Handle.FishingLoop;
			local fishingRodRemote = fishingRod.FishinScript.RemoteEvent;
	
			local lastPullDirection;
	
			local function pullFishingRod(direction)
				if (direction == lastPullDirection) then return warn('same direction, we dont change') end;
				print('pulling', direction);
	
				if (lastPullDirection) then
					fishingRodRemote:FireServer(lastPullDirection, false);
				end;
	
				fishingRodRemote:FireServer(direction, true);
				lastPullDirection = direction;
			end;
	
			local function attachBait()
				local fishFarmBaits = library.flags.fishFarmBait:split(',');
				local bait = fishingRod.Bait.Value;
				local canBait = fishingRod.CanBait.Value;
	
				for i, v in next, fishFarmBaits do
					for i2, v2 in next, LocalPlayer.Backpack:GetChildren() do
						if (v:lower() == v2.Name:lower() and CollectionService:HasTag(v2, 'Edible') and canBait and not bait) then
							fishingRod.AddBait:FireServer(v2);
	
							local lastAttachBaitAt = tick();
	
							repeat
								task.wait();
							until fishingRod.Bait.Value or tick() - lastAttachBaitAt > 5;
	
							task.wait(0.5);
	
							return;
						end;
					end;
				end;
			end;
	
			maid.fishFarmAutoPull = humanoid.AnimationPlayed:Connect(function(anim)
				local animationId = anim.Animation.AnimationId:match('%d+');
	
				if (animationId == '6415331110') then
					-- Pull left
					pullFishingRod('a');
				elseif (animationId == '6415331617') then
					-- Pull right
					pullFishingRod('d');
				elseif (animationId == '6415330705') then
					-- Pull back
					pullFishingRod('s');
				end;
			end);
	
			maid.fishFarmAutoClicker = reelLongSong:GetPropertyChangedSignal('Playing'):Connect(function()
				if (reelLongSong.Playing) then
					task.wait(0.2);
	
					while (reelLongSong.Playing) do
						fishingRod:Activate();
						task.wait(1 / 10);
						-- Clicking 10 time per second
					end;
				end;
			end);
	
			local fishingStartedAt = tick();
	
			task.spawn(function()
				while (library.flags.fishFarm) do
					local hook = fishingRod.Handle.Rod.bobby.hook;
	
					if ((rootPart.Position - hook.Position).Magnitude < 10) then
						-- If the hook is too close it mean the player is not fishing so we start fishing again.
	
						attachBait();
	
	
						fishingRod:Activate();
						task.wait(library.flags.fishFarmHoldTime);
						fishingRod:Deactivate();
						task.wait(1);
						fishingStartedAt = tick();
					elseif (tick() - fishingStartedAt >= 120) then
						-- If player is fishing for more than 120 second without any fish, we stop fishing and retry.
						fishingRod.Parent = LocalPlayer.Backpack;
						task.wait(1);
						fishingRod.Parent = LocalPlayer.Character;
					end;
	
					task.wait(0.1);
				end;
			end);
		end;
	
		function functions.autoLoot(toggle)
			if (not toggle) then
				maid.autoLoot = nil;
				return;
			end;
	
			local colors = {
				['875252'] = 'Rare',
				['a38e64'] = 'Uncommon',
				['40504c'] = 'Common',
				['9057ac'] = 'Epic',
				['e2ffe6'] = 'Enchant',
				['46ccaf'] = 'Legendary'
			};
	
			local icons = {
				[tostring(Vector2.new(0, 0))] = 'Ring',
				[tostring(Vector2.new(20, 0))] = 'Gloves',
				[tostring(Vector2.new(40, 0))] = 'Shoes',
				[tostring(Vector2.new(60, 0))] = 'Helmets',
				[tostring(Vector2.new(80, 0))] = 'Glasses',
				[tostring(Vector2.new(100, 0))] = 'Earrings',
				[tostring(Vector2.new(120, 0))] = 'Schematics',
				[tostring(Vector2.new(140, 0))] = 'Weapons',
				[tostring(Vector2.new(160, 0))] = 'Daggers',
				[tostring(Vector2.new(180, 0))] = 'Necklace',
				[tostring(Vector2.new(200, 0))] = 'Trinkets'
			};
	
			local weaponAttributes = {
				'HP',
				'ETH',
				'RES',
				'Posture',
				'SAN',
				'Monster Armor',
				'PHY Armor',
				'Monster DMG',
				'ELM Armor'
			}
	
			local starIcon = fromHex('E29885');
			local fired = {};
	
			local function firstToUpper(str) --Totally not somewhat ripped from devforum cuz lazy
				return str:gsub("^%l", string.upper)
			end
	
			local function checkItemAttributes(weaponType,itemAttributes) --This function could be more efficient if i didn't check the ones at 0 but whatevs
				local foundMatch = false;
				if library.flags['autoLootWhitelistMatchAll'..weaponType] then --All things have to match gte for it to return true
					local attributeAmount = #weaponAttributes;
					local timesMatched = 0;
	
					for _,statName in next, weaponAttributes do
						statName = firstToUpper(toCamelCase(statName));
	
						local weaponTypeValue = library.flags['autoLootWhitelist'..statName..weaponType];
						local itemValue = itemAttributes[statName] or 0;
	
						if weaponTypeValue and itemValue and itemValue >= weaponTypeValue then
							timesMatched = timesMatched+1;
						end
	
					end
					foundMatch = attributeAmount == timesMatched;
				else --Only one thing has to match to return true
	
					for statName, itemValue in next, itemAttributes do --This check is annoying because if its greater than 0 but probably nobody gonna want a 0 stat thing so...
						local weaponTypeValue = library.flags['autoLootWhitelist'..statName..weaponType]; --This is incredibly demonic at this point... autoLootWhitelistHPWeapon
	
						if weaponTypeValue and itemValue >= weaponTypeValue and weaponTypeValue ~= 0 then
							foundMatch = true;
							break;
						end
					end
				end
	
				return foundMatch;
			end
	
			local function canGrabItem(starAmount, weaponRarity, weaponType, itemAttributes, itemName)
				if (weaponRarity == 'Enchant' and library.flags.alwaysPickupEnchant) then
					return true;
				end;
				if (itemName == "Kyrsan Medallion" and library.flags.alwaysPickupMedallion) then
					return;
				end
	
				if (library.flags['autoLootFilter' .. weaponType]) then
					local priority = library.flags['autoLootWhitelistPriorities' .. weaponType];
					local starsFlag = library.flags['autoLootWhitelistStars' .. weaponType];
	
					if (priority == 'Stars' and starsFlag[starAmount .. ' Stars']) then
						return true;
					elseif priority == 'Stats' and library.flags['autoLootWhitelistUseAttributes' .. weaponType] and checkItemAttributes(weaponType,itemAttributes) then
						return true;
					end
	
					local hasOneStarSelected = Utility.find(starsFlag, function(v) return v == true end);
	
					if (not library.flags['autoLootWhitelistRarities' .. weaponType][weaponRarity]) then
						return false;
					end;
	
					if (not starsFlag[starAmount .. ' Stars'] and hasOneStarSelected) then
						return false;
					end;
	
					if (library.flags['autoLootWhitelistUseAttributes' .. weaponType] and not checkItemAttributes(weaponType,itemAttributes)) then
						return false;
					end
	
					return true;
				end;
	
				return true;
			end;
	
			_G.canGrabItem = canGrabItem;
	
			local lastRan = 0;
	
			maid.autoLoot = RunService.Heartbeat:Connect(function()
				local choicePrompt = LocalPlayer.PlayerGui:FindFirstChild('ChoicePrompt');
	
				-- Note to myself the description check could break if game add translation in the future.
				if (not choicePrompt or choicePrompt.ChoiceFrame.Title.Text ~= 'Treasure Chest') then return end;
	
				local remote = choicePrompt:FindFirstChild('Choice');
				if (not remote or tick() - lastRan <= 0.1) then return end;
	
				for _, v in next, choicePrompt.ChoiceFrame.Options:GetChildren() do
					if (not IsA(v, 'TextButton') or v.Name == 'Nothing') then continue end;
	
					local canClick = v.AutoButtonColor;
					if (not canClick) then print('NOOOON'); continue end;
	
					local weaponRarity = colors[v.BackgroundColor3:ToHex()];
					local weaponType = v.Title.Text:find('Ring') and 'Ring' or icons[tostring(v.Icon.ImageRectOffset)];
	
					local splitText = v.Text:split(starIcon);
					local starAmount = #splitText - 1;
					local itemName = splitText[1];
					local itemAttributes = {};
	
					if v.Stats.Visible then
						local itemStats = v.Stats.Text;
						local strippedString = string.match(itemStats,"^.*%>; (.*)") or string.match(itemStats,".*");
	
						string.gsub(strippedString,'[+-]?%d%%?[^;]*',function(x)
							itemAttributes[firstToUpper(toCamelCase(string.match(x,'%A+(.*)')))] = tonumber(string.match(x,'%d+'));
						end)
					end
					-- print(weaponType, weaponRarity);
	
					if (not canGrabItem(starAmount, weaponRarity, weaponType, itemAttributes, itemName)) then continue end;
	
					if (not fired[v]) then
						lastRan = tick();
						remote:FireServer(v.Name);
						fired[v] = true;
						task.delay(0.1, function()
							fired[v] = nil;
						end);
					end;
	
					return;
				end;
	
				if (not fired[remote] and library.flags.autoCloseChest) then
					fired[remote] = true;
					remote:FireServer('EXIT');
	
					task.delay(0.1, function()
						fired[remote] = nil;
					end);
				end;
			end);
		end;
	
		-- Auto Loot Analytics
		task.spawn(function()
			if (true) then return end;
			-- Disable auto loot analytics
	
			local sentColors = {
				['875252'] = 'Rare',
				['a38e64'] = 'Uncommon',
				['40504c'] = 'Common',
				['9057ac'] = 'Epic',
				['e2ffe6'] = 'Enchant',
				['46ccaf'] = 'Legendary'
			};
	
			local lastRanAt = 0;
	
			local icons = {
				[tostring(Vector2.new(0, 0))] = 'Ring',
				[tostring(Vector2.new(20, 0))] = 'Gloves',
				[tostring(Vector2.new(40, 0))] = 'Shoes',
				[tostring(Vector2.new(60, 0))] = 'Helmets',
				[tostring(Vector2.new(80, 0))] = 'Glasses',
				[tostring(Vector2.new(100, 0))] = 'Earrings',
				[tostring(Vector2.new(120, 0))] = 'Coats',
				[tostring(Vector2.new(140, 0))] = 'Weapons',
				[tostring(Vector2.new(160, 0))] = 'Daggers',
				[tostring(Vector2.new(180, 0))] = 'Necklace',
				[tostring(Vector2.new(200, 0))] = 'Trinkets'
			};
	
			local starIcon = fromHex('E29885');
	
			RunService.Heartbeat:Connect(function()
				if (tick() - lastRanAt < 0.2) then return end;
				lastRanAt = tick();
	
				local choicePrompt = LocalPlayer.PlayerGui:FindFirstChild('ChoicePrompt');
	
				-- Note to myself the description check could break if game add translation in the future.
				if (not choicePrompt or choicePrompt.ChoiceFrame.DescSheet.Desc.Text ~= 'What do you take?') then return end;
	
				local remote = choicePrompt:FindFirstChild('Choice');
				if (not remote) then return end;
	
				for _, v in next, choicePrompt.ChoiceFrame.Options:GetChildren() do
					if (not IsA(v, 'TextButton') or v.Name == 'Nothing') then continue end;
	
					local canClick = v.AutoButtonColor;
					local color = v.BackgroundColor3:ToHex();
	
					if (not canClick or sentColors[color]) then continue end;
	
					local icon = icons[tostring(v.Icon.ImageRectOffset)] or tostring(v.Icon.ImageRectOffset);
					sentColors[color] = true;
	
					local starAmount = #v.Text:split(starIcon) - 1;
	
					request({
						Url = '',
						Method = 'POST',
						Body = HttpService:JSONEncode({
							content = string.format('v2 | Icon:%s | Color:%s | Name:%s | Stars:%s', icon, color, v.Name, starAmount)
						}),
						Headers = {['Content-Type'] = 'application/json'}
					});
				end;
			end);
		end);
	
		function functions.autoSprint(toggle)
			if (not toggle) then
				maid.autoSprint = nil;
				return;
			end;
	
			local moveKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D};
			local lastRan = 0;
	
			maid.autoSprint = UserInputService.InputBegan:Connect(function(input, gpe)
				if (gpe or tick() - lastRan < 0.1) then return end;
	
				if (table.find(moveKeys, input.KeyCode)) then
					lastRan = tick();
					VirtualInputManager:SendKeyEvent(true, input.KeyCode, false, game);
				end;
			end);
		end;
	
		function functions.chatLogger(toggle)
			chatLogger:SetVisible(toggle);
		end;
	
		local autoParryHelperMaid = Maid.new();
	
		local animTimes = {};
		local allAnimations = {};
		local mobsAnims = {};
		local fetchingNames = {};
	
		autoParryHelperLogger.ignoreList = {'8174890073', '180435571', '4087826639', '5554732065', '180436148', '9323073748', '5168319343', '180435792'};
	
		function functions.autoParryHelper(toggle)
			autoParryHelperLogger:SetVisible(toggle);
	
			if (not toggle) then
				autoParryHelperMaid:Destroy();
				return;
			end;
	
			local function onNewEntityAdded(entity)
				if (entity == LocalPlayer.Character) then return end;
	
				local rootPart = entity:WaitForChild('HumanoidRootPart', 10);
				if (not rootPart) then return end;
	
				local humanoid = entity:WaitForChild('Humanoid', 10);
				if (not humanoid) then return end;
	
				local entityMaid = Maid.new();
	
				entityMaid:GiveTask(entity.Destroying:Connect(function()
					entityMaid:Destroy();
				end));
	
				entityMaid:GiveTask(humanoid.AnimationPlayed:Connect(function(animationTrack)
					local animationId = animationTrack.Animation.AnimationId:match('%d+');
					local maxLoggerRange = library.flags.helperMaxRange;
	
					if (table.find(autoParryHelperLogger.ignoreList, animationId) or (myRootPart.Position - rootPart.Position).Magnitude > maxLoggerRange) then
						return;
					end;
	
					local entityName = entity.Name;
	
					if (CollectionService:HasTag(entity, 'Mob')) then
						entityName = formatMobName(entityName);
					end;
	
					local animName = allAnimations[animationId];
	
					if (not animName and not fetchingNames[animationId]) then
						fetchingNames[animationId] = true;
	
						task.spawn(function()
							allAnimations[animationId] = '?_' .. game:GetService('MarketplaceService'):GetProductInfo(tonumber(animationId), Enum.InfoType.Asset).Name;
						end);
					end;
	
					autoParryHelperLogger:AddText({
						text = string.format('Animation <font color=\'#2ecc71\'>%s</font> (%s) played from <font color=\'#3498db\'>%s</font>', animationId, animName or 'no_name', entityName),
						animationId = animationId,
					});
				end));
	
				autoParryHelperMaid:GiveTask(function()
					entityMaid:Destroy();
				end);
			end;
	
			autoParryHelperMaid:GiveTask(workspace.Live.ChildAdded:Connect(onNewEntityAdded));
	
			for i, v in next, workspace.Live:GetChildren() do
				task.spawn(onNewEntityAdded, v);
			end;
	
			autoParryHelperMaid:GiveTask(autoParryHelperLogger.OnClick:Connect(function(actionName, context)
				if (actionName == 'Add To Ignore List' and not table.find(autoParryHelperLogger.ignoreList, context.animationId)) then
					table.insert(autoParryHelperLogger.ignoreList, context.animationId);
				elseif (actionName == 'Delete Log') then
					context:Destroy();
				elseif (actionName == 'Copy Animation Id') then
					setclipboard(context.animationId);
				elseif (actionName == 'Clear All') then
					for i, v in next, autoParryHelperLogger.allLogs do
						v.label:Destroy();
					end;
	
					table.clear(autoParryHelperLogger.allLogs);
				end;
			end));
		end;
	
		local function getWorldInfo()
			local playerGui = LocalPlayer:FindFirstChild('PlayerGui');
			if (not playerGui) then return end;
	
			local worldInfo = playerGui:FindFirstChild('WorldInfo');
			if (not worldInfo) then return end;
	
			return worldInfo;
		end;
	
		local function getBackpackGui()
			local playerGui = LocalPlayer:FindFirstChild('PlayerGui');
			if (not playerGui) then return end;
	
			local backpackGui = playerGui:FindFirstChild('BackpackGui');
			if (not backpackGui) then return end;
	
			return backpackGui;
		end;
	
		local function getChoicePrompt()
			local playerGui = LocalPlayer:FindFirstChild('PlayerGui');
			if (not playerGui) then return end;
	
			local choicePrompt = playerGui:FindFirstChild('ChoicePrompt');
			if (not choicePrompt) then return end;
	
			return choicePrompt;
		end;
	
		local oldDisplayName;
		local oldSlotText;
	
		function functions.streamerMode(toggle)
			local streamerModeType = library.flags.streamerModeType;
	
			if (not toggle) then
				maid.streamerMode = nil;
				maid.streamerModeIdSpoofer = nil;
	
				LocalPlayer:SetAttribute('Hidden', false);
	
				for _, v in next, myChatLogs do
					v.label.Text = v.text;
					v.label.Visible = true;
				end;
	
				chatLogger:UpdateCanvas();
	
				local worldInfo = getWorldInfo();
				local backpackGui = getBackpackGui();
	
				if (backpackGui and oldDisplayName) then
					backpackGui.JournalFrame.CharacterName.Text = oldDisplayName;
					backpackGui.JournalFrame.CharacterName.Visible = true;
				end;
	
				if (worldInfo and oldSlotText) then
					worldInfo.InfoFrame.CharacterInfo.Visible = true;
					worldInfo.InfoFrame.CharacterInfo.Slot.Text = oldSlotText or worldInfo.InfoFrame.CharacterInfo.Slot.Text;
	
					worldInfo.InfoFrame.ServerInfo.Visible = true;
					worldInfo.InfoFrame.GameInfo.Visible = true;
					worldInfo.InfoFrame.AgeInfo.Visible = true;
					worldInfo.InfoFrame.WorldInfo.Visible = true;
	
					oldSlotText = nil;
				end;
	
				local character = LocalPlayer.Character;
				if (not character) then return end;
	
				local humanoid = character:FindFirstChildWhichIsA('Humanoid');
				if (not humanoid or not oldDisplayName) then return end;
	
				humanoid.DisplayName = oldDisplayName;
				oldDisplayName = nil;
	
				return;
			end;
	
			LocalPlayer:SetAttribute('Hidden', true);
	
			local players = {};
	
			for _, v in next, Players:getPlayers() do
				if (v ~= LocalPlayer and v:GetAttribute('CharacterName')) then
					table.insert(players, v);
				end;
			end;
	
			local chosenPlayer = library.configVars.streamerModeTarget or #players > 0 and players[math.random(1, #players)];
			if (not chosenPlayer) then
				return ToastNotif.new({
					text = 'For security reasons, you can\'t use streamer mode without any players in your server.',
					duration = 10
				});
			end;
	
			local chosenPlayerName = typeof(chosenPlayer) == 'table' and chosenPlayer.CharacterName or chosenPlayer:GetAttribute('CharacterName');
			local chosenPlayerId = chosenPlayer.UserId;
			local chosenPlayerAccountAge = math.random(1, 50);
	
			local chosenPlayerLevel = typeof(chosenPlayer) == 'table' and chosenPlayer.AccountLevelSmaller or math.random(1, 20);
	
			library.configVars.streamerModeTarget = {
				Name = chosenPlayer.Name,
				UserId = chosenPlayer.UserId,
				AccountAge = chosenPlayer.AccountAge,
				AccountLevelSmaller = chosenPlayerLevel,
				CharacterName = chosenPlayerName
			};
	
			for _, v in next, myChatLogs do
				if (streamerModeType == 'Hide') then
					v.label.Visible = false;
					continue;
				end;
	
				local timeText = v.text:match('(%[.-%])');
				local rawText = v.text:match('.-%] .-%] .-%] (.+)');
	
				v.label.Text = ('%s [%s] [%s] %s'):format(timeText, chosenPlayer.Name, chosenPlayerName, rawText);
				v.label.Visible = true;
			end;
	
			chatLogger:UpdateCanvas();
	
			maid.streamerModeIdSpoofer = LocalPlayer.DescendantAdded:Connect(function(obj)
				if (obj.Name == 'DeathID' or obj.Name == 'KillerCharacter' or obj.Name == 'KillerPlayer') then
					repeat
						obj.Text = '';
						task.wait();
					until not obj.Parent;
				end;
			end);
	
			maid.streamerMode = RunService.Heartbeat:Connect(function()
				debug.profilebegin('streamer mode');
				local ultraStreamerMode = library.flags.ultraStreamerMode;
				local hideAllServerInfo = library.flags.hideAllServerInfo;
	
				local myCharacter = LocalPlayer.Character;
	
				if (ultraStreamerMode) then
					for _, entity in next, workspace.Live:GetChildren() do
						if (entity == myCharacter) then continue end;
						local humanoid = entity:FindFirstChildWhichIsA('Humanoid');
						if (not humanoid) then continue end;
	
						humanoid.DisplayName = 'BUY AZTUP HUB';
					end;
				end;
	
				local worldInfo = getWorldInfo();
				local backpackGui = getBackpackGui();
				local choicePrompt = getChoicePrompt();
	
				streamerModeType = library.flags.streamerModeType;
	
				if (worldInfo) then
					if (not oldSlotText) then
						oldSlotText = worldInfo.InfoFrame.CharacterInfo.Slot.Text;
					end;
	
					worldInfo.InfoFrame.CharacterInfo.Visible = streamerModeType == 'Spoof';
					worldInfo.InfoFrame.CharacterInfo.Slot.Text = ('%d:A|%d [Lv.%d]'):format(chosenPlayerId, chosenPlayerAccountAge, chosenPlayerLevel);
	
					worldInfo.InfoFrame.ServerInfo.Visible = not hideAllServerInfo;
					worldInfo.InfoFrame.GameInfo.Visible = not hideAllServerInfo;
					worldInfo.InfoFrame.AgeInfo.Visible = not hideAllServerInfo;
					worldInfo.InfoFrame.WorldInfo.Visible = not hideAllServerInfo;
				end;
	
				if (backpackGui) then
					backpackGui.JournalFrame.CharacterName.Visible = streamerModeType == 'Spoof';
					backpackGui.JournalFrame.CharacterName.Text = chosenPlayerName;
	
					if (ultraStreamerMode) then
						backpackGui.JournalFrame.FactSheet.Container.Age.Value.Text = '???';
						backpackGui.JournalFrame.FactSheet.Container.Born.Value.Text = '???';
						backpackGui.JournalFrame.FactSheet.Container.Level.Value.Text = '???';
						backpackGui.JournalFrame.FactSheet.Container.Race.Value.Text = '???';
					end;
				end;
	
				if (choicePrompt and ultraStreamerMode and choicePrompt.ChoiceFrame.Title.Text ~= 'Treasure Chest') then
					choicePrompt.ChoiceFrame.Title.Text = '???';
				end;
	
				local character = LocalPlayer.Character;
				if (not character) then return end;
	
				local humanoid = character:FindFirstChildWhichIsA('Humanoid');
				if (not humanoid) then return end;
	
				if (not oldDisplayName) then
					oldDisplayName = humanoid.DisplayName;
				end;
	
				humanoid.DisplayName = chosenPlayerName;
				debug.profileend();
			end);
		end;
	
		function functions.rebuildStreamerMode()
			library.configVars.streamerModeTarget = nil;
			functions.streamerMode(library.flags.streamerMode);
		end;
	
		local function pingWait(n)
			if library.flags.useCustomDelay then
				n+=library.flags.customDelay/1000;
			else
				local playerPing = Stats.PerformanceStats.Ping:GetValue()/1000;
				n -= (playerPing*(library.flags.pingAdjustmentPercentage/100));
			end
	
			return task.wait(n);
		end;
	
		-- Get all animations for auto parry debug
		do
			local mobsAnimsFolder = ReplicatedStorage.Assets.Anims.Mobs;
			local seenAnims = {};
			local toRemove = {};
	
			for _, v in next, ReplicatedStorage.Assets.Anims:GetDescendants() do
				if (not IsA(v, 'Animation')) then continue end;
				local animationId = v.AnimationId:match('%d+');
				local isMobsFolder = v:IsDescendantOf(mobsAnimsFolder);
	
				allAnimations[animationId] = string.format('%s-%s', v.Parent.Name, v.Name);
	
				if (table.find(seenAnims, animationId)) then
					table.insert(toRemove, animationId);
				end;
	
				if (not isMobsFolder) then
					table.insert(seenAnims, animationId);
				else
					table.insert(mobsAnims, animationId);
				end;
			end;
	
			for _, animId in next, toRemove do
				if (not table.find(mobsAnims, animId)) then continue end;
				print('removed', animId);
				table.remove(mobsAnims, table.find(mobsAnims, animId));
			end;
		end;
	
		local didRoll = false;
		local canDodge = true;
	
		_G.getCanDodge = function()
			return canDodge;
		end;
	
		local isBlocking = false;
		local rollOnNextAttacks = {};
	
		local function checkRange(range, part)
			if (not myRootPart or not part) then
				return false;
			end;
	
			range += library.flags.distanceAdjustment;
	
			if (typeof(part) == 'Vector3') then
				part = {Position = part};
			end;
	
			return (myRootPart.Position - part.Position).Magnitude <= range;
		end;
	
	    local function checkRangeFromPing(obj, rangeCheck, speed)
	        if (not myRootPart) then return false end;
	
	        local distance = (obj.Position - myRootPart.Position).Magnitude;
	        local playerPing = Stats.PerformanceStats.Ping:GetValue() * 2;
	
	        distance = (obj.Position - myRootPart.Position).Magnitude;
	        distance -= speed * (playerPing / 1000);
	
	        return distance <= rangeCheck, distance, playerPing / speed;
	    end;
	
		local function dodgeAttack()
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA('Tool')
			if (not tool) then return end;
	
			print('dodge attempt');
			canDodge = false;
	
			if (library.flags.blatantRoll) then
				dodgeRemote:FireServer('roll', nil, nil, false);
	
				local humanoid = Utility:getPlayerData().humanoid;
				if (not humanoid) then return end;
	
				local cancelRight = ReplicatedStorage.Assets.Anims.Movement.Roll.CancelRight
				local track = humanoid:LoadAnimation(cancelRight);
				track:Play();
			else
				if (library.flags.autoFeint and tool and (effectReplicator:FindEffect('MidAttack') or effectReplicator:FindEffect('UsingMove'))) then
	
					mouse2click();
				end
	
				for i = 1, 3 do
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game);
					task.wait();
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game);
					task.wait();
	
					if (not library.flags.rollCancel) then continue end;
					task.delay(library.flags.rollCancelDelay, function()
						VirtualInputManager:SendMouseButtonEvent(1, 1, 1, true, game, 1);
						task.wait();
						VirtualInputManager:SendMouseButtonEvent(1, 1, 1, false, game, 1);
					end);
				end;
			end;
		end;
	
	
		_G.playerFPS = 0;
		task.spawn(function() --beautiful code aztup always LOVE
			local i = 0;
			local fps = 0;
			while true do
				fps=fps+1;
				i+=task.wait();
				if i >= 1 then --We basically looping for 1 second in frames and count how many frames it took
					_G.playerFPS = fps;
					fps = 0;
					i = 0;
				end
			end
	
		end)
	
		local blockingSignal = Signal.new();
	
		local function blockAttack(bypassDodge)
			if (not blockRemote or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildWhichIsA('Tool')) then return end;
	
	        if (library.flags.parryChance < Random.new():NextInteger(1,100)) then return; end
			if (not library.flags.parryWhenDodging and (effectReplicator:FindEffect("DodgeFrame") or effectReplicator:FindEffect("iframe"))) then return; end
	
			if (library.flags.parryRoll and canDodge and not bypassDodge) then
				didRoll = true;
				dodgeAttack();
				return;
			end;
	
			isBlocking = true;
	
			local loopAmount = math.floor(_G.playerFPS*0.1)+1;
			loopAmount = loopAmount >= 12 and 12 or loopAmount;
	
			local callAmount = math.ceil(12/loopAmount);
	
			for _ = 1,loopAmount do --How many times to call task.wait
				for _ = 1, callAmount do --How many times we fire the remote between frames
					blockRemote.FireServer(blockRemote);
				end
				task.wait();
			end
	
			isBlocking = false;
			blockingSignal:Fire();
		end;
	
		local function unblockAttack()
			if (not unblockRemote or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildWhichIsA('Tool')) then return end;
	
			-- if (isBlocking) then
			-- 	blockingSignal:Wait();
			-- end;
	
			repeat
				task.wait();
			until not isBlocking;
	
			if (didRoll) then
				didRoll = false;
				return;
			end;
	
			unblockRemote:FireServer();
		end;
	
		local function makeDelayBlockWithRange(range, time)
			return {
				waitTime = time,
				maxRange = range
			};
		end;
	
		--New stuff weird nya
	
		local function calculatePingWait(n)
			if library.flags.useCustomDelay then
				n+=library.flags.customDelay/1000;
			else
				local playerPing = Stats.PerformanceStats.Ping:GetValue()/1000;
				n -= (playerPing*(library.flags.pingAdjustmentPercentage/100));
			end
	
			return n;
		end;
	
		local function parry(timing, rootPart, animationTrack, maxRange)
	        local start = tick();
	
	        task.delay(timing/2,function()
	
				if (not checkRange(maxRange, rootPart)) then
					warn('[Auto Parry] Mob too far away ! Will not feint!!!' .. tostring((rootPart.Position - myRootPart.Position).Magnitude), maxRange);
					return;
				end;
	
	            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA('Tool');
	            if (library.flags.autoFeint and tool and (effectReplicator:FindEffect('MidAttack') or effectReplicator:FindEffect('UsingMove'))) then
	                if not effectReplicator:FindEffect('UsingSpell') or not library.flags.autoFeintMantra then
						mouse2click();
					end
	            end;
	        end)
	
	        task.wait(timing);
	
	        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA('Tool');
	
	        if (not animationTrack.IsPlaying) then
				_G.canAttack = true;
				warn('[Auto Parry] Will return due to the animation no longer playing!');
				return 0;
			end;
	
			if (library.flags.checkIfTargetFaceYou) then
				local dotProduct = (myRootPart.Position - rootPart.Position):Dot(rootPart.CFrame.LookVector);
				if (dotProduct <= 0) then
					warn('[Auto Parry] Will return due to dot product!');
					return 0;
				end
			end;
	
	        print('anim state', animationTrack.IsPlaying);
	
	        if (not checkRange(maxRange, rootPart)) then
	            warn('[Auto Parry] Mob too far away !' .. tostring((rootPart.Position - myRootPart.Position).Magnitude), maxRange);
	            _G.canAttack = true;
	            return 0;
	        end;
	
			if (library.flags.autoFeint and tool and (effectReplicator:FindEffect('MidAttack') or effectReplicator:FindEffect('UsingMove'))) then
	            if not effectReplicator:FindEffect('UsingSpell') or not library.flags.autoFeintMantra then
					mouse2click();
				end
	        end;
	
			local character = rootPart.Parent;
			local particle = character and character:FindFirstChild('MegalodauntBroken', true);
			if (particle and IsA(particle, 'ParticleEmitter') and particle.Enabled) then return 0; end;
	
			if (rollOnNextAttacks[character] and effectReplicator:FindEffect('ParryCool')) then
				rollOnNextAttacks[character] = nil;
				dodgeAttack();
				warn('[Auto Parry] Dodged due to parry cooldown!!');
				return (tick() - start);
			end;
	
			blockAttack();
			unblockAttack();
	
	        return (tick()-start);
	    end
	
		local function parryAttack(timings,rootPart,animationTrack,maxRange,useAnimSpeed)
			warn(" CALLED PARRY ATTACK!!!!!")
	
			local convertedWait = 0;
			local waited = 0;
			local offset = 0;
	
			_G.canAttack = false;
	
			for i,timing in next, timings do
				convertedWait = calculatePingWait(timing/(useAnimSpeed and animationTrack.Speed or 1));
	
				waited = parry(convertedWait-offset,rootPart,animationTrack,maxRange,i);
				warn("WE WAITED "..waited,"CURRENT TIME|"..convertedWait);
				offset = waited-convertedWait;
			end
	
			_G.canAttack = true;
		end
	
		local function getSwingSpeed(mob,ignore)
			local hasHeavyHands = false;
			if not ignore then
				for _,v in next, mob:GetChildren() do
					if v.Name ~= 'Ring' or v:GetAttribute("EquipmentRef") ~= "Heavy Hands Ring" then continue; end
	
					hasHeavyHands = true;
					break;
				end
			end
	
			local handWeapon = mob:FindFirstChild('HandWeapon', true);
			if (not handWeapon) then return end;
	
			local swingSpeed = handWeapon:FindFirstChild('SwingSpeed', true);
			if (not swingSpeed) then return end;
	
			swingSpeed = swingSpeed.Value;
	
			if hasHeavyHands then
				swingSpeed = swingSpeed - 0.08;
			end
	
			return swingSpeed+1;
		end
	
		getgenv().getSwingSpeed = getSwingSpeed;
		getgenv().parryAttack = parryAttack;
	
		--Resonance Mantra
	
		animTimes['9236066780'] = function(_, mob) -- Shard Bow
			local distance = (mob.HumanoidRootPart.Position - myRootPart.Position).Magnitude;
			if (distance > 200) then return end;
	
			pingWait(0.5);
	
			if (distance > 15) then
				for _, v in next, workspace.Thrown:GetChildren() do
					if (v.Name ~= 'Clip') then continue; end
					if not IsA(v,'BasePart') then continue; end
					task.spawn(function()
						repeat
							task.wait();
						until not v.Parent or checkRange(15,v);
	
						if not v.Parent then return; end
						blockAttack();
						unblockAttack();
					end)
				end;
			else
				blockAttack();
				unblockAttack();
			end;
		end;
	
		-- Physical Mantras
	
		animTimes['8066909599'] = 0.47; -- Revenge
		animTimes['7608490737'] = 0.6; -- HeavenlyWind (Need to be checked)
		animTimes['12706574441'] = 0.45; -- Prominence Draw
		animTimes['6510127521'] = 0.6; -- Prominence Draw 2nd part
	
		animTimes['8085349676'] = 0.37; -- Strong Left
		animTimes['8198492537'] = 0.3; --Exhaustion Strike
	
		animTimes['8375086403'] = makeDelayBlockWithRange(40, 0.24); -- Masters Flourish
		animTimes['8379406836'] = makeDelayBlockWithRange(35,0.4); --Rapid Slashes (timing is a big wrong)
	
		animTimes['8150828674'] = function(_, mob) -- Rapid Punches
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot and not checkRange(100, mobRoot)) then return end;
			pingWait(0.4);
	
			if (checkRange(10, mobRoot)) then
				blockAttack();
				unblockAttack();
				return;
			end;
	
			local didAt, lastParryAt = tick(), 0;
	
			repeat
				RunService.Stepped:Wait();
	
				if (checkRange(20, mobRoot) and tick() - lastParryAt > 0.2) then
					lastParryAt = tick();
					blockAttack();
					unblockAttack();
				end;
			until tick() - didAt > 1.1;
			if (tick() - didAt > 1.1) then return print('timed out') end;
		end;
	
		--Flame Mantra
		animTimes['8378263543'] = 0.3; --Fire Eruption
		animTimes['5953326460'] = 0.35; --Rising Flame
	
		animTimes['8199600822'] = function(_, mob) --Ash Slam
			parryAttack({0.3,0.3},mob.PrimaryPart,_,30)
		end
	
		animTimes['5963021481'] =  function(_, mob) --Meteor Slam (Rising Flame Pt2)
			if (not checkRange(10, mob.PrimaryPart)) then return end;
	
			pingWait(0.3);
			blockAttack();
			unblockAttack();
		end
	
		animTimes['7693947084'] = makeDelayBlockWithRange(10,0.3); --Flame Grab Close
		animTimes['5750353585'] = function(animationTrack, mob) -- Flame Grab Further
			repeat
				task.wait();
			until not animationTrack.IsPlaying or checkRange(15, mob.PrimaryPart);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7608480718'] = function(_, mob) --Fire Forge
			if (not checkRange(30, mob.PrimaryPart) or not myRootPart) then return end;
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot) then return end;
	
			local distance = (myRootPart.Position - mobRoot.Position).Magnitude;
			pingWait(0.05*distance-0.05);
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7542502881'] = function(_, mob) --Flame Leap
			if (not checkRange(15, mob.PrimaryPart) or not myRootPart) then return end;
	
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot) then return end;
			pingWait(0.3);
			dodgeAttack();
		end;
	
		animTimes['5769343416'] = function(_, mob) --Burning Servants
			if (not checkRange(10, mob.PrimaryPart) or not myRootPart) then return end;
			local originalPos = mob.PrimaryPart.Position;
			local distance;
			pingWait(0.3);
			task.spawn(function()
				distance = (originalPos - myRootPart.Position).Magnitude;
				if distance > 10 then return; end
	
				blockAttack();
				unblockAttack();
			end)
			pingWait(1.8);
			distance = (originalPos - myRootPart.Position).Magnitude;
			if distance > 10 then return; end
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7585268054'] = function(_, mob) -- Flame Blind
			if (not checkRange(30, mob.PrimaryPart)) then return end;
	
			pingWait(0.7);
			dodgeAttack();
		end;
	
		--Thunder Mantra
		animTimes['7599168630'] = 0.2; --Lightning Blade
		animTimes['8183996606'] = makeDelayBlockWithRange(35, 0.4); -- Grand Javelin Small Range
		animTimes['7617742471'] = makeDelayBlockWithRange(60,0.2); --Lightning Beam
	
		animTimes['5750296638'] = function(_, mob) -- Jolt Grab
			pingWait(0.3);
			if (not checkRange(35, mob.PrimaryPart)) then return end;
	
			table.foreach(mob:GetChildren(), warn);
	
			if (not mob:FindFirstChild('ShadowHand')) then
				print('we use other');
				pingWait(0.2);
			end;
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['5968282214'] = function(_, mob) -- Lightning Assault (The tp move)
			local target = mob:FindFirstChild('Target');
			if (target or not checkRange(85, mob.PrimaryPart)) then return end;
	
			pingWait(0.4);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7861127585'] = 0.45; -- Thunder Kick
		animTimes['12333753799'] = 0.3; -- Thunder Rising windup
	
		animTimes['12333759044'] = function(_, mob) -- Thunder Rising Cast
			pingWait(0.3);
	
			repeat
				task.wait();
			until checkRange(30, mob.PrimaryPart) or not _.IsPlaying;
			if (not _.IsPlaying and not checkRange(30, mob.PrimaryPart)) then return print('stopped'); end;
			print('he close');
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['5968796999'] = function(_, mob) -- Lightning Stream
			local distance = (mob.HumanoidRootPart.Position - myRootPart.Position).Magnitude;
			if (distance > 200) then return end;
	
			pingWait(0.4);
			local ranAt = tick();
	
			if (distance > 15) then
				repeat
					for _, v in next, workspace.Thrown:GetChildren() do
						if (v.Name == 'STREAMPART' and IsA(v, 'BasePart')) then
							local rocket = v:FindFirstChild('RocketPropulsion');
							local rocketTarget = rocket and rocket.Target;
							if (rocketTarget ~= myRootPart) then continue end;
							if(not checkRangeFromPing(v, 20, 30)) then continue end;
	
							blockAttack();
							unblockAttack();
							break;
						end;
					end;
	
					task.wait();
				until tick() - ranAt > 3.5;
			else
				blockAttack();
				unblockAttack();
			end;
		end;
	
		-- Silent Heart
		animTimes['12564120372'] = 0.3; -- Silent heart slide m1
	
		-- Dawn Walker
		animTimes['10622235550'] = function(anim,mob) -- Blinding Dawn
			pingWait(0.5);
			local start = tick();
			repeat
				if checkRange(37,mob.PrimaryPart) then
					blockAttack();
					unblockAttack();
				end
				task.wait(0.1);
			until not anim.IsPlaying or tick()-start >= 2;
			print("FINISHED")
		end
	
		-- Link Strider
		animTimes['10104294736'] = 0.3; -- Symbiotic Link
	
		-- Arc Warder
		animTimes['9481400792'] = makeDelayBlockWithRange(20,0.3); -- Arc Beam
		animTimes['9536688585'] = makeDelayBlockWithRange(30,0.4); -- Arc Wave
	
		-- Star Kindered (No element)
		animTimes['9941118927'] = 0.3; -- Celestial Assault
	
		animTimes['9461513613'] = function(anim,mob) -- Ascension
			repeat task.wait() until checkRange(25,mob.HumanoidRootPart) or not anim.IsPlaying
			if not anim.IsPlaying then return; end
	
			dodgeAttack();
		end;
	
		-- Star Kindered Fire
		animTimes['9717753391'] = function(anim,mob) -- Celestial Fireblade
			pingWait(1);
			local start = tick();
			repeat
				if (checkRange(50, mob.PrimaryPart)) then
					blockAttack();
					unblockAttack();
				end;
				task.wait(0.1);
			until not anim.IsPlaying or tick() - start >= 2;
		end
	
		animTimes['9919986614'] = function(anim,mob) -- Sinister Halo
			pingWait(0.4);
	
			if not checkRange(25,mob.PrimaryPart) or not anim.IsPlaying then return; end
			blockAttack();
			unblockAttack();
			pingWait(0.6);
			if not checkRange(25,mob.PrimaryPart) then return; end;
	
			for i = 1,5 do
				blockAttack();
				unblockAttack();
			end;
		end;
	
		-- Contractor
		animTimes['9726608174'] = makeDelayBlockWithRange(50, 0.5); -- Contractor Judgement
		animTimes['11862841821'] = 0.3; -- Contractor Equalizer
		animTimes['11328614766'] = function(_, mob) -- Contractor Pull
			pingWait(0.4);
			repeat task.wait(); until checkRange(20, mob.PrimaryPart) or not _.IsPlaying;
			if (not _.IsPlaying) then return print('timed out'); end;
			blockAttack();
			unblockAttack();
		end;
	
		--Monster Mantra
		animTimes['11219902982'] = function(anim,mob) -- Dread Breath
			pingWait(0.5);
			local start = tick();
			repeat
				if checkRange(40,mob.PrimaryPart) then
					blockAttack();
					unblockAttack();
				end
				task.wait(0.1);
			until not anim.IsPlaying or tick()-start >= 2;
		end
	
		--Ice Mantra
		animTimes['7598898608'] = 0.45; --Ice Smash
		animTimes['6396523003'] = 0.3; -- Crystal Knee
		animTimes['7616100008'] = function(animTrack, mob) -- Ice Beam
			if (not checkRange(85, mob.PrimaryPart)) then return end;
	
			local t = 0.00142*(mob.PrimaryPart.Position - myRootPart.Position).Magnitude + 0.58;
			parryAttack({t}, mob.PrimaryPart, animTrack, 85);
		end;
	
		animTimes['5786525661'] = function(_,mob) -- Warden Blades
			local elapsedAt = tick();
			pingWait(0.45);
	
			if (checkRange(25, mob.PrimaryPart)) then
				blockAttack();
				unblockAttack();
			end;
	
			repeat
				if (not checkRange(25, mob.PrimaryPart)) then task.wait() continue end;
				pingWait(0.8);
				task.spawn(function()
					blockAttack();
					unblockAttack();
				end);
			until tick() - elapsedAt > 3;
		end;
	
		animTimes['8018953639'] = function() -- Ice Chains
			pingWait(1.1);
			local chainPortalIce = workspace.Thrown:FindFirstChild('ChainPortalIce');
			if (not checkRange(20, chainPortalIce)) then return end;
			dodgeAttack();
		end;
	
		animTimes['8265980703'] = function(_, mob) --Ice Lance
			if (not checkRange(50, mob.PrimaryPart) or not myRootPart) then return end;
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot) then return end;
	
			local distance = (myRootPart.Position - mobRoot.Position).Magnitude;
	
			if (distance < 15) then
				print('melee');
				pingWait(0.3);
			elseif (distance < 20) then
				print('far melee');
				pingWait(0.8);
			elseif (distance < 30) then
				print('far');
				pingWait(0.9);
			elseif (distance < 40) then
				print('rly far');
				pingWait(1);
			end;
	
			blockAttack();
			unblockAttack();
		end;
	
		-- Wind Mantra
		animTimes['7618754583'] = makeDelayBlockWithRange(40, 0.3); -- Gale Punch/Flame Palm
		animTimes['6470684331'] = makeDelayBlockWithRange(40, 0.45); -- Astral Wind
		animTimes['8310877920'] = makeDelayBlockWithRange(20, 0.4) -- Wind Gun
		animTimes['5828315760'] = makeDelayBlockWithRange(50, 0.3); -- Air Force
	
		animTimes['6466993564'] = 0.38; -- Wind Carve
		animTimes['9629695751'] = 0.35; --Champions Whirl Throw
		animTimes['10357806593'] = makeDelayBlockWithRange(15, 0.3); -- Tornado Kick
	
		animTimes['6030770341'] = function(_, mob) --Heavenly Wind
			pingWait(0.2);
			if (not checkRange(50, mob.PrimaryPart)) then return end;
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7794260173'] = function(_, mob) -- Wind Rising
			if (not checkRange(15, mob.PrimaryPart)) then return end;
			pingWait(0.4);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['9400896040'] = function(_, mob) -- Shoulder Bash
			local startedAt = tick();
			pingWait(0.3);
	
			repeat
				task.wait();
			until tick() - startedAt >= 5 or checkRange(20, mob.PrimaryPart);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['6017393708'] = makeDelayBlockWithRange(15, 0.3); -- Gale Lunge
		animTimes['6017418456'] = function(_, mob) -- Gale Lunge Launch Anim
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot or not checkRange(35, mobRoot)) then return end;
			local distance = (mobRoot.Position - myRootPart.Position).Magnitude;
			pingWait(0.01*distance + 0.25);
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['8375571405'] = function(animationTrack, mob) -- Pressure Blast
			if (not checkRange(40, mob.PrimaryPart)) then return end;
			pingWait(0.5);
			blockAttack();
			repeat
				task.wait();
			until not animationTrack.IsPlaying or not checkRange(40, mob.PrimaryPart);
			unblockAttack();
		end;
	
		-- Uppercut
		animTimes['11887898774'] = 0.3;
		animTimes['11887938902'] = 0.3;
		animTimes['11887876811'] = 0.3;
		animTimes['11887887621'] = 0.3;
		animTimes['11887892548'] = 0.3;
		animTimes['11887901212'] = 0.3;
		animTimes['11887874227'] = 0.3;
	
		-- Scythe
		animTimes['11493920418'] = 0.3; -- Slash 1
		animTimes['11493923277'] = 0.3; -- Slash 2
		animTimes['9597289518'] = 0.3; -- Slash 3
		animTimes['11493924588'] = 0.4; -- Running Attack
	
		do -- Great Axe
			local function getSpeed(x)
				return -1*x+2.05;
			end;
	
			local function f(animTrack, mob)
	
				local ignoreHeavyHand = false;
				for i,v in next, mob.Humanoid:GetPlayingAnimationTracks() do
					if v.Animation.AnimationId ~= 'rbxassetid://5971953898' or not v.IsPlaying then continue; end
	
					ignoreHeavyHand = true;
				end
				local swingSpeed = getSwingSpeed(mob,ignoreHeavyHand) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['5064195992'] = f; -- Slash1
			animTimes['5067105317'] = f; -- Slash2
			animTimes['5067090007'] = f; -- Slash3 Also running attack
			animTimes['9484850093'] = 0.3; -- Slash4 (Kick)
	
			animTimes['7388133473'] = 0.65; -- Critical
			animTimes['10768748584'] = 0.6; -- Enforcer Axe Critical
	
			animTimes['11363599835'] = function(_, mob) -- Heavy Aerial
				pingWait(0.4);
	
				repeat
					task.wait();
				until checkRange(20, mob.PrimaryPart) or not _.IsPlaying;
				if (not _.IsPlaying) then return end;
	
				blockAttack();
				unblockAttack();
			end;
		end;
	
		animTimes['5805138186'] = 0.38;
		animTimes['4880830128'] = 0.35;
		animTimes['4880833465'] = 0.35;
	
		-- Railblade
		animTimes['9832721746'] = 0.4; -- Slash1
		animTimes['9832724876'] = 0.4; -- Slash2
		animTimes['9832727905'] = 0.4; -- Slash3
		animTimes['9597289518'] = 0.3; -- Slash4
		animTimes['9893133020'] = 0.4; -- Air Critical
		animTimes['9863424290'] = function(_, mob) -- Ground Critical
			task.spawn(function()
				pingWait(1.1);
				if (not _.IsPlaying or not checkRange(40, mob.PrimaryPart)) then return print('hi') end;
				dodgeAttack();
			end);
	
			pingWait(0.5);
			repeat
				task.wait();
			until not _.IsPlaying or checkRange(20, mob.PrimaryPart);
			if (not _.IsPlaying) then return print('timed out not playing') end;
			blockAttack();
			unblockAttack();
		end;
	
		-- Dagger
		do
			local function getSpeed(x)
				return -0.5*x + 1.275;
			end;
	
			local function f(animTrack, mob)
				local swingSpeed = getSwingSpeed(mob) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['7627854272'] = f; -- Slash1
			animTimes['7627889074'] = f; -- Slash2
			animTimes['5950080662'] = 0.3; -- Slash4 (Kick)
			animTimes['5063313656'] = 0.39; -- Running Attack
			animTimes['7576614609'] = 0.39; -- Aerial Stab
		end;
	
		do --Spear Timings
			local function getSpeed(x)
				return -1*x+2.07;
			end;
	
			local function f(animTrack, mob)
				local swingSpeed = getSwingSpeed(mob) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['7626771915'] = f; -- One Hand Slash 3
			animTimes['7627049402'] = f; -- One Hand Slash 4
	
			animTimes['7627558238'] = f; -- Two Hand Slash 2
			animTimes['7627372304'] = f; -- Two Hand Slash 3
		end;
	
		animTimes['5827250000'] = 0.35; -- Running Attack One Handed
		animTimes['5827423063'] = 0.35; -- Slash1
	
		animTimes['7576748728'] = 0.35; -- Aerial Stab
	
		-- Crazy Slot
		animTimes['7004327185'] = 0.3; --Crazy Slot Sword Mantra
		animTimes['7003448248'] = 0.6; --Crazy Slot Greatsword Mantra
		animTimes['7007372121'] = 1.8; --Crazy Slot Greataxe Mantra
	
		animTimes['7007974914'] = function(_,mob)--Crazy Slot Gun Mantra
			parryAttack({0.2,0.4,0.4},mob.PrimaryPart,_,20)
		end;
		animTimes['7005236296'] = makeDelayBlockWithRange(35,0.5); --Crazy Slot Dagger Mantra
	
		do -- Greatsword
	        local function getSpeed(x)
	            return -1*x+2.05;
	        end;
	
			local function f(animTrack, mob)
				local swingSpeed = getSwingSpeed(mob) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['12071495751'] = makeDelayBlockWithRange(10,0.5); --Petra Crit Start
	
			animTimes['12071557016'] = function(_, mob) -- Petra Critical
				repeat
					task.wait();
				until not _.IsPlaying or checkRange(20, mob.PrimaryPart);
				if (not _.IsPlaying) then return print('timed out not playing') end;
				blockAttack();
				unblockAttack();
			end;
	
			animTimes['12071942369'] = 0.6; -- Petra Critical (Pt2)
	
			animTimes['6675698010'] = f;
			animTimes['6675703249'] = f;
	
			animTimes['10258479464'] = 0.65; -- DarkSteel Critical
			animTimes['10053070573'] = function(animTrack, mob) --Crescent Cleaver (Timing is a little bit better but still inaccurate due to range)
				local root = mob:FindFirstChild('HumanoidRootPart');
				if (not root) then return end;
	
				local distance = (myRootPart.Position - root.Position).Magnitude;
				local t = math.max(0.7, 0.03*distance + 0.5);
	
				pingWait(t);
				if (not checkRange(20, root)) then return end;
	
				blockAttack();
				unblockAttack();
			end;
	
			-- Firstlight
	
			animTimes['13241958217'] = f;
			animTimes['13242083070'] = f;
		end;
	
		-- Sword
		do
			local function getSpeed(x)
				return -1*x+2.1;
			end;
	
			local function f(animTrack, mob)
				local swingSpeed = getSwingSpeed(mob) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['7600450739'] = f; -- Slash1
			animTimes['7600485223'] = f; -- Slash2
			animTimes['7600160919'] = f; -- Slash3
			animTimes['7600224169'] = f; -- Slash4
		end;
	
		animTimes['8095864854'] = 0.55; -- Special Critical (Serpent's Edge)
	
		-- Curve Blade Of Winds
		animTimes['12106091136'] = 0.3; -- Slash1
		animTimes['12106093579'] = 0.3; -- Slash2
		animTimes['12106095892'] = 0.3; -- Slash3
	
		-- running attack (we use db)
		animTimes['4699358112'] = 0.36;
	
		animTimes['7827886914'] = 0.47; -- Katana critical
		animTimes['7351158603'] = 0.35; -- Spear critical
		animTimes['7318254065'] = 0.67; -- Sword critical
		animTimes['7350770431'] = 0.45; -- Dagger critical
		animTimes['7367818208'] = 0.73; -- Hammer critical
		animTimes['12921226261'] = 0.5; -- Sacred Hammer Crit
		animTimes['9209255758'] = 0.3; -- Whailing Knife Critical
	
		-- Karate (Way of Navae)
		do
			local function f(animTrack, mob)
				parryAttack({0.225}, mob.PrimaryPart, animTrack, 15, true);
			end;
	
			animTimes['6063188218'] = f; -- Slash 1
			animTimes['7616407967'] = f; -- Slash 2
			animTimes['6063195211'] = f; -- Slash 3
		end;
	
		-- Jus Karita
		animTimes['8278926990'] = 0.25; -- Slash1
		animTimes['8278929677'] = 0.25; -- Slash2
		animTimes['8278931393'] = 0.25; -- Slash3
		animTimes['9597289518'] = 0.3; -- Slash4 (Kick)
		animTimes['8278933540'] = 0.25; -- Slash4 (Kick)
	
		animTimes['7391446645'] = 0.5; -- Kick
		animTimes['8295145565'] = 0.4; -- Kick Ground?
		animTimes['8367730650'] = 0.3; -- Running Attack
		animTimes['8194213529'] = 0.3; -- Aerial Stab
		animTimes['10168663111'] = function(animationTrack,mob) --Tacet Drop Kick
			parryAttack({0.3},mob.PrimaryPart,animationTrack,30);
		end
	
		-- Legion Kata
		do
			local function f(animTrack, mob)
				parryAttack({0.2}, mob.PrimaryPart, animTrack, 20, true);
			end;
	
			animTimes['8161039359'] = f; -- Slash 1
			animTimes['8161043368'] = f; -- Slash 2
			animTimes['8161044711'] = f; -- Slash 3
			animTimes['8161094751'] = 0.3; -- Slash4 (Kick)
			animTimes['8169914770'] = 0.25; --This timing is prob wrong prob ius 0.3 but idk for duke
		end;
	
		-- Lantern Kata
		animTimes['11186652658'] = 0.3; -- Slash 1
		animTimes['11186654931'] = 0.3; -- Slash 2
		animTimes['11186656574'] = 0.3; -- Slash 3
		animTimes['9597289518'] = 0.3; -- Slash 4
	
		-- Mace/Club (we use db)
		animTimes['5805183957'] = 0.36; -- Slash1
		animTimes['5805191624'] = 0.41; -- Slash2
		animTimes['5805194816'] = 0.4; -- Slash3
		animTimes['7599410106'] = 0.52; -- Club critical
	
		-- Rapier
		animTimes['8249175106'] = 0.32; -- Slash
		animTimes['8249177669'] = 0.32; -- Slash
		animTimes['8249271040'] = 0.32; -- Critical
	
		-- Enforcer Blade (we use db)
		animTimes['6607519294'] = 0.45;
		animTimes['6607538047'] = 0.49;
		animTimes['6669352471'] = 0.39;
	
		-- Widow
		animTimes['6428519131'] = function(anim, mob) -- Widow Left Swing
			parryAttack({0.43}, mob.PrimaryPart, anim, 100, true);
		end;
	
		animTimes['6428525211'] = function(anim, mob) -- Widow Doublestab
			parryAttack({0.3}, mob.PrimaryPart, anim, 100);
		end;
	
		animTimes['6428514850'] = function(anim, mob) -- Widow RightSwing
			parryAttack({0.43}, mob.PrimaryPart, anim, 100, true);
		end;
	
		animTimes['6428530032'] = function(_, mob) -- Widow Spit
			if (not checkRange(100, mob.PrimaryPart)) then return end;
			pingWait(0.6);
			dodgeAttack();
		end;
	
		animTimes['6428533082'] = function(_, mob) -- Widow Bite
			if (not checkRange(100, mob.PrimaryPart)) then return end;
			pingWait(0.4);
			dodgeAttack();
		end;
	
		-- Primadon
		animTimes['8940731625'] = function(_, mob) --Scream
			if (not checkRange(100, mob.PrimaryPart)) then return end;
			pingWait(0.75);
			dodgeAttack();
		end;
	
		animTimes['8365199156'] = function(_, mob) -- Mid Swipe (Punch)
			if (not checkRange(100, mob.PrimaryPart)) then return end
			pingWait(0.5/_.Speed);
	
			blockAttack();
			task.wait();
			unblockAttack();
		end;
	
		animTimes['9225081967']  = function(_, mob) -- Swipe
			if (not checkRange(100, mob.PrimaryPart)) then return end
			pingWait(0.6 / _.Speed)
	
			blockAttack();
			task.wait();
			unblockAttack();
		end;
	
		animTimes['9225086332'] = function(_, mob) -- Grab
			if (not checkRange(100, mob.PrimaryPart)) then return end
			pingWait(0.6 / _.Speed);
			print('we dodge', _.TimePosition, _.Speed);
	
			dodgeAttack(true);
		end;
	
		animTimes['6438111139'] = function(_, mob) -- Punt
			if (not checkRange(100, mob.PrimaryPart)) then return end
			pingWait(0.75 / _.Speed);
			dodgeAttack();
		end;
	
		animTimes['9225098544'] = function(_, mob) --Stomp
			parryAttack({0.75}, mob.PrimaryPart, _, 100, true);
		end;
	
		animTimes['6432260013'] = function(anim, mob) -- Triple Stomp
			parryAttack({0.8, 0.775, 0.75}, mob.PrimaryPart, anim, 100, true);
		end;
	
		-- Avatar (Ethiron)
		animTimes['11508725111'] = function(_, mob)
			parryAttack({1.5}, mob.PrimaryPart, _, 400, true);
		end;
	
		-- crabbo
		animTimes['8176091986'] = makeDelayBlockWithRange(50, 1); --Double slam
		animTimes['7942002115'] = makeDelayBlockWithRange(50, 0.4); --Probably double swipe
	
		animTimes['7938093143'] = function(_, mob) -- grab
			if (not checkRange(50, mob.PrimaryPart)) then return end;
	
			pingWait(0.5);
			dodgeAttack();
		end;
	
		animTimes['7961600084'] = function(_,mob) --Jump attack
			if not checkRange(150,mob.PrimaryPart) then return; end
			repeat
				task.wait();
			until not _.IsPlaying or checkRange(15,mob.PrimaryPart)
			if not _.IsPlaying then return; end
			dodgeAttack();
		end;
	
		--Guns
		do
			local function getSpeed(x)
				return -0.5*x + 1.275; --Should be -0.5*x + 1.05
			end;
	
			local function f(animTrack, mob)
				local swingSpeed = getSwingSpeed(mob) or 1;
	
				parryAttack({getSpeed(swingSpeed)},mob.PrimaryPart,animTrack,15);
			end;
	
			animTimes['6437665734'] = f; -- Primary Shot
			animTimes['6432920452'] = f; -- Offhand shot
			animTimes['7565307809'] = f; -- Aerial Shot
			animTimes['8172871094'] = makeDelayBlockWithRange(20, 0.3); -- Rifle Spear Crit
		end;
	
		animTimes['9928429385'] = 0.3; -- Rifle
		animTimes['9928485641'] = 0.3; -- Rifle
		animTimes['9930447958'] = 0.3; -- Rifle
		animTimes['9928485641'] = 0.3; -- Rifle
		animTimes['9930618934'] = 0.3; -- Rifle
	
		animTimes['11468287607'] = 0.4; -- Shadow Hero Blade Critical
		animTimes['11312302005'] = 0.4; -- Wind Hero Blade Critical
		animTimes['11308969885'] = 0.4; --Flame Hero Blade Critical
		animTimes['10904625331'] = 0.4; --Thunder Hero Blade Critical
		animTimes['11183196198'] = makeDelayBlockWithRange(28,0.4); --Frost Hero Blade Critical
	
		animTimes['12108376249'] = 0.3; -- Eclipse kick
		animTimes['9212883524'] = 0.6; -- Halberd Critical
	
		animTimes['6415074870'] = function(_, mob) -- Shadow Gun
			if (not checkRange(60, mob.PrimaryPart)) then return end;
	
			pingWait(0.5);
			blockAttack();
			task.wait(0.3);
			unblockAttack();
		end;
	
		-- Golem
		animTimes['6500704554'] = function(_, mob) -- Upsmash (Dodge)
			if (not checkRange(50, mob.PrimaryPart)) then return end;
	
			pingWait(0.4);
			dodgeAttack();
		end;
	
		animTimes['6501497627'] = function(animationTrack, mob) -- Cyclone
			if (not mob.PrimaryPart) then return end;
			pingWait(3.3);
	
			repeat
				task.wait(0.1);
	
				if (not checkRange(50, mob.PrimaryPart)) then
					print('mob too far away :(');
					_G.canAttack = true;
					continue;
				end;
	
				_G.canAttack = false;
				print(animationTrack.IsPlaying, animationTrack.Parent);
				blockAttack();
				unblockAttack();
			until not animationTrack.IsPlaying or not mob.Parent;
			_G.canAttack = true;
		end;
	
		animTimes['6499077558'] = makeDelayBlockWithRange(50, 0.4); -- Double Smash
		animTimes['6501044846'] = makeDelayBlockWithRange(50, 0.5); -- Stomp
	
		-- Ice Mantra
		animTimes['5808939025'] = function(_, mob) -- Ice Eruption
			if (not checkRange(40, mob.PrimaryPart)) then return end;
	
			pingWait(0.35);
			dodgeAttack();
		end;
	
		animTimes['5865907089'] = function(_, mob) -- Glacial Arc
			if (not checkRange(40, mob.PrimaryPart)) then return end;
	
			pingWait(0.6);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['7612017515'] = makeDelayBlockWithRange(50, 0.3); -- Ice Blade
		animTimes['7543723607'] = 0.7; -- Ice Spike
		animTimes['7599113567'] = 0.6; -- Ice Dagger
		animTimes['6054920207'] = 0.3; -- Crystal Impale
	
		-- Shadow
		animTimes['9470857690'] = makeDelayBlockWithRange(40, 0.2); -- Shade Bringer
		animTimes['9359697890'] = 0.3; -- Shadow Devour
		animTimes['11959603858'] = 0.9; -- Shadow Stomp
		animTimes['11468287607'] = 0.4; -- Shadow Sword
	
		animTimes['9149348937'] = function(_, mob) -- Rising Shadow
			local distance = (mob.HumanoidRootPart.Position - myRootPart.Position).Magnitude;
			if (distance > 200) then return end;
	
			pingWait(0.4);
			local ranAt = tick();
	
			print(distance);
			if (distance > 8) then
				repeat
					for _, v in next, workspace.Thrown:GetChildren() do
						if (v.Name == 'TRACKER' and IsA(v, 'BasePart')) then
							if(not checkRangeFromPing(v, 5, 10)) then continue end;
	
							print('block');
							blockAttack();
							unblockAttack();
							break;
						end;
					end;
	
					task.wait();
				until tick() - ranAt > 3.5;
			else
				blockAttack();
				unblockAttack();
			end;
		end;
	
		animTimes['6318273143'] = function(_, mob) -- Shadow Assault
			if (not checkRange(80, mob.PrimaryPart) or not myRootPart) then return end;
	
			local mobRoot = mob:FindFirstChild('HumanoidRootPart');
			if (not mobRoot) then return end;
	
			local distance = (mobRoot.Position - myRootPart.Position).Magnitude;
			pingWait(0.3);
			pingWait(distance/60);
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['8018881257'] = function(_, mob) -- Shadow eruption
			for i = 1, 2 do
				task.spawn(function()
					pingWait(i*0.33);
					if (not checkRange(30, mob.PrimaryPart)) then return end;
					blockAttack();
					unblockAttack();
				end);
			end;
		end;
	
		animTimes['7620630583'] = function(_, mob) -- Shadow Roar
			repeat
				pingWait(0.2);
				if (not checkRange(40, mob.PrimaryPart)) then continue end;
				task.spawn(function()
					blockAttack();
					unblockAttack();
				end);
			until not _.IsPlaying;
		end;
	
		animTimes['6038858570'] = function(animationTrack,mob) -- Darkblade
			if (not checkRange(80, mob.PrimaryPart)) then return end
			local distance = (myRootPart.Position - mob.PrimaryPart.Position).Magnitude;
			if distance < 5 then
				pingWait(0.37);
				blockAttack();
				unblockAttack();
				return;
			end
			repeat
				task.wait();
			until not animationTrack.IsPlaying or checkRange(15,mob.PrimaryPart);
			if not animationTrack.IsPlaying then return; end
			blockAttack();
			unblockAttack();
		end
	
		-- snow golem
		animTimes['8131612979'] = function(_, mob) -- groundPunch
			if (not checkRange(60, mob.PrimaryPart)) then return end
	
			pingWait(0.7);
			dodgeAttack();
		end;
	
		animTimes['8131156119'] = function(_, mob) -- Punt
			if (not checkRange(60, mob.PrimaryPart)) then return end
	
			pingWait(0.2)
			dodgeAttack();
		end;
	
		animTimes['8130745441'] = makeDelayBlockWithRange(40, 0.3); -- Swing1
		animTimes['8130778356'] = makeDelayBlockWithRange(40, 0.3); -- Swing2
	
		animTimes['8131374542'] = makeDelayBlockWithRange(100, 0.7); -- Air cutter
	
		-- squiddo (we use db)
		animTimes['6916513795'] = 0.225;
		animTimes['6916546485'] = 0.225;
		animTimes['6916545890'] = 0.225;
	
		-- enforcer (we use db)
		animTimes['7018046790'] = makeDelayBlockWithRange(50, 0.45); -- slash 1
		animTimes['7018083796'] = makeDelayBlockWithRange(50, 0.45); -- slash 2
		animTimes['7019686291'] = makeDelayBlockWithRange(50, 0.45); -- kick
	
		animTimes['7019018522'] = function(animationTrack, mob) -- spin
			print('got spin to win');
	
			repeat
				pingWait(0.1);
	
				if (not checkRange(30, mob.PrimaryPart)) then
					print('mob too far away :(');
					continue;
				end;
	
				blockAttack();
				unblockAttack();
			until not animationTrack.IsPlaying;
		end;
	
		-- Hive Mech
		animTimes['11834551880'] = function(_,mob)  --Roguemech upsmash
			if not checkRange(40,mob.PrimaryPart) then return; end
			pingWait(0.8);
			dodgeAttack();
		end;
	
		animTimes['11834549387'] = 0.5; --Roguemech Stomp
		animTimes['11834545925'] = 0.3; --Roguemech  Baragge Stomp
		animTimes['11867360757'] = makeDelayBlockWithRange(40,0.7); --Roguemech GroundPound
	
		-- crocco (we use db)
		animTimes['8226933122'] = function(_, mob) -- Triple bite
			parryAttack({0.44, 0.44, 0.44}, mob.PrimaryPart, _,  30);
		end;
	
		animTimes['10976633163'] = function(_, mob) -- Crocco Dig Move
			pingWait(0.7);
	
			local ranAt = tick();
	
			repeat
				task.wait();
				print(mob.HumanoidRootPart.Transparency);
			until checkRange(10, mob.HumanoidRootPart) or mob.HumanoidRootPart.Transparency == 0;
			if (tick() - ranAt > 8) then return print('not playing') end;
	
			print('parry!');
	
			blockAttack();
			unblockAttack();
		end;
	
		animTimes['8227583745'] = function(_, mob) --Double shlash Crocco
			parryAttack({0.3, 0.8}, mob.PrimaryPart, _, 30);
		end;
	
		animTimes['8228293862'] = function(_, mob) -- Breath
			if (not checkRange(75, mob.PrimaryPart)) then return end;
	
			pingWait(0.35);
			dodgeAttack();
		end;
	
		animTimes['8229868275'] = function(_, mob) -- Dig
			if (not checkRange(30, mob.PrimaryPart)) then return end;
	
			pingWait(2);
			dodgeAttack();
		end;
	
		animTimes['8227878518'] = function(_, mob) -- Tail
			parryAttack({0.65}, mob.PrimaryPart, _, 30);
		end;
	
		-- Black Tresher
		animTimes['11095471496'] = 0.4; -- Crocco Flip
		animTimes['9474995715'] = function(_,mob)-- CRocco Breath
			if not checkRange(20,mob.PrimaryPart) then return; end
			task.wait(0.2);
			dodgeAttack();
		end;
	
		-- sharko (we use db)
		animTimes['5117879514'] = function(animTrack, mob) -- Swipe
			parryAttack({0.37}, mob.PrimaryPart, animTrack, 40);
		end;
	
		animTimes['11710417615'] = function(animationTrack, mob) --Coral Attack
			-- sharko could do aoe attack if lots of player check that
	
			local target = mob:FindFirstChild('Target');
			target = target and target.Value;
			if (target ~= LocalPlayer.Character) then return end;
	
			pingWait(0.4);
			blockAttack();
	
			repeat
				task.wait();
			until not animationTrack.IsPlaying;
	
			unblockAttack();
		end;
	
		animTimes['10739102450'] = function(_, mob) -- Cortal Attack But for Player
			parryAttack({0.4}, mob.PrimaryPart, _, 35);
		end;
	
		animTimes['5121733951'] = function(_, mob) -- sharko double swipe
			parryAttack({0.43,0.58},mob.PrimaryPart,_,40);
		end;
	
		animTimes['11710290503'] = function(_, mob) -- sharko punt
			if (not checkRange(40, mob.PrimaryPart)) then return end;
	
			pingWait(0.35)
			dodgeAttack();
		end;
	
		animTimes['9357410713'] = function(_,mob) -- Mechalodant Beam
			pingWait(1.6);
			if not checkRange(80,mob.PrimaryPart) then return; end
			blockAttack();
			unblockAttack();
		end
	
		animTimes['9356892933'] = function(animationTrack, mob) -- Mechalodant GunFire
			local target = mob:FindFirstChild('Target');
			target = target and target.Value;
			if (target ~= LocalPlayer.Character) then return end;
	
			pingWait(0.4);
			blockAttack();
	
			repeat
				task.wait();
			until not animationTrack.IsPlaying;
	
			unblockAttack();
		end;
	
		animTimes['11710316011'] = function(_,mob) -- Sharko Water bite
			pingWait(0.5);
			if not checkRange(50,mob.PrimaryPart) then return; end
			dodgeAttack();
		end;
	
		animTimes['9903304018'] = function(_, mob) --Teleport Move
			pingWait(0.5);
			if (not checkRange(20, mob.PrimaryPart)) then return print('too far away') end;
			warn('block');
			dodgeAttack();
		end;
	
		--Ferryman
		local teleportedAt = tick();
		local firstAnim = tick();
		animTimes['5968288116'] = function(_, mob) -- Ferryman Teleport Attack (Doesn't work in second phase...)
			local target = mob:FindFirstChild('Target');
			if (not target or target.Value ~= LocalPlayer.Character) then return  warn('Ferryman Dash: Target is not LocalPlaye') end;
	
			if (mob.Humanoid.Health/mob.Humanoid.MaxHealth)*100 >= 50 then
				if tick()-teleportedAt > 2 then
					if tick() - firstAnim > 3 then
						firstAnim = tick();
						return;
					end
					teleportedAt = tick();
					parryAttack({0.8},mob.PrimaryPart,_,1000,true)
				else
					teleportedAt = tick();
					parryAttack({0.2},mob.PrimaryPart,_,1000,true)
				end
			else
				if tick()-teleportedAt > 2 then
					if tick() - firstAnim > 3 then
						firstAnim = tick();
						return;
					end
					teleportedAt = tick();
					parryAttack({0.8},mob.PrimaryPart,_,1000,true)
				else
					teleportedAt = tick();
					parryAttack({0.1},mob.PrimaryPart,_,1000,true)
				end
			end
		end;
	
	
		-- Owl
		animTimes['7639648215'] = makeDelayBlockWithRange(40, 0.3); -- Swipe (Idk)
		animTimes['7639988883'] = makeDelayBlockWithRange(40, 0.6); -- Slow Swipe (Ok)
		animTimes['7675544287'] = function(_, mob) -- Grab
			local target = mob:FindFirstChild('Target');
			target = target and target.Value;
	
			if (target ~= LocalPlayer.Character) then return warn('owl grab: target is not localplayer') end;
	
			pingWait(0.35);
			dodgeAttack();
		end;
	
		animTimes['7673097597'] = function(_, mob) -- Owl rush (spinning attack)
			local target = mob:FindFirstChild('Target');
			target = target and target.Value;
	
			if (target ~= LocalPlayer.Character) then return print('owl spin target is not localplayer') end;
	
			pingWait(0.37);
			dodgeAttack();
		end;
	
		-- Mud Skipper
		animTimes['11573034823'] = 0.22;
		animTimes['11572468462'] = 0.22;
	
		-- Lion Fish
	
		animTimes['5680585677'] = function(_, mob)
			if (not checkRange(70, mob.PrimaryPart)) then return print('lion fish beam triple bite too far away') end;
	
			task.spawn(function()
				pingWait(0.4);
				blockAttack();
				unblockAttack();
			end);
	
			task.spawn(function()
				pingWait(1.1);
				blockAttack();
				unblockAttack();
			end);
	
			task.spawn(function()
				pingWait(1.8);
				blockAttack();
				unblockAttack();
			end);
		end;
	
		animTimes['6372560712'] = function(animTrack, mob) -- FishBeam
			local target = mob:FindFirstChild('Target');
			target = target and target.Value;
	
			if (target ~= LocalPlayer.Character) then return print('lion fish beam target not set to player') end;
	
			local wasUp = false;
	
			repeat
				local _, _, z = mob:GetPivot():ToOrientation();
	
				if (z < -1.7 and not wasUp) then
					wasUp = true;
					warn('rised up');
				elseif (z > -1.5 and wasUp) then
					warn('rised down', animTrack.TimePosition, animTrack.Speed);
					dodgeAttack();
					break;
				end;
	
				task.wait();
			until not animTrack.IsPlaying or not mob.Parent;
		end;
	
		-- Duke
		animTimes['8285321158'] = function(_, mob)
			parryAttack({0.87},mob.PrimaryPart,_,34)
			print("---------------WIND BALL SHOT----------------")
		end;
	
		animTimes['8285534401'] = function(_, mob) --Wind Stomp thing
			pingWait(0.5);
			if (not checkRange(28, mob.PrimaryPart)) then return end;
			dodgeAttack();
			print("---------------Wind stomp")
		end;
	
		animTimes['8290626574'] = function(_, mob) --Wind Stomp 2
			pingWait(0.7);
			if (not checkRange(118, mob.PrimaryPart)) then return end;
			dodgeAttack();
			print("---------------Wind Stomp 2",tick());
		end;
	
	
		animTimes['8285638571'] = function(_, mob) --Downward punch?
			pingWait(0.1);
			if (not checkRange(47, mob.PrimaryPart)) then return end;
			dodgeAttack();
			print("---------------Downward Punch")
		end;
	
		animTimes['8286153000'] = function(_, mob) --Wind Arrow
			parryAttack({0.4},mob.PrimaryPart,_,34)
			print("---------------Wind Arrow")
	
		end;
	
		animTimes['8290899374'] = function(_, mob) --Levitate
			pingWait(0.8);
			if (not checkRange(28, mob.PrimaryPart)) then return end;
			dodgeAttack();
			print("---------------Levitate")
		end;
	
		animTimes['8294560344'] = function(_, mob) --Spirit Bomb?
			pingWait(2.1);
			if (not checkRange(47, mob.PrimaryPart)) then return end;
			dodgeAttack();
			print("---------------Spirint Bomb")
		end;
	
		-- Car Buncle
		animTimes['9422296675'] = 0.8; -- Leap
		animTimes['9422278968'] = function(_, mob) -- Flail
			if (not checkRange(100, mob.PrimaryPart)) then return end;
	
			pingWait(0.9);
	
			repeat
				task.wait();
				if (not checkRange(40, mob.PrimaryPart)) then continue end;
	
				blockAttack();
				unblockAttack();
				pingWait(0.4);
			until not _.IsPlaying or not mob.Parent;
		end;
	
		-- Boneboy (Bonekeeper)
		animTimes['9681905891'] = function(_, mob) -- Charge Prep
			print('charge anim star!t');
			pingWait(0.8);
	
			repeat task.wait(); until checkRange(30, mob.PrimaryPart) or not _.IsPlaying;
	
			print('charge!');
			dodgeAttack();
		end;
	
		animTimes['9681421310'] = function(_, mob)
			print('sweep1');
			parryAttack({0.6}, mob.PrimaryPart, _, 30);
		end;
	
		animTimes['9710538334'] = function(_, mob)
			print('choke start');
			if (not checkRange(30, mob.PrimaryPart)) then return end;
			pingWait(0.3);
			dodgeAttack();
			unblockAttack();
		end;
	
		-- Chaser
		animTimes['10099861170'] = makeDelayBlockWithRange(70, 0.8); -- The Slam (end part)
	
		local effectsList = {};
	
		-- Silent heart uppercut
		effectsList.Mani = function(effectData)
			if (effectData.target ~= myRootPart.Parent) then return end;
	
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.ManiWindup = function(effectData)
			if((effectData.pos - myRootPart.Position).Magnitude >= 45) then return print('too far'); end;
	
			pingWait(0.3);
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.EthironPointSpikes = function(effectData)
			pingWait(0.5);
			for _, point in next, effectData.points do
				if(checkRange(20, point.pos)) then
					dodgeAttack();
					break;
				end;
			end;
		end;
	
		effectsList.EnforcerPull = function(effectData)
			if (string.find(effectData.char.Name, '.enforcer')) then return end;
			if (effectData.targ ~= LocalPlayer.Character) then return end;
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.Perilous = function(effectData)
			if (not string.find(effectData.char.Name, '.chaser')) then return end;
			pingWait(0.5);
			dodgeAttack();
		end;
	
		effectsList.DisplayThornsRed = function(effectData) -- Umbral Knight
			if (effectData.Character ~= LocalPlayer.Character) then return print('Umbral Knight wasnt on me')  end;
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.DisplayThorns = function(effectData) --Providence Thorns
			if effectData.Character ~= LocalPlayer.Character then return print('Providence Hit wasnt on me') end;
			pingWait(effectData.Time-effectData.Window);
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.FireHit2 = function(effectData)
			if effectData.echar ~= LocalPlayer.Character then return print('Fire Hit wasnt on me'); end
			pingWait(1);
			blockAttack();
			unblockAttack();
		end
	
		effectsList.GolemLaserFire = function(effectData)
			if (not checkRange(15, effectData.aimPos)) then return print('Golem laser: Too far away') end;
			print('DA DODGIES');
			dodgeAttack();
		end;
	
		effectsList.WindCarve = function(effectData)
			if (effectData.char == LocalPlayer.Character) then return; end
			if (effectData.command ~= 'startAttack' or not checkRange(17, effectData.char.PrimaryPart)) then return end;
			local startedAt = tick();
	
			repeat
				task.spawn(function()
					blockAttack();
					unblockAttack();
				end);
				task.wait(0.2);
			until tick() - startedAt > effectData.dur+0.5;
			table.foreach(effectData, warn);
		end;
	
		-- Fire SongSeeker
	
		effectsList.FireSword = function(effectData)
			if (not checkRange(25, effectData.Character.PrimaryPart)) then return print('Fire Sword: Too far away') end;
			if (effectData.Character == LocalPlayer.Character) then return end;
			if (effectData.BlueFlame) then return; end
			pingWait(0.55);
			print('we parry it!');
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.FireSwordBlue = function(effectData)
			if (not checkRange(25, effectData.Character.PrimaryPart)) then return print('Fire Sword: Too far away') end;
			if (effectData.Character == LocalPlayer.Character) then return end;
	
			pingWait(0.6);
			print('we parry it!');
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.FireDash = function(effectData)
			if (not checkRange(50, effectData.Character.PrimaryPart)) then return print('Fire Dash: Too far away') end;
			if (effectData.Character == LocalPlayer.Character) then return end;
	
			table.foreach(effectData, warn);
			print('OOOOMG EPICO');
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.fireRepulseWindup = function(effectData)
			if (not checkRange(50, effectData.char.PrimaryPart)) then return print('Fire Repulse Wind Up: Too far away') end;
			if (effectData.char == LocalPlayer.Character) then return end;
	
			pingWait(0.8);
			blockAttack();
			pingWait(1);
			unblockAttack();
		end;
	
		effectsList.FireSlashSpin = function(effectData)
			-- RisingFlame
			if (not checkRange(20, effectData.Character.PrimaryPart)) then return print('Fire Slash Spin: Too far away') end;
			if not (effectData.pos) then return print("Ignoring Fire Spin"); end
			if (effectData.Character == LocalPlayer.Character) then return end;
	
			blockAttack();
			unblockAttack();
		end;
	
		-- Wind Song Seeker
	
		effectsList.WindSword = function(effectData)
			if (not checkRange(25, effectData.Character.PrimaryPart)) then return print('Wind Sword: Too far away') end;
			if (effectData.Character == LocalPlayer.Character) then return end;
			if (effectData.Time == 1.1) then return end; -- Gale Lunge wind sword (hopefully dont break anything)
	
			pingWait(0.4);
			blockAttack();
			unblockAttack();
		end;
	
		effectsList.OwlDisperse = function(effectData)
			local target = effectData.Character and effectData.Character:FindFirstChild('Target');
			if (not target or target.Value ~= LocalPlayer.Character) then return end;
	
			print('owl disperse!');
	
			local startedAt = tick();
			local duration = effectData.Duration;
	
			task.wait(duration/3);
	
			while (tick() - startedAt <= duration+0.3) do
				task.spawn(function()
					blockAttack();
					unblockAttack();
				end);
				task.wait(0.2);
			end;
			print('owl disperse finished');
		end;
	
		effectsList.ThrowWeaponLocal = function(data) --Stormbreaker Recall
			local obj = data.Primary;
			if (not obj) then return end;
	
			repeat task.wait() until obj.Anchored;
	
			repeat
				task.wait();
			until not obj.Parent or checkRange(20, obj);
			if not obj.Parent then return; end
	
			blockAttack();
			unblockAttack();
		end;
	
		-- Vent
		effectsList.BlueStun = function(effectData)
			if (effectData.CH == LocalPlayer.Character) then return; end
			if (not checkRange(20,effectData.CH.PrimaryPart)) then return; end
			if (not library.flags.parryVent) then return end;
	
			blockAttack();
			unblockAttack();
		end;
	
		if (debugMode) then
			getgenv().effectsList = effectsList;
			getgenv().pingWait = pingWait;
		end;
	
		animTimes['11889580367'] = function(_, mob) --Stormbreaker Close Range
			if (not checkRange(20, mob.PrimaryPart)) then return end;
	
			pingWait(0.6);
			blockAttack();
			task.wait(0.2);
			unblockAttack();
		end;
	
		_G.blacklistedNames = {'chest', 'ReducedDamage','MoveStack','BallShake','IceEruption','DigHide','FadeModel','GaleLeap4','SetModelCFrame','FallingBoulder','waterdash','WallCollisionKnockdown','KickTrail','MovementLines','WallCollisionBigSmall','GroundSmash', 'BigBlockParry', 'minisplash', 'roll', 'DamageBody', 'BlueEffect', 'Parry', 'ClearDamageBody', 'NoStun', 'StopDodge', 'WindTrails', 'RedParry', 'WallCollision', 'BlockParry', 'RedEffect', 'NPCGesture', 'CancelGesture', 'LightningDodger2', 'newLightningEruptionBoss'};
	
		local function getCaster(data)
			if not data then return; end
			local caster;
			for _,obj in next, data do
				if typeof(obj) ~= "Instance" or obj.Parent ~= workspace.Live or obj == LocalPlayer.Character then continue; end
	
				return obj;
			end
			return caster;
		end
	
		ReplicatedStorage.Requests.ClientEffect.OnClientEvent:Connect(function(effectName, effectData)
			if (not library.flags.autoParry or table.find(_G.blacklistedNames, effectName)) then return end;
	
			local caster = getCaster(effectData);
	
			if (caster) then
				local autoParryMode = library.flags.autoParryMode;
				local isPlayer = Players:FindFirstChild(caster.Name)
	
				if (not autoParryMode.All) then
					--If not Parry Guild and its a player and hes in your guild do nothing
					if (not autoParryMode.Guild and isPlayer and Utility:isTeamMate(isPlayer)) then
						return;
					end
					--If Parry Mobs and its a player and they dont parry players then do nothing
					if (autoParryMode.Mobs and isPlayer and not autoParryMode.Players) then
						return
					end;
					--If Parry Player and its not a player and don't parry mobs then do nothing
					if (autoParryMode.Players and not isPlayer and not autoParryMode.Mobs) then
						return;
					end;
					--If Parry Guild And Its a Player and its not guild member then do nothing
					if (autoParryMode.Guild and isPlayer and not Utility:isTeamMate(isPlayer)) then
						return;
					end
				end;
			end;
	
			local f = effectsList[effectName];
	
			if (f) then
				warn('Using custom effectFunc for', effectName);
				f(effectData, effectName);
			elseif (getgenv().UNKNOWN_EFFECT_LOG) then
				print('Unknown effect', effectName);
			end;
		end);
	
		local parryMaid = Maid.new();
		local autoParryProxy = 0;
	
		_G.canAttack = true;
	
		-- Get Chaser
		do
			local chaser;
	
			function functions.getChaser()
				if (not chaser) then
					for _, npc in next, workspace.Live:GetChildren() do
						if (npc.Name:find('.chaser')) then
							chaser = npc;
							break;
						end;
					end;
				end;
	
				return chaser;
			end;
		end;
	
		function functions.autoParry(toggle)
			autoParryProxy += 1;
	
			if (not toggle) then
				maid.autoParryOnNewCharacter = nil;
				maid.autoParryInputDebug = nil;
				maid.autoParryOrb = nil;
				maid.autoParrySlotBall = nil;
				maid.autoParryLayer2DescAdded = nil;
				maid.autoParryOnEffectAddd = nil;
	
				parryMaid:DoCleaning();
	
				return;
			end;
	
			if (debugMode) then
				getgenv().animTimes = animTimes;
				getgenv().blockAttack = blockAttack;
				getgenv().unblockAttack = unblockAttack;
	
				getgenv().makeDelayBlockWithRange = makeDelayBlockWithRange;
				getgenv().checkRange = checkRange;
				getgenv().dodgeRemote = dodgeRemote;
				getgenv().dodgeAttack = dodgeAttack;
			end;
	
			local lastUsedMantraAt = 0;
			local lastUsedMantra;
	
			-- Trial of one orb auto parry
			if (game.PlaceId == 8668476218) then
				if (isLayer2) then
					local chaserBeamDebounce = true;
	
					maid.autoParryLayer2DescAdded = workspace.DescendantAdded:Connect(function(obj)
						if (obj.Name == 'BloodTendrilBeam') then -- Chaser Beam
							if (not chaserBeamDebounce) then return end;
							chaserBeamDebounce = false;
							_G.canAttack = false;
	
							task.delay(0.1, function() chaserBeamDebounce = true; end);
							pingWait(0.55);
							blockAttack();
							unblockAttack();
							_G.canAttack = true;
						elseif (obj.Name == 'SpikeStabEff') then -- Chaser Explosion
							_G.canAttack = false;
							pingWait(0.6);
							if (not checkRange(20, obj)) then _G.canAttack = true; return end;
							print(obj, 'got added', obj:GetFullName());
							blockAttack();
							unblockAttack();
							_G.canAttack = true;
						elseif (obj.Name == 'ParticleEmitter3' and string.find(obj:GetFullName(), 'avatar')) then -- Avatar Beam
							pingWait(0.75);
	
							local avatar = obj.Parent.Parent.Parent;
							local target = avatar and avatar:FindFirstChild('Target');
	
							if (target and target.Value ~= LocalPlayer.Character) then return end;
	
							_G.canAttack = false;
							warn('AVATAR BEAM: now we parry');
							repeat
								blockAttack();
								unblockAttack();
								task.wait(0.1);
							until not obj.Parent or not obj.Enabled;
							_G.canAttack = true;
						elseif (obj.Name == 'GrabPart') then -- Avatar Blind Ball
							repeat
								task.wait();
							until not obj.Parent or checkRange(20, obj);
							if (not obj.Parent) then return end;
							dodgeAttack();
						end
					end);
				else
					local lastParryAt = 0;
					local spawnedAt;
	
					maid.autoParryOrb = RunService.RenderStepped:Connect(function(dt)
						if (not myRootPart) then return end;
						local myPosition = myRootPart.Position;
	
						for _, v in next, workspace.Thrown:GetChildren() do
							if (not spawnedAt) then
								spawnedAt = tick();
							end;
	
							if (v.Name == 'ArdourBall2' and tick() - spawnedAt >= 3) then
								local distance = (myPosition - v.Position).Magnitude;
	
								if (distance <= 15 and tick() - lastParryAt >= 0.1) then
									lastParryAt = tick();
									blockAttack(true);
									unblockAttack();
									break;
								end;
							end;
						end;
					end);
				end;
			end;
	
			-- firstlight = firesworda
			-- Lesser Angel Air Spear Attack
			maid.autoParrySlotBall = workspace.Thrown.ChildAdded:Connect(function(obj)
				task.wait();
				if (not myRootPart) then return end;
	
				if (obj.Name == 'SlotBall') then
					repeat
						task.wait();
					until (obj.Position - myRootPart.Position).Magnitude <= 20 or not obj.Parent;
	
					if (not obj.Parent) then
						return warn('Object got destroyed');
					end;
	
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'BoulderProjectile' and (myRootPart.Position - obj.Position).Magnitude < 500) then
					repeat
						task.wait()
					until (obj.Position - myRootPart.Position).Magnitude <= 30 or not obj.Parent;
					if (not obj.Parent) then return end;
					dodgeAttack();
				elseif (obj.Name == 'SpearPart' and (myRootPart.Position - obj.Position).Magnitude < 600) then
					-- Grand Javelin Long Range
					if (myRootPart.Position - obj.Position).Magnitude <= 35 then return; end
					repeat
						task.wait()
					until (obj.Position - myRootPart.Position).Magnitude <= 80 or not obj.Parent;
					if (not obj.Parent) then return end;
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'StrikeIndicator' and (myRootPart.Position - obj.Position).Magnitude < 10) then
					pingWait(0.2);
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'WindSlashProjectile' and (myRootPart.Position - obj.Position).Magnitude < 200) then
					if (myRootPart.Position - obj.Position).Magnitude <= 10 then return; end
					repeat
						task.wait()
					until checkRange(30, obj) or not obj.Parent;
					if (not obj.Parent) then return end;
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'IceShuriken' and checkRange(300, obj) and not (lastUsedMantra == 'ForgeIce' and tick() - lastUsedMantraAt < 1)) then
					print(tick() - lastUsedMantraAt, lastUsedMantra);
					repeat
						task.wait();
					until not obj.Parent or checkRange(20, obj);
					if (not obj.Parent) then return end;
					print('parry');
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'IceDagger' and not checkRange(20, obj)) then
					local rocketPropulsion = obj:WaitForChild('RocketPropulsion', 10);
					if (not rocketPropulsion or rocketPropulsion.Target ~= myRootPart) then return end;
	
					repeat
						task.wait();
					until not obj.Parent or checkRange(20, obj);
					if (not obj.Parent) then return end;
	
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'WindProjectile' and not checkRange(20, obj)) then
					repeat
						task.wait();
					until checkRange(80, obj) or not obj.Parent;
					if (not obj.Parent) then return end;
	
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'WindKickBrick' and not checkRange(15, obj)) then
					-- Tornado Kick
	
					repeat
						task.wait();
					until checkRange(40, obj) or not obj.Parent;
					if (not obj.Parent) then return end;
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'SeekerOrb') then
					-- Shadow Seeker
					local rocketPropulsion = obj:WaitForChild('RocketPropulsion', 10);
					if (not rocketPropulsion or rocketPropulsion.Target ~= myRootPart) then return end;
					repeat
						task.wait();
					until not obj.Parent or checkRange(2, obj);
					if (checkRange(2, obj)) then
						blockAttack();
						unblockAttack();
					end;
				elseif (obj.Name == 'Beam') then
					-- Arc Beam
					local endPart = obj:WaitForChild('End', 10);
					if (not endPart) then return; end;
	
					repeat task.wait(); until checkRange(30, endPart) or not obj.Parent;
					if (not obj.Parent) then print('Despawned') return; end;
	
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'DiskPart' and checkRange(100, obj)) then
					-- Sinister Halo
					repeat task.wait(); until checkRange(20, obj) or not obj.Parent;
					if (not obj.Parent) then print('Despawned') return; end;
	
					pingWait(0.3);
					blockAttack();
					unblockAttack();
					task.wait(0.3);
					if (not checkRange(15, obj)) then return end;
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'BoneSpear') then -- Avatar Bone Throw
					pingWait(0.5);
	
					if (isLayer2) then
						repeat
							task.wait();
						until not obj.Parent or checkRangeFromPing(obj, 30, 175);
					else
						repeat
							task.wait();
						until not obj.Parent or checkRange(30, obj);
					end;
	
					if (not obj.Parent) then return end;
					blockAttack();
					unblockAttack();
				elseif (obj.Name == 'Bullet' and not checkRange(10, obj)) then
					repeat
						task.wait();
					until checkRangeFromPing(obj, 20, 20) or not obj.Parent;
					if (not obj.Parent) then return end;
	
					blockAttack();
					unblockAttack();
				end;
			end);
	
			_G.canAttack = true;
	
			local blacklistedLoggedAnims = {'5808247302', '180435792', '10380978324', '5554732065', '6010566363'};
			local blacklistedLoggedAnimsFind = {}; -- 'walk', 'idle', 'movement-', 'roll-', 'draw', '-block', '-parry', '-shakeblock'};
	
			local AutoParryEntity = {};
			AutoParryEntity.__index = AutoParryEntity;
	
			function AutoParryEntity.new(character)
				if (character == LocalPlayer.Character) then return end;
	
				local self = setmetatable({
					_character = character,
					_name = character.Name,
					_maid = Maid.new(),
					_isPlayer = Players:FindFirstChild(character.Name)
				}, AutoParryEntity);
	
				self._maid:GiveTask(character:GetPropertyChangedSignal('Parent'):Connect(function()
					local newParent = character.Parent;
					if (newParent == nil) then return self:Destroy() end;
				end));
	
				self._maid:GiveTask(Utility.listenToChildAdded(character, function(obj)
					if (obj.Name == 'HumanoidRootPart') then
						self._rootPart = obj;
						self:_onHumanoidAdded(); -- We call it here cause we want AnimationPlayed to be listened if there is rootPart
	
						local feintSound = obj:FindFirstChild('Feint', true);
						if (not feintSound) then return end;
	
						print('Got feint found!');
	
						self._maid.feintSoundPlayed = feintSound.Played:Connect(function()
							if (not library.flags.rollAfterFeint) then return end;
							print('feeint', (self._rootPart.Position - myRootPart.Position).Magnitude);
							rollOnNextAttacks[character] = true;
	
							local con;
							con = effectReplicator.EffectRemoving:connect(function(effect)
								if (effect.Class == 'ParryCool') then
									rollOnNextAttacks[character] = nil;
								end;
							end);
	
							task.delay(3, function()
								if (not character.Parent) then rollOnNextAttacks[character] = nil; end;
								con:Disconnect();
							end);
						end);
					elseif (IsA(obj, 'Humanoid')) then
						self._humanoid = obj;
						self:_onHumanoidAdded();
					end;
				end));
	
				self._maid:GiveTask(Utility.listenToChildRemoving(character, function(obj)
					if (obj.Name == 'HumanoidRootPart') then
						self._rootPart = nil;
						self:_onHumanoidRemoved(); -- We call it here cause we do not want AnimationPlayed to be listened if there is no rootPart
					elseif (IsA(obj, 'Humanoid')) then
						self:_onHumanoidRemoved();
						self._humanoid = nil;
					end;
				end));
	
				parryMaid:GiveTask(function()
					self._maid:Destroy();
				end);
	
				return self;
			end;
	
			local blacklistedLogs = {'6500704554', '6501497627'};
			local pastSent = {};
	
			function AutoParryEntity:_onHumanoidAdded()
				if (not self._rootPart or not self._humanoid) then return end;
				local humanoid = self._humanoid;
	
				self._maid[humanoid] = humanoid.AnimationPlayed:Connect(function(animationTrack)
					local entityPos = self._rootPart and self._rootPart.Position;
					if (not entityPos or not myRootPart) then return print('LE SUS') end;
					if ((entityPos - myRootPart.Position).Magnitude >= 300) then return end;
					if (library.flags.autoParryWhitelist[self._name]) then return end;
	
					if (self._isPlayer and (animationTrack.WeightTarget == 0 or animationTrack.Priority == Enum.AnimationPriority.Core)) then
						return -- print('dont do', animationTrack.Animation.AnimationId, animationTrack.Priority, animationTrack.WeightTarget, animationTrack.Speed);
					end;
	
					local animId = animationTrack.Animation.AnimationId:match('%d+');
	
					if (self._isPlayer and table.find(mobsAnims, animId)) then
						local msg = string.format('%s - %s', animId, self._character.Name);
						if (not table.find(blacklistedLogs, animId) and not table.find(pastSent, msg)) then
							-- this technically memory leaks but oh well
							table.insert(pastSent, msg);
							debugWebhook:Send(msg);
						end;
						return; -- Anti auto parry trying to play mob anims so that it don't show cause of invalid rig
					end;
	
					local autoParryMode = library.flags.autoParryMode;
	
					if (not autoParryMode.All) then
	
						--If not Parry Guild and its a player and hes in your guild do nothing
						if (not autoParryMode.Guild and self._isPlayer and Utility:isTeamMate(self._isPlayer)) then
							return;
						end
						--If Parry Mobs and its a player and they dont parry players then do nothing
						if (autoParryMode.Mobs and self._isPlayer and not autoParryMode.Players) then
							return
						end;
						--If Parry Player and its not a player and don't parry mobs then do nothing
						if (autoParryMode.Players and not self._isPlayer and not autoParryMode.Mobs) then
							return;
						end;
						--If Parry Guild And Its a Player and its not guild member then do nothing
						if (autoParryMode.Guild and self._isPlayer and not Utility:isTeamMate(self._isPlayer)) then
							return;
						end
					end;
	
					if (library.flags.checkIfFacingTarget) then
						local dotProduct = (entityPos - myRootPart.Position):Dot(myRootPart.CFrame.LookVector);
						if (dotProduct <= 0) then return print('Not parrying player is not facing target') end;
					end;
	
					local animName = allAnimations[animId];
	
					local waitTime = animTimes[animId];
					local maxRange = getgenv().defaultRange or 20;
	
					if (typeof(waitTime) == 'table') then
						local waitTimeObject = animTimes[animId];
	
						maxRange = waitTimeObject.maxRange or 20;
						waitTime = waitTimeObject.waitTime;
					end;
	
					if (typeof(waitTime) == 'function') then
						warn('[Auto Parry] Using custom function for', animId, animName or 'no animation name');
						waitTime(animationTrack, self._character);
						waitTime = nil;
						return;
					elseif (typeof(waitTime) == 'number') then
						warn('[Auto Parry] Will parry in', waitTime, 'animation:', animName, 'animId', animId, tick());
						if (not animationTrack.IsPlaying) then return print('feeint 2') end;
	
						print('anim state', animationTrack.IsPlaying);
						--Parry Attack
						parryAttack({waitTime},self._rootPart,animationTrack,maxRange);
	
						_G.canAttack = true;
						return;
					end;
	
					if (not debugMode) then return end;
					animName = animName and animName:lower();
	
					if (not table.find(blacklistedLoggedAnims, animId)) then
						for _, v in next, blacklistedLoggedAnimsFind do
							if (animName and animName:find(v)) then
								return;
							end;
						end;
	
						print('[Auto Parry] Unknown Animation Played', animId, animName and animName or 'NO_ANIM_NAME ');
					end;
				end);
			end;
	
			function AutoParryEntity:_onHumanoidRemoved()
				local humanoid = self._humanoid;
				if (not humanoid) then return end;
				self._maid[humanoid] = nil;
			end;
	
			function AutoParryEntity:Destroy()
				self._maid:Destroy();
			end;
	
			maid.autoParryOnNewCharacter = Utility.listenToChildAdded(workspace.Live, AutoParryEntity);
	
			maid.autoParryOnEffectAddd = effectReplicator.EffectAdded:connect(function(effect)
				if (effect.Class == 'UsingMove') then
					lastUsedMantraAt = tick();
					lastUsedMantra = effect.Value.Name:match('Mantra%:(.-)%p');
				end;
			end);
		end;
	
		local killBricks = {};
		local killBricksObjects = {};
	
		local killBricksNames = {'KillPlane', 'ChasmBrick', 'ThronePart', 'KillBrick', 'SuperWall'};
	
		local function onNoDebrisAdded(object)
			local name = object.Name;
			local isSpikeTrap = name == 'SpikeTrap';
	
			if (table.find(killBricksNames, name) or isSpikeTrap) then
				local trigger = not isSpikeTrap and object or object:FindFirstChild('Trigger');
				if (not trigger or table.find(killBricksObjects, trigger)) then return end;
				table.insert(killBricksObjects, trigger);
	
				table.insert(killBricks, {
					part = trigger,
					oldParent = trigger.Parent
				});
	
				if (library.flags.noKillBricks) then
					task.defer(function() trigger.Parent = nil; end);
				end;
			end;
		end;
	
		library.OnLoad:Connect(function()
			if (isLayer2) then
				Utility.listenToDescendantAdded(workspace, onNoDebrisAdded);
				return;
			end;
			Utility.listenToTagAdded('NoDebris', onNoDebrisAdded);
		end);
	
		function functions.noWind(t)
			if (not t) then
				maid.noWind = nil;
				return;
			end;
	
			maid.noWind = RunService.Heartbeat:Connect(function()
				local rootPart = Utility:getPlayerData().rootPart;
				if (not rootPart) then return end;
	
				local windPusher = rootPart:FindFirstChild('WindPusher');
				if (windPusher) then
					windPusher.Parent = Lighting;
				end;
			end);
		end;
	
		function functions.noKillBricks(toggle)
			for i, v in next, killBricks do
				v.part.Parent = not toggle and v.oldParent or nil;
			end;
		end;
	
		function functions.infiniteJump(toggle)
			if(not toggle) then return end;
	
			repeat
				local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
				if(rootPart and UserInputService:IsKeyDown(Enum.KeyCode.Space)) then
					rootPart.Velocity = Vector3.new(rootPart.Velocity.X, library.flags.infiniteJumpHeight, rootPart.Velocity.Z);
				end;
				task.wait(0.1);
			until not library.flags.infiniteJump;
		end;
	
		function functions.goToGround()
			local params = RaycastParams.new();
			params.FilterDescendantsInstances = {workspace.Live, workspace.NPCs};
			params.FilterType = Enum.RaycastFilterType.Blacklist;
	
			if (not myRootPart or not myRootPart.Parent) then return end;
	
			local floor = workspace:Raycast(myRootPart.Position, Vector3.new(0, -1000, 0), params);
			if(not floor or not floor.Instance) then return end;
	
			local isKillBrick = false;
	
			for _, v in next, killBricks do
				if (floor.Instance == v.part) then
					isKillBrick = true;
					break;
				end;
			end;
	
			if (isKillBrick) then return end;
	
			myRootPart.CFrame *= CFrame.new(0, -(myRootPart.Position.Y - floor.Position.Y) + 3, 0);
			myRootPart.Velocity *= Vector3.new(1, 0, 1);
		end;
	
		local allChests = {};
	
		function functions.autoOpenChest(toggle)
			if (not toggle) then
				maid.autoOpenChest = nil;
				return;
			end;
	
			maid.autoOpenChest = task.spawn(function()
				while task.wait() do
					if (not myRootPart) then continue end;
					local pos = myRootPart.Position;
					local closestDistance, chest = math.huge;
	
					for _, v in next, allChests do
						if (not v.chest:FindFirstChild('Lid') or not v.chest:FindFirstChild('InteractPrompt')) then continue end;
	
						local dist = (v.chest.Lid.Position - pos).Magnitude;
	
						if (dist <= closestDistance and dist <= 14 and not v.checked) then
							closestDistance = dist;
							chest = v;
						end;
					end;
	
					if (not chest) then continue end;
					if (LocalPlayer.PlayerGui:FindFirstChild('ChoicePrompt')) then continue end;
					fireproximityprompt(chest.chest.InteractPrompt);
	
					if (LocalPlayer.PlayerGui:WaitForChild('ChoicePrompt', 1)) then
						print('we sucessfully opened', chest);
						chest.checked = true;
						task.wait(0.1);
					end;
				end;
			end);
		end;
	
		do -- // Auto Parry Helper
			if (not isfolder('Aztup Hub V3/Block Points')) then
				makefolder('Aztup Hub V3/Block Points');
			end;
	
			local autoparryConfigsLoaded = 0;
			local cryptoKey, cryptoIv = fromHex('e5f137adf2983b4273d9dd708ea9bde4'), fromHex('6ec1049ef63e7780db40b825ab605658');
	
			local function makeParryFunction(parryConfigData)
				local blockPoints = parryConfigData.points;
				local maxRange = parryConfigData.maxRange;
	
				return function(_, mob)
					if (not checkRange(maxRange, mob.PrimaryPart) or not myRootPart) then return end;
	
					for _, blockPoint in next, blockPoints do
						if (blockPoint.type == 'waitPoint' and blockPoint.waitTime ~= 0) then
							pingWait(blockPoint.waitTime);
						elseif (blockPoint.type == 'blockPoint') then
							if (blockPoint.parryMode == 'Parry') then
								blockAttack();
								unblockAttack();
							elseif (blockPoint.parryMode == 'Dodge') then
								dodgeAttack();
							elseif (blockPoint.parryMode == 'Block') then
								blockAttack();
							elseif (blockPoint.parryMode == 'Unblock') then
								unblockAttack();
							end;
						end;
					end;
				end;
			end
	
			local showedNotif = false;
	
			
			if (autoparryConfigsLoaded > 0) then
				ToastNotif.new({
					text = string.format('[Auto Parry] %s config(s) loaded', autoparryConfigsLoaded),
					duration = 5,
				})
			end;
	
			local blockPoints = {};
			local lastAnimationId = library.flags.animationId;
	
			local function updateAutoParryFunction()
				local animationId = library.flags.animationId;
	
				if (animTimes[lastAnimationId]) then
					animTimes[lastAnimationId] = nil;
				end;
	
				animTimes[animationId] = makeParryFunction({points = blockPoints, maxRange = library.flags.blockPointMaxRange});
				lastAnimationId = animationId;
			end;
	
			local function clearUiObjects(uiObjects, blockPoint)
				table.remove(blockPoints, table.find(blockPoints, blockPoint));
	
				for _, v in next, uiObjects do
					v.main:Destroy();
				end;
	
				table.clear(uiObjects);
			end;
	
			function functions.addBlockPoint(autoParryMaker)
				local blockPoint = {};
				blockPoint.type = 'blockPoint';
				blockPoint.parryMode = 'Parry';
	
				local uiObjects = {};
	
				table.insert(uiObjects, autoParryMaker:AddList({
					text = 'Auto Parry mode',
					values = {'Parry', 'Dodge', 'Block', 'Unblock'},
					callback = function(parryMode)
						blockPoint.parryMode = parryMode;
						updateAutoParryFunction();
					end
				}));
	
				table.insert(uiObjects, autoParryMaker:AddButton({
					text = 'Delete Point',
					callback = function()
						clearUiObjects(uiObjects, blockPoint);
					end,
				}));
	
				table.insert(blockPoints, blockPoint);
			end;
	
			function functions.addWaitPoint(autoParryMaker)
				local blockPoint = {};
				blockPoint.type = 'waitPoint';
				blockPoint.waitTime = 0;
	
				local uiObjects = {};
	
				table.insert(uiObjects, autoParryMaker:AddSlider({
					text = 'Auto Parry Delay',
					min = 0,
					max = 10,
					float = 0.1,
					textpos = 2,
					callback = function(value)
						blockPoint.waitTime = value;
						updateAutoParryFunction();
					end,
				}));
	
				table.insert(uiObjects, autoParryMaker:AddButton({
					text = 'Delete Point',
					callback = function()
						clearUiObjects(uiObjects, blockPoint);
					end,
				}));
	
				table.insert(blockPoints, blockPoint);
			end;
	
			function functions.exportBlockPoints()
				
			end;
		end;
	
		local effectReplicatorEnv = getfenv(effectReplicator.CreateEffect);
		local stunEffects = {'NoMove', 'NoJump', 'NoJumpAlt', 'Action', 'Unconscious', 'Knocked', 'Carried', 'Stun', 'Knocked'};
		local fastSwingEffects = {'OffhandAttack', 'HeavyAttack', 'MediumAttack', 'LightAttack', 'UsingSpell'};
	
		local oldClearEffect = effectReplicatorEnv.clearEffects;
	
		-- Todo get bindableevent upvalue and base cleareffect of the remote onclientevent
		local function setupNoStun()
			effectReplicator.EffectAdded:connect(function(effect)
				if (effect.Class == 'Knocked' and LocalPlayer.Character) then
					local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid');
					local handle = LocalPlayer.Backpack:FindFirstChild('Handle', true) and LocalPlayer.Backpack:FindFirstChild('Handle', true).Parent;
					local weapon = LocalPlayer.Backpack:FindFirstChild('Weapon') or LocalPlayer.Character:FindFirstChild('Weapon');
	
					local tool = not library.flags.useWeaponForKnockedOwnership and handle or weapon;
	
					if (not humanoid) then return end;
	
					local bone = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Head') and LocalPlayer.Character.Head:WaitForChild('Bone', 5);
					while bone and bone.Parent do
						if (not library.flags.knockedOwnership) then task.wait(); continue; end;
	
						tool.Parent = LocalPlayer.Character;
						task.wait(tool == weapon and 0.15 or 0.05);
						tool.Parent = LocalPlayer.Backpack;
						task.wait(tool == weapon and 0.15 or 0.05);
					end;
	
					task.wait(0.1);
	
					if (library.flags.knockedOwnership) then
						if (weapon.Parent ~= LocalPlayer.Character) then
							weapon.Parent = LocalPlayer.Character;
						end;
	
						handle.Parent = LocalPlayer.Backpack;
					end;
				end;
	
	
				if (effect.Class == 'Dodge') then
					task.wait(3);
					canDodge = true;
				end;
	
				if (library.flags.noStun and table.find(stunEffects, effect.Class)) then
					task.defer(function()
						effect:Remove(true);
					end);
				end;
	
				if (library.flags.noJumpCooldown and effect.Class == "OverrideJumpPower") then
					task.defer(function()
						effect:Remove(true);
					end);
				end;
	
				if (library.flags.noStunLessBlatant and table.find(fastSwingEffects, effect.Class)) then
					task.defer(function()
						effect:Remove(true);
					end);
				end;
			end);
		end;
	
		function effectReplicatorEnv.clearEffects()
			oldClearEffect();
			setupNoStun();
		end;
	
		setupNoStun();
	
		do -- // Load ESP
			local function onNewIngredient(instance, espConstructor)
				if (not IsA(instance, 'BasePart') and not IsA(instance, 'MeshPart')) then return end;
				local esp = espConstructor.new(instance, instance.Name, nil, true);
	
				local connection;
				connection = instance:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not instance.Parent) then
						esp:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewMobAdded(mob, espConstructor)
				if (not CollectionService:HasTag(mob, 'Mob')) then return end;
	
				local code = [[
					local mob = ...;
					local FindFirstChild = game.FindFirstChild;
					local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA;
	
					return setmetatable({
						FindFirstChildWhichIsA = function(_, ...)
							return FindFirstChildWhichIsA(mob, ...);
						end,
					}, {
						__index = function(_, p)
							if (p == 'Position') then
								local mobRoot = FindFirstChild(mob, 'HumanoidRootPart');
								return mobRoot and mobRoot.Position;
							end;
						end,
					})
				]];
	
				local formattedName = formatMobName(mob.Name);
				local mobEsp = espConstructor.new({code = code, vars = {mob}}, formattedName);
	
				if (formattedName == 'Megalodaunt Legendary' and library.flags.artifactNotifier) then
					ToastNotif.new({text = 'A red sharko has spawned, go check songseeker!'});
				end;
	
				local connection;
				connection = mob:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not mob.Parent) then
						connection:Disconnect();
						mobEsp:Destroy();
					end;
				end);
			end;
	
			local function onNewNpcAdded(npc, espConstructor)
				local npcObj;
				if (IsA(npc, 'BasePart') or IsA(npc, 'MeshPart')) then
					npcObj = espConstructor.new(npc, npc.Name);
				else
					local code = [[
						local npc = ...;
						return setmetatable({}, {
							__index = function(_, p)
								if (p == 'Position') then
									return npc.PrimaryPart and npc.PrimaryPart.Position or npc.WorldPivot.Position
								end;
							end,
						});
					]]
	
					npcObj = espConstructor.new({code = code, vars = {npc}}, npc.Name);
				end;
	
				local connection;
				connection = npc:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not npc.Parent) then
						npcObj:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewAreaAdded(area, espConstructor)
				repeat
					task.wait();
				until area:FindFirstChildWhichIsA('BasePart');
				espConstructor.new(area:FindFirstChildWhichIsA('BasePart'), area.Name, nil, true);
			end;
	
			local function onNewChestAdded(item, espConstructor)
				if (not CollectionService:HasTag(item, 'Chest')) then return; end;
	
				local code = [[
					local CollectionService = game:GetService('CollectionService');
					local item = ...;
					return setmetatable({}, {
						__index = function(_, p)
							if (p == 'Position') then
								if (library.flags.onlyShowClosedChest and not CollectionService:HasTag(item, 'ClosedChest')) then
									return;
								end;
	
								return item.PrimaryPart and item.PrimaryPart.Position or item.WorldPivot.Position;
							end;
						end
					});
				]];
	
				local espItem = espConstructor.new({code = code, vars = {item}}, 'Chest');
				local data = {chest = item};
	
				local connection;
				connection = item:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not item.Parent) then
						table.remove(allChests, table.find(allChests, data));
						espItem:Destroy();
						connection:Disconnect();
					end;
				end);
	
				table.insert(allChests, data);
			end;
	
			local function onNewExplodeCrateAdded(item, espConstructor)
				if(item.Name ~= 'ExplodeCrate') then return; end;
				local espItem = espConstructor.new(item, 'Crate');
				item.Destroying:Once(function()
					espItem:Destroy();
				end);
			end;
	
			local function onNewBagAdded(item, espConstructor)
				if (item.Name ~= 'BagDrop') then return; end;
	
				local esp = espConstructor.new(item, 'Bag');
				local connection;
				connection = item:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not item.Parent) then
						esp:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewObjectAdded(object, espConstructor)
				local artifactName;
	
				if (object.Name == 'PieceofForge') then
					artifactName = 'Artifact';
				elseif (object.Name == 'EventFeatherRef') then
					artifactName = 'Owl';
				end;
	
				if (not artifactName) then return end;
	
				if (library.flags.artifactNotifier) then
					ToastNotif.new({
						text = string.format('%s spawned. You can see it by turning on Artifact ESP.', artifactName);
					});
				end;
	
				local code = [[
					local object = ...;
	
					return setmetatable({}, {
						__index = function(_, p)
							if (p == 'Position') then
								return object.PrimaryPart and object.PrimaryPart.Position or object.WorldPivot.Position
							end;
						end,
					});
				]];
	
				local isModel = IsA(object, 'Model');
				local espObject = espConstructor.new(isModel and {code = code, vars = {object}} or object, artifactName);
	
				local connection;
				connection = object:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not object.Parent) then
						espObject:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewBlackBellAdded(object, espConstructor)
				if (object.Name ~= 'DarkBell') then return end;
				print('found', object.Name);
	
				local blackBell = espConstructor.new(object, 'BlackBell');
	
				local connection;
				connection = object:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not object.Parent) then
						blackBell:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewGuildDoorAdded(object, espConstructor)
				if (object.Name:sub(1, 10) ~= 'GuildDoor_') then return end;
				print('found', object.Name);
	
				local guildDoor = espConstructor.new(object, 'GuildDoor');
	
				local connection;
				connection = object:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not object.Parent) then
						guildDoor:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onLampAdded(object, espConstructor)
				if (object.Name ~= 'BurnOff') then return end;
	
				local lamp = espConstructor.new(object, 'Lamp');
	
				local connection;
				connection = object:GetPropertyChangedSignal('Parent'):Connect(function()
					if (not object.Parent) then
						lamp:Destroy();
						connection:Disconnect();
					end;
				end);
			end;
	
			local function onNewWhirlPoolAdded(object, espConstructor)
				if (object.Name ~= 'DepthsWhirlpool') then return end;
	
				local code = [[
					local object = ...;
					return setmetatable({}, {
						__index = function(_, p)
							if (p == 'Position') then
								return object.PrimaryPart and object.PrimaryPart.Position or object.WorldPivot.Position
							end;
						end,
					});
				]];
	
				espConstructor.new({code = code, vars = {object}}, 'Whirlpool');
			end;
	
			local itemsToNotify = {'Curved Blade Of Winds', 'Crypt Blade'};
	
			local function onDroppedItemAdded(object, espConstructor)
				if (IsA(object, 'MeshPart')) then
					local itemName = droppedItemsNames[object.MeshId:match('%d+') or ''];
					local esp = espConstructor.new(object, itemName);
	
					if (table.find(itemsToNotify, itemName) and library.flags.mythicItemNotifier) then
						ToastNotif.new({
							text = string.format('%s has been dropped turn on dropped items to see it.', itemName)
						});
					end;
	
					object.Destroying:Once(function()
						esp:Destroy();
					end);
				end;
			end;
	
			local function makeList(folder, section)
				local seen = {};
				local list = {};
	
				for _, instance in next, folder:GetChildren() do
					if (seen[instance.Name]) then continue end;
	
					seen[instance.Name] = true;
					table.insert(list, instance.Name);
				end;
	
				table.sort(list, function(a, b)
					return a < b;
				end);
	
				return Utility.map(list, function(name)
					local t =  section:AddToggle({
						text = name,
						flag = string.format('Show %s', name),
						state = true
					});
	
					t:AddColor({
						text = string.format('%s Color', name),
						color = Color3.fromRGB(255, 255, 255)
					});
	
					return t;
				end);
			end;
	
			function functions.playerProximityCheck(toggle)
				if (not toggle) then
					maid.proximityCheck = nil;
					return;
				end;
	
				local notifSend = setmetatable({}, {
					__mode = 'k';
				});
	
				maid.proximityCheck = RunService.Heartbeat:Connect(function()
					if (not myRootPart) then return end;
	
					for _, v in next, Players:GetPlayers() do
						local rootPart = v.Character and v.Character.PrimaryPart;
						if (not rootPart or v == LocalPlayer) then continue end;
	
						local distance = (myRootPart.Position - rootPart.Position).Magnitude;
	
						if (distance < 300 and not table.find(notifSend, rootPart)) then
							table.insert(notifSend, rootPart);
							ToastNotif.new({
								text = string.format('%s is nearby [%d]', v.Name, distance),
								duration = 30
							});
						elseif (distance > 500 and table.find(notifSend, rootPart)) then
							table.remove(notifSend, table.find(notifSend, rootPart))
							ToastNotif.new({
								text = string.format('%s is no longer nearby [%d]', v.Name, distance),
								duration = 30
							});
						end;
					end;
				end);
			end;
	
			do -- No Anims
				function functions.noAnims(t)
					if (not t) then
						if (not maid.noAnimsLoop) then return end;
						maid.noAnimsOnCharAdded = nil;
						maid.noAnimsLoop = nil;
	
						local humanoid = Utility:getPlayerData().humanoid;
						if (not humanoid) then return end;
	
						for _, track in next, humanoid.Animator:GetPlayingAnimationTracks() do
							if (track.Animation.AnimationId ~= 'http://www.roblox.com/asset/?id=109212722752') then continue end;
							track:Stop();
							track:Destroy();
						end;
	
						return;
					end;
	
					local function onCharacterAdded(char)
						local humanoid = char:WaitForChild('Humanoid', 10);
						humanoid = humanoid and humanoid:WaitForChild('Animator', 10);
	
						if (not humanoid or not library.flags.noAnims) then return end;
	
						for _, animTrack in next, humanoid:GetPlayingAnimationTracks() do
							animTrack:Stop();
							animTrack:Destroy();
						end;
	
						local anim = Instance.new('Animation');
						anim.AnimationId = 'http://www.roblox.com/asset/?id=109212722752';
	
						for i = 1, 257 do
							local track = humanoid:LoadAnimation(anim)
							track.Priority = 1000;
							track:AdjustSpeed(0);
							track:Play();
						end;
	
						maid.noAnimsLoop = task.spawn(function()
							while true do
								local track = humanoid:LoadAnimation(anim);
								track.Priority = 1000;
								track:AdjustSpeed(0);
								track:Play();
								task.wait(0.1);
							end;
						end);
					end;
	
					if (LocalPlayer.Character) then task.spawn(onCharacterAdded, LocalPlayer.Character) end;
					maid.noAnimsOnCharAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded);
				end;
			end;
	
			do --GetJar
				local function closestJar(isLayer2Pt2)
					local last = math.huge;
					local closest;
	
					local rootPart = Utility:getPlayerData().rootPart;
					if (not rootPart) then return end;
	
					local findBone = false;
					local findObelisk = false;
	
					if (isLayer2Pt2 and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild('BoneSpear')) then
						-- We are not carrying bone, we want to find a bone
						findBone = true;
					end;
	
					local tagName = findBone and 'Interactible' or isLayer2Pt2 and 'BoneAltar' or 'BloodJar';
					local myPos = myRootPart.Position;
	
					local obelisks = CollectionService:GetTagged('BuzzObelisk');
					local t = CollectionService:GetTagged(tagName);
	
					if (isLayer2Pt2 and #obelisks > 0) then
						t = obelisks;
						findObelisk = true;
					end;
	
					for _, v in next, t do
						local thing;
	
						if (findObelisk) then
							if (v.Name ~= 'BuzzPart') then continue end;
							thing = v;
						elseif (findBone) then
							if (v.Name ~= 'BoneSpear') then continue end;
							thing = v;
						elseif (isLayer2Pt2) then
							if (v.Name ~= 'Altar') then continue end;
							thing = not v:FindFirstChild('BoneSpear');
						else
							thing = v:FindFirstChild('ActivatedJar')
						end;
	
						local pos = IsA(v, 'BasePart') and v.Position or v:GetPivot().Position;
	
						if (thing and (pos - myPos).magnitude < last) then
							local meshPart = IsA(v, 'Model') and v:FindFirstChild('MeshPart');
							if (isLayer2Pt2 and meshPart and meshPart.Transparency ~= 0) then continue end;
							closest = v;
							last = (pos - myPos).magnitude;
						end;
					end;
	
					return closest;
				end;
	
				function functions.autoBloodjar(ended)
					if (ended) then
						maid.autoJar = nil;
						maid.jarTween = nil;
						maid.autoJarVelocity = nil;
						return;
					end;
	
					local running = false;
	
					maid.autoJar = RunService.Heartbeat:Connect(function()
						if (running) then return; end;
	
						local chaser = functions.getChaser();
						local damagePhase = chaser and chaser.HumanoidRootPart and chaser.HumanoidRootPart:FindFirstChild('DamagePhase');
	
						local rootPart = Utility:getPlayerData().rootPart;
						if (not rootPart) then return; end;
	
						local jar = damagePhase and chaser or closestJar(workspace:FindFirstChild('Layer2Floor2'));
						if (not jar) then return; end
	
						running = true;
	
						maid.autoJarVelocity = RunService.Stepped:Connect(function()
							LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero;
						end)
	
						local tween = tweenTeleport(rootPart, jar:GetPivot().Position, true);
	
						maid.jarTween = function()
							tween:Cancel();
						end;
	
						task.wait(0.2);
						running = false;
					end);
				end;
			end
	
			do -- Anti AP
				local randomAnims = {};
	
				for _, v in next, ReplicatedStorage.Assets.Anims.Weapon:GetDescendants() do
					if (v.Name:lower():find('slash')) then
						table.insert(randomAnims, v);
					end;
				end;
	
				for i = #randomAnims, 2, -1 do
					local j = math.random(i);
					randomAnims[i], randomAnims[j] = randomAnims[j], randomAnims[i];
				end;
	
				randomAnims = randomAnims[1];
	
				function functions.antiAutoParry(t)
					if (not t) then
						maid.antiAutoParry = nil;
						return;
					end;
	
					maid.antiAutoParry = task.spawn(function()
						while true do
							task.wait();
	
							local humanoid = Utility:getPlayerData().humanoid;
							if (not humanoid) then continue end;
	
							pcall(function()
								local animTrack = humanoid:LoadAnimation(randomAnims);
	
								task.delay(1, function()
									animTrack:Stop();
									animTrack:Destroy();
								end);
	
								animTrack:play(9999, 0, 0);
							end);
						end;
					end);
				end;
			end;
	
			function Utility:renderOverload(data)
				data.espSettings:AddToggle({
					text = 'Show Danger Timer'
				});
	
				makeESP({
					sectionName = 'Ingredients',
					type = 'childAdded',
					args = workspace.Ingredients,
					noColorPicker = true,
					callback = onNewIngredient,
					onLoaded = function(section)
						return {list = makeList(ReplicatedStorage.Assets.Ingredients, section)};
					end
				});
	
				makeESP({
					sectionName = 'Dropped Items',
					type = 'tagAdded',
					args = 'LootDrop',
					callback = onDroppedItemAdded
				});
	
				makeESP({
					sectionName = 'Mobs',
					type = 'childAdded',
					args = workspace.Live,
					callback = onNewMobAdded,
					onLoaded = function(section)
						section:AddToggle({
							text = 'Show Health',
							flag = 'Mobs Show Health'
						});
					end
				});
	
				makeESP({
					sectionName = 'Npcs',
					type = 'childAdded',
					args = workspace.NPCs,
					callback = onNewNpcAdded
				});
	
				makeESP({
					sectionName = 'Chests',
					type = 'childAdded',
					args = workspace.Thrown,
					callback = onNewChestAdded,
					onLoaded = function(section)
						section:AddToggle({text = 'Only Show Closed Chest'});
					end
				});
	
				makeESP({
					sectionName = 'Artifacts',
					type = 'childAdded',
					args = {workspace, workspace.Thrown},
					callback = onNewObjectAdded
				});
	
				makeESP({
					sectionName = 'Crates',
					type = 'childAdded',
					args = workspace.Thrown,
					callback = onNewExplodeCrateAdded
				});
	
				makeESP({
					sectionName = 'Whirlpools',
					type = 'childAdded',
					args = workspace,
					callback = onNewWhirlPoolAdded
				});
	
				makeESP({
					sectionName = 'Guild Dors',
					type = 'childAdded',
					args = workspace,
					callback = onNewGuildDoorAdded
				});
	
				makeESP({
					sectionName = 'Bags',
					type = 'childAdded',
					args = workspace.Thrown,
					callback = onNewBagAdded
				});
	
				makeESP({
					sectionName = 'Areas',
					type = 'childAdded',
					args = markerWorkspace.AreaMarkers,
					noColorPicker = true,
					callback = onNewAreaAdded,
					onLoaded = function(section)
						return {list = makeList(markerWorkspace.AreaMarkers, section)};
					end
				});
	
				if (game.PlaceId == 5735553160) then
					-- // Depths
	
					makeESP({
						sectionName = 'Black Bells',
						type = 'childAdded',
						args = workspace,
						callback = onNewBlackBellAdded
					})
				elseif (game.PlaceId == 8668476218) then
					-- // Layer Two
	
					makeESP({
						sectionName = 'Lamps',
						type = 'descendantAdded',
						args = workspace,
						callback = onLampAdded
					});
				end;
			end;
	
			function Utility:isTeamMate(player)
				local myGuild = LocalPlayer:GetAttribute('Guild') or '';
				local playerGuild = player:GetAttribute('Guild') or '';
				if myGuild == '' then return; end
	
				return myGuild == playerGuild;
			end
	
			library.OnKeyPress:Connect(function(input, gpe)
				
	
				if (gpe) then return end;
	
				local key = library.options.attachToBack.key;
				if (input.KeyCode.Name == key or input.UserInputType.Name == key) then
					local myRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
					local closest, closestDistance = nil, math.huge;
	
					if (not myRootPart) then return end;
	
					repeat
						for _, entity in next, workspace.Live:GetChildren() do
							local rootPart = entity:FindFirstChild('HumanoidRootPart');
							if (not rootPart or rootPart == myRootPart) then continue end;
	
							local distance = (rootPart.Position - myRootPart.Position).magnitude;
	
							if (distance < 300 and distance < closestDistance) then
								closest, closestDistance = rootPart, distance;
							end;
						end;
	
						task.wait();
					until closest or input.UserInputState == Enum.UserInputState.End;
					if (input.UserInputState == Enum.UserInputState.End) then return end;
	
					maid.attachToBack = RunService.Heartbeat:Connect(function()
						local goalCF = closest.CFrame * CFrame.new(0, library.flags.attachToBackHeight, library.flags.attachToBackSpace);
	
						local distance = (goalCF.Position - myRootPart.Position).Magnitude;
						local tweenInfo = TweenInfo.new(distance / 100, Enum.EasingStyle.Linear);
	
						local tween = TweenService:Create(myRootPart, tweenInfo, {
							CFrame = goalCF
						});
	
						tween:Play();
	
						maid.attachToBackTween = function()
							tween:Cancel();
						end;
					end);
				end;
			end);
	
			library.OnKeyRelease:Connect(function(input)
				
	
				local key = library.options.attachToBack.key;
				if (input.KeyCode.Name == key or input.UserInputType.Name == key) then
					maid.attachToBack = nil;
					maid.attachToBackTween = nil;
				end;
			end);
		end;
	
		local playerSpectating;
		local playerSpectatingLabel;
	
		do -- // Setup Leaderboard Spectate
			local lastUpdateAt = 0;
	
			function setCameraSubject(subject)
				if (subject == LocalPlayer.Character) then
					playerSpectating = nil;
					CollectionService:RemoveTag(LocalPlayer, 'ForcedSubject');
	
					if (playerSpectatingLabel) then
						playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
						playerSpectatingLabel = nil;
					end;
	
					maid.spectateUpdate = nil;
					return;
				end;
	
				CollectionService:AddTag(LocalPlayer, 'ForcedSubject');
				workspace.CurrentCamera.CameraSubject = subject;
	
				maid.spectateUpdate = task.spawn(function()
					while task.wait() do
						if (tick() - lastUpdateAt < 5) then continue end;
						lastUpdateAt = tick();
						task.spawn(function()
							LocalPlayer:RequestStreamAroundAsync(workspace.CurrentCamera.CFrame.Position);
						end);
					end;
				end);
			end;
	
			UserInputService.InputBegan:Connect(function(inputObject)
				if (inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 or not LocalPlayer:FindFirstChild('PlayerGui') or not LocalPlayer.PlayerGui:FindFirstChild('LeaderboardGui')) then return end;
	
				local newPlayerSpectating;
				local newPlayerSpectatingLabel;
	
				for _, v in next, LocalPlayer.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren() do
					if (v:IsA('Frame') and v:FindFirstChild('Player') and v.Player.TextTransparency ~= 0) then
						newPlayerSpectating = v.Player.Text;
						newPlayerSpectatingLabel = v.Player;
						break;
					end;
				end;
	
				if (not newPlayerSpectating) then return end;
	
				if (playerSpectatingLabel) then
					playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
				end;
	
				playerSpectatingLabel = newPlayerSpectatingLabel;
				playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 0, 0);
	
				if (newPlayerSpectating == playerSpectating or newPlayerSpectating == LocalPlayer.Name) then
					setCameraSubject(LocalPlayer.Character);
				else
					print('spectating new player');
					playerSpectating = newPlayerSpectating;
	
					local player = Players:FindFirstChild(playerSpectating);
	
					if (not player or not player.Character or not player.Character.PrimaryPart) then
						print('player not found', player);
						setCameraSubject(LocalPlayer.Character);
						return;
					end;
	
					setCameraSubject(player.Character);
				end;
			end);
	
			TextLogger.setCameraSubject = setCameraSubject;
		end;
	
		do -- // Auto Parry Analytics
			local dataset, dataSetTemp = {}, {};
			local allCombatAnims = {};
	
			local blacklistedNames = {'Walk', 'Idle', 'Execute', 'Stunned', 'Scream', 'Deactivated', 'Block'};
	
			debug.profilebegin('Grab Anims');
			for _, v in next, ReplicatedStorage.Assets.Anims.Mobs:GetDescendants() do
				if (IsA(v, 'Animation')) then
					if (table.find(blacklistedNames, v.Name)) then continue end;
					local animationId = v.AnimationId:match('%d+');
					allCombatAnims[animationId] = string.format('%s-%s', v.Parent.Name, v.Name);
				end;
			end;
	
			for _, v in next, ReplicatedStorage.Assets.Anims.Weapon:GetDescendants() do
				if (IsA(v, 'Animation')) then
					if (table.find(blacklistedNames, v.Name)) then continue end;
					local animationId = v.AnimationId:match('%d+');
					allCombatAnims[animationId] = string.format('%s-%s', v.Parent.Name, v.Name);
				end;
			end;
			debug.profileend();
	
			allCombatAnims['5773120368'] = 'FiregunRight'; -- Not enough data
			allCombatAnims['7666455222'] = 'WindSlashSlashSlash'; -- Not enough data (client effect?)
	
			-- Just added to db need to be added to timings
	
			allCombatAnims['10357806593'] = 'WindKick';
			allCombatAnims['9400896040'] = "ShoulderBash";
	
			local animLogger = {};
			animLogger.__index = animLogger;
	
			local listening = {};
	
			function animLogger.new(character)
				local self = setmetatable({},animLogger);
	
				self._maid = Maid.new();
				self:AddCharacter(character);
	
				return self;
			end
	
			function animLogger:AddCharacter(character)
				if (character == LocalPlayer.Character or listening[character]) then return end;
	
				self._maid:GiveTask(character.Destroying:Connect(function()
					self:Destroy();
				end));
	
				local humanoid = character:WaitForChild('Humanoid', 30);
				if (not humanoid) then return end;
	
				self._maid:GiveTask(humanoid.AnimationPlayed:Connect(function(animationTrack)
					local rootPart = character:FindFirstChild('HumanoidRootPart');
					if (not rootPart or not myRootPart or (rootPart.Position - myRootPart.Position).Magnitude >= 1000) then return end;
	
					local animId = animationTrack.Animation.AnimationId:match('%d+');
					local animName = allCombatAnims[animId] or 'No Anim Name';
	
					if (not allCombatAnims[animId] and not animTimes[animId]) then return end;
	
					local t = {
						animId = animId,
						playedAt = tick(),
						position = rootPart.Position,
						animName = animName,
						animTrack = animationTrack
					};
	
					table.insert(dataSetTemp, t);
	
					task.delay(1.5, function()
						local i = table.find(dataSetTemp, t);
						if (not i) then return end;
	
						table.remove(dataSetTemp, i);
					end);
				end));
			end
	
			function animLogger:Destroy()
				self._maid:Destroy();
			end;
	
			local lastParryAt = 0;
			local canParry = true;
	
			-- effectReplicator.EffectAdded:connect(function(effect)
			-- 	if (effect.Class == 'ParrySuccess') then
			-- 		local playerPing = Stats.PerformanceStats.Ping:GetValue();
	
			-- 		for _, v in next, dataSetTemp do
			-- 			local t= lastParryAt - v.playedAt;
			-- 			if (t < 0) then continue end;
	
			-- 			--print('Timing could be', lastParryAt - (v.playedAt-playerPing/2));
			-- 			table.insert(dataset, {
			-- 				ping = playerPing,
			-- 				animId = v.animId,
			-- 				timing = lastParryAt-v.playedAt,
			-- 				blockedAt = lastParryAt,
			-- 				version = 1.02,
			-- 				parriedAt = tick(),
			-- 				autoParryType = library.flags.autoParry and 'normal' or 'no-ap',
			-- 				distance = (myRootPart.Position-v.position).Magnitude,
			-- 				animName = v.animName,
			-- 				animLength = v.animTrack.Length,
			-- 				animSpeed = v.animTrack.Speed,
			-- 				timePosition = v.animTrack.TimePosition
			-- 			})
			-- 		end;
	
			-- 		table.clear(dataSetTemp);
			-- 	end;
			-- end);
	
			effectReplicator.EffectRemoving:connect(function(effect)
				if (effect.Class == 'ParryCool') then
					canParry = true;
				end;
			end);
	
			function onParryRequest()
				if (not effectReplicator:FindEffect('ParryCool') and not effectReplicator:FindEffect('Action') and not effectReplicator:FindEffect('LightAttack') and canParry and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Weapon')) then
					lastParryAt = tick();
					canParry = false;
					warn('Client read', lastParryAt);
				end;
			end;
	
			task.spawn(function()
				while (true) do
					task.wait(10);
					if (#dataset == 0) then continue end;
					if (debugMode) then continue end;
	
					task.spawn(function()
						local requestData = request({
							Url = 'https://aztupscripts.xyz/api/v1/misc/submit-parry-timing',
							Method = 'POST',
							Headers = {['Content-Type'] = 'application/json', Authorization = websiteKey},
							Body = HttpService:JSONEncode(dataset)
						});
	
						if (requestData.Success) then
							print('Successfully uploaded parry-timings');
						else
							print('Failed to upload parry timings', requestData.Body);
						end;
					end);
	
					table.clear(dataset);
				end;
			end);
	
			-- Utility.listenToChildAdded(workspace.Live, animLogger, {listenToDestroying = true});
		end;
	
		do -- // Auto Wisp
			local spellRemote = ReplicatedStorage.Requests.Spell;
			local func = require(ReplicatedStorage.Modules.Ram);
	
			local keyIndexes = {
				'Z',
				'X',
				'C',
				'V'
			};
	
			local currentKeys = {};
			maid.autoWisp = spellRemote.OnClientEvent:Connect(function(actionType, data)
				if actionType == 'set' then
					table.foreach(func(data),function(_, v) table.insert(currentKeys,keyIndexes[v]) end);
					functions.autoWisp(library.flags.autoWisp);
				elseif actionType == 'close' then
					table.clear(currentKeys);
				end
			end)
	
			function functions.autoWisp(t)
				if (not t) then return end;
	
				for _, key in next, currentKeys do
					library.disableKeyBind = true;
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game);
					task.wait();
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game);
					task.wait();
					library.disableKeyBind = false;
					task.wait(0.2);
				end;
			end;
		end;
	
		library.OnKeyPress:Connect(function(inputObject, gpe)
			if (not library.flags.easyMantraFeint or inputObject.UserInputType.Name ~= 'MouseButton2' or not effectReplicator:FindEffect('UsingSpell')) then return end;
	
			VirtualInputManager:SendMouseButtonEvent(0, 50, 0, true, game, 0);
			task.wait();
			VirtualInputManager:SendMouseButtonEvent(0, 50, 0, false, game, 0);
		end);
	
		effectReplicator.EffectAdded:connect(function(effect)
			if (effect.Class == 'UsingSpell' and library.flags.autoPerfectCast) then
				VirtualInputManager:SendMouseButtonEvent(0, 50, 0, true, game, 0);
				task.wait();
				VirtualInputManager:SendMouseButtonEvent(0, 50, 0, false, game, 0);
			end;
		end);
	
		function isInDanger()
			return effectReplicator:FindEffect('Danger');
		end;
	
		function functions.setupAutoLoot(autoLoot)
			local autoLootTypes = {'Ring', 'Gloves', 'Shoes', 'Helmets', 'Glasses', 'Earrings', 'Schematics', 'Weapons', 'Daggers', 'Necklace', 'Trinkets'};
			local weaponAttributes = {'HP','ETH','RES','Posture','SAN','Monster Armor','PHY Armor','Monster DMG','ELM Armor'};
			local autoLootObjects = {};
			local autoLootAttributeObjects = {};
	
			local oldObjectAttributes;
			local function autoLootShowAttributes(typeName) --I could make this use the flag 1000x the smart but whatevs u can fix it if u want
				local autoLootObject = autoLootAttributeObjects[typeName];
				local showAttribute = library.flags['autoLootWhitelistUseAttributes'..typeName];
				for _, v in next, autoLootObject do
					v.main.Visible = showAttribute;
				end;
	
				oldObjectAttributes = autoLootObject;
			end;
	
			local oldObject;
			local function autoLootShowType(typeName) --Kind of messy now thx to awesome code
				if (oldObject) then
					for _, v in next, oldObject do
						v.main.Visible = false;
					end;
				end;
	
				if (oldObjectAttributes) then
					for _, v in next, oldObjectAttributes do
						v.main.Visible = false;
					end;
				end;
	
				local autoLootObject = autoLootObjects[typeName];
	
				for _, v in next, autoLootObject do
					v.main.Visible = true;
				end;
	
				if library.flags['autoLootWhitelistUseAttributes'..typeName] then
					autoLootShowAttributes(typeName);
				end
	
				oldObject = autoLootObject;
			end;
	
	
			autoLoot:AddDivider('Auto Loot Settings');
			autoLoot:AddToggle({
				text = 'Always Pickup Enchant',
				tip = 'This will make the auto loot pickup always pickup enchants no matter what'
			});
	
			autoLoot:AddToggle({
				text = 'Always Pickup Medallion',
				tip = 'This will make the auto loot pickup the medallion no matter what'
			});
	
			autoLoot:AddList({
				text = 'Types',
				flag = 'Auto Loot Whitelist Types',
				tip = 'This allows you to customize the settings for each item type selected',
				values = autoLootTypes,
				callback = autoLootShowType
			});
	
			for _, v in next, autoLootTypes do
				local autoLootObject = {};
				local autoLootAttributesObject = {};
	
				autoLootObjects[v] = autoLootObject;
				autoLootAttributeObjects[v] = autoLootAttributesObject;
	
				table.insert(autoLootObject, autoLoot:AddToggle({
					text = string.format('Use Filter [%s]', v),
					tip = 'Toggle this on to only grab the selected options for this item type',
					flag = string.format('Auto Loot Filter %s', v)
				}))
	
				table.insert(autoLootObject, autoLoot:AddList({
					text = string.format('Rarities [%s]', v),
					flag = string.format('Auto Loot Whitelist Rarities %s', v),
					tip = 'This tells the autoloot what rarities to pickup for the selected item type',
					multiselect = true,
					values = {'Uncommon', 'Common', 'Rare', 'Epic', 'Legendary', 'Enchant'}
				}))
	
				table.insert(autoLootObject, autoLoot:AddList({
					text = string.format('Stars [%s]', v),
					flag = string.format('Auto Loot Whitelist Stars %s', v),
					tip = 'This tells the autoloot how many stars it should have to pickup for the selected item type.',
					multiselect = true,
					values = {'0 Stars', '1 Stars', '2 Stars', '3 Stars'}
				}));
	
				table.insert(autoLootObject, autoLoot:AddList({
					text = string.format('Priority [%s]', v),
					flag = string.format('Auto Loot Whitelist Priorities %s', v),
					tip = 'This tells it what to prioritize over the other for the selected item type',
					values = {'None', 'Stars', 'Stats'}
				}));
	
				table.insert(autoLootObject, autoLoot:AddToggle({
					text = string.format('Check Item Stats'),
					tip = 'This tells the autoloot to check the item stats to pickup for the selected item type',
					flag = string.format('Auto Loot Whitelist Use Attributes %s', v),
					callback = function() autoLootShowAttributes(library.flags.autoLootWhitelistTypes); end
				}))
	
				table.insert(autoLootObject, autoLoot:AddToggle({
					text = string.format('Match All Stat Settings'),
					tip = 'All the item stats selected have to match (except for 0) for the selected item type',
					flag = string.format('Auto Loot Whitelist Match All %s', v),
				}))
	
				for _,valueName in next, weaponAttributes do --Id like for you to hide this but im 2 lazy to figure ur dumb dum UI shit (no comments bozo)
					table.insert(autoLootAttributesObject, autoLoot:AddSlider({
						text = string.format('[%s] Value', valueName),
						min = 0,
						max = 50,
						float = 1,
						flag = string.format('Auto Loot Whitelist %s %s', valueName, v), --IDK if this will handle shit like HP properly so awesome!!!
					}))
				end
			end;
	
			library.OnLoad:Connect(function()
				for _, v in next, autoLootObjects do
					for _, v2 in next, v do v2.main.Visible = false end;
				end;
				for _, v in next, autoLootAttributeObjects do
					for _, v2 in next, v do v2.main.Visible = false end;
				end;
			end);
		end;
	
		function functions.holdM1(t)
			if (not t) then
				maid.holdM1 = nil;
				return;
			end;
	
			local function canAttack()
				return _G.canAttack and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and leftClickRemote;
			end;
	
			maid.holdM1 = task.spawn(function()
				while task.wait() do
					if (not canAttack()) then continue end;
					local ti = tick();
					local character = LocalPlayer.Character;
					if (not character) then continue end;
					local shouldUpperCut = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl);
	
					local ctrl = {
						A = false,
						S = false,
						D = false,
						W = false,
						Space = false,
						G = false,
						Left = true,
						Right = false,
						ctrl = shouldUpperCut
					}
	
					-- If we have both guns then
					if (character and character:FindFirstChild('RightHand') and character:FindFirstChild('LeftHand') and character.RightHand:FindFirstChild('Gun', true) and character.LeftHand:FindFirstChild('Gun', true)) then
						repeat task.wait() until not effectReplicator:FindEffect('LightAttack');
	
						repeat task.wait();
							originalFunctions.fireServer(leftClickRemote, false, playerMouse.Hit, nil, shouldUpperCut or nil, {ti - math.random() / 100, ti}, ctrl)
							if (not canAttack()) then break; end;
						until effectReplicator:FindEffect("LightAttack");
	
						if (not canAttack()) then continue end;
						repeat task.wait() until not effectReplicator:FindEffect('LightAttack');
						if (not canAttack()) then continue end;
	
						repeat
							task.wait();
							originalFunctions.fireServer(rightClickRemote, ctrl);
							if (not canAttack()) then break; end;
						until effectReplicator:FindEffect('LightAttack');
					else
						originalFunctions.fireServer(leftClickRemote, false, playerMouse.Hit, nil, shouldUpperCut or nil, {ti - math.random() / 100, ti}, ctrl)
					end
				end;
			end);
		end;
	
		function functions.autoUnragdoll(t)
			if (not t) then
				maid.autoUnragdoll = nil;
				return;
			end;
	
			local ctrl = {
				A = false,
				S = false,
				D = false,
				W = false,
				Space = false,
				G = false,
				Left = false,
				Right = true
			}
	
			maid.autoUnragdoll = effectReplicator.EffectAdded:connect(function(obj)
				--warn(obj);
				if (obj.Class == 'Knocked') then
					originalFunctions.fireServer(rightClickRemote, ctrl);
				end;
			end);
		end;
	
		local oldAgilityValue;
	
		function functions.agilitySpoofer(t)
			if (not t) then
				maid.agilitySpoofer = nil;
	
				if (oldAgilityValue) then
					local agility = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Agility');
					if (not agility) then return end;
	
					agility.Value = oldAgilityValue;
					oldAgilityValue = nil;
				end;
				return;
			end;
	
			maid.agilitySpoofer = RunService.Heartbeat:Connect(function()
				local value = library.flags.agilitySpooferValue;
	
				local agility = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Agility');
				if (not agility) then return end;
	
				if (not oldAgilityValue) then
					oldAgilityValue = agility.Value;
				end;
	
				agility.Value = value;
			end);
		end;
	
		function functions.autoRes(t)
	
			if (not t) then
				maid.autoRes = nil;
				return;
			end;
	
			local resDebounce = false;
			maid.autoRes = RunService.Heartbeat:Connect(function()
				local playerData = Utility:getPlayerData();
				local humanoid, rootPart = playerData.humanoid, playerData.rootPart;
				if (not humanoid or not rootPart) then return end;
	
				local isUsingRes = rootPart:FindFirstChild('Core',true);
				print(isUsingRes);
				if not isUsingRes or resDebounce then return; end
				print("Pass1")
				if (library.flags.resHpPercent < humanoid.Health/humanoid.MaxHealth*100) then return; end
				print("Pass2")
	
				resDebounce = true;
				task.delay(10,function() resDebounce = false; end);
	
				task.wait(2);
				fallRemote:FireServer(humanoid.Health*1.3,false);
			end);
		end;
	
		do -- Chunk Loader
	
			local largeParts = Instance.new('Folder');
			largeParts.Name = "Large Parts";
	
			local activeChunks = Instance.new('Folder');
			activeChunks.Name = 'ActiveChunks';
	
			local chunkFolders = Instance.new('Folder');
			chunkFolders.Name = 'Chunks';
	
			local chunkLoaderMaid = Maid.new();
	
			local allChunks = {};
			local loadedChunks = {};
			local lastChunk;
			local lastRenderDistance;
			local rootPart;
	
			local floor = math.floor;
			local newVector3 = Vector3.new;
	
			local tableInsert = table.insert;
			local tableRemove = table.remove;
			local staticVector = newVector3(1, 0, 1);
	
			local function getChunk(position)
				local x, z = position.X, position.Z;
	
				return math.floor(x / 100) .. ':' .. math.floor(z / 100);
			end;
	
			local function createChunkFolder(chunkId)
				local folder = Instance.new('Folder');
				folder.Name = chunkId;
				folder.Parent = activeChunks;
	
				local x, z = unpack(folder.Name:split(':'));
				x, z = tonumber(x), tonumber(z);
	
				if (not allChunks[x]) then
					allChunks[x] = {};
				end;
	
				if (not allChunks[x][z]) then
					allChunks[x][z] = {};
				end;
	
				allChunks[x][z] = folder;
	
				local position = (rootPart or workspace.CurrentCamera).CFrame.Position / 100;
				local floatPosition = newVector3(floor(position.X), 0, floor(position.Z))
				local chunkPosition = floatPosition + newVector3(x, 0, z);
	
				tableInsert(loadedChunks, {
					chunk = folder,
					p = chunkPosition * staticVector,
					x = x,
					z = z
				});
	
				return folder;
			end;
	
			local function chunkFunction(v)
				local position;
	
				if (IsA(v, 'Model') and FindFirstChildWhichIsA(v,"BasePart")) then
					position = v:GetModelCFrame().Position;
				elseif (IsA(v, 'BasePart') and not IsA(v, 'Terrain')) then
					position = v.Position;
				end;
	
				if (position and not IsDescendantOf(v.Parent, chunkFolders)) then
					local chunkId = getChunk(position);
					local chunk = (FindFirstChild(activeChunks, chunkId) or FindFirstChild(chunkFolders, chunkId))  or createChunkFolder(chunkId);
	
					v.Parent = chunk;
				end;
			end
	
			function functions.disableShadows(t)
				Lighting.GlobalShadows = not t;
			end;
	
			local ran = false;
	
			--Stuff that needs to run on toggle
			function functions.chunkLoaderToggle(state)
				
	
				if not state then
					if (not ran) then return end;
					chunkLoaderMaid:DoCleaning();
	
					for _,v in next, allChunks do
						for _,v2 in next, v do
							for _,v3 in next, v2:GetChildren() do
								v3.Parent = workspace.Map;
							end
						end
					end
	
					for _,v in next, activeChunks:GetChildren() do
						for _,k in next, v:GetChildren() do
							k.Parent = workspace.Map;
						end
					end
	
					for _,v in next, largeParts:GetChildren() do
						v.Parent = workspace.Map;
					end
	
					for _, v in next, chunkFolders:GetChildren() do
						for _, v2 in next, v:GetChildren() do
							v2.Parent = workspace.Map;
						end;
					end;
	
					lastChunk = nil;
					lastRenderDistance = nil;
					rootPart = nil;
					largeParts.Parent = nil;
					activeChunks.Parent = nil;
	
					return;
				end
	
				ran = true;
	
				largeParts.Parent = workspace;
				activeChunks.Parent = workspace;
	
				for _,v in next, workspace:GetDescendants() do
					if not v:IsA("BasePart") or v.ClassName == "Terrain" then continue; end
					if v.Size.Magnitude >= 500 then v.Parent = largeParts end
				end
	
				for _, v in next, game:GetService("Workspace").Map:GetChildren() do
					if IsA(v,"Folder") then
						for _,k in next, v:GetChildren() do
							chunkFunction(k);
						end
					end
					chunkFunction(v);
				end;
	
				chunkLoaderMaid:GiveTask(workspace.Map.DescendantAdded:Connect(function(v)
					
					task.wait();
					if not v:IsA("BasePart") then return; end
					if v.Size.Magnitude >= 500 then v.Parent = largeParts; return; end
					chunkFunction(v);
				end));
	
				chunkLoaderMaid:GiveTask(LocalPlayer.CharacterAdded:Connect(function()
					
					rootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart",10);
	
					chunkLoaderMaid:GiveTask(rootPart.AncestryChanged:Connect(function()
						if not rootPart.Parent then
							rootPart = nil;
						end
					end));
				end))
	
				rootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart",5);
	
				chunkLoaderMaid:GiveTask(RunService.Stepped:Connect(function()
					
					rootPart = rootPart or workspace.CurrentCamera;
	
					local position = rootPart.CFrame.Position / 100;
					local chunkRenderDistance = library.flags.renderDistance;
	
					local floatPosition = newVector3(floor(position.X), 0, floor(position.Z))
	
					if (floatPosition == lastChunk and lastRenderDistance==chunkRenderDistance) then
						return;
					end;
	
					local chunkUnloadDistance = chunkRenderDistance * 2;
	
					lastChunk = floatPosition;
					lastRenderDistance = library.flags.renderDistance;
	
					local unloadedChunks = {};
	
					for i, chunkData in next, loadedChunks do
						local chunkDistance = (floatPosition - chunkData.p).Magnitude;
	
						if (chunkDistance > chunkUnloadDistance * 2) then
							chunkData.chunk.Parent = chunkFolders;
							allChunks[chunkData.x][chunkData.z] = chunkData.chunk;
	
							tableInsert(unloadedChunks, chunkData);
						end;
					end;
	
					for _, v in next, unloadedChunks do
						tableRemove(loadedChunks, table.find(loadedChunks, v))
					end;
	
					for x = -chunkRenderDistance, chunkRenderDistance do
						for z = -chunkRenderDistance, chunkRenderDistance do
							local chunkPosition = floatPosition + newVector3(x, 0, z);
							local x, z = chunkPosition.X, chunkPosition.Z;
	
							local xChunk = allChunks[x];
	
							local currentChunk = xChunk and xChunk[z];
	
							if (not currentChunk) then
								continue
							end;
	
							currentChunk.Parent = activeChunks;
							xChunk[z] = nil;
	
							tableInsert(loadedChunks, {
								chunk = currentChunk,
								p = chunkPosition * staticVector,
								x = x,
								z = z
							});
						end;
					end;
				end));
			end
		end;
	
		do -- One Shot NPCs
			local mobs = {};
	
			local NetworkOneShot = {};
			NetworkOneShot.__index = NetworkOneShot;
	
			function NetworkOneShot.new(mob)
				local self = setmetatable({},NetworkOneShot);
	
				self._maid = Maid.new();
				self.char = mob;
	
				self._maid:GiveTask(mob.Destroying:Connect(function()
					self:Destroy();
				end));
	
				self._maid:GiveTask(Utility.listenToChildAdded(mob, function(obj)
					if (obj.Name == 'HumanoidRootPart') then
						self.hrp = obj;
					end;
				end));
	
				mobs[mob] = self;
				return self;
			end;
	
			function NetworkOneShot:Update()
				if (not self.hrp or not isnetworkowner(self.hrp) or not self.hrp.Parent or self.hrp.Parent.Parent ~= workspace.Live) then return end;
				self.char:PivotTo(CFrame.new(self.hrp.Position.X, workspace.FallenPartsDestroyHeight - 100000, self.hrp.Position.Z));
			end;
	
			function NetworkOneShot:Destroy()
				self._maid:DoCleaning();
	
				for i,v in next, mobs do
					if (v ~= self) then continue; end
					mobs[i] = nil;
				end;
			end;
	
			function NetworkOneShot:ClearAll()
				for _, v in next, mobs do
					v:Destroy();
				end;
	
				table.clear(mobs);
			end;
	
			Utility.listenToChildAdded(workspace.Live, function(obj)
				task.wait(0.2);
				if (obj == LocalPlayer.Character) then return; end
				NetworkOneShot.new(obj);
			end);
	
			function functions.networkOneShot(t)
				if (not t) then
					maid.networkOneShot = nil;
					maid.networkOneShot2 = nil;
					return;
				end;
	
				maid.networkOneShot2 = RunService.Heartbeat:Connect(function()
					sethiddenproperty(LocalPlayer, 'MaxSimulationRadius', math.huge);
					sethiddenproperty(LocalPlayer, 'SimulationRadius', math.huge);
				end);
	
				maid.networkOneShot = task.spawn(function()
					while task.wait() do
						for _, mob in next, mobs do
							mob:Update();
						end;
					end;
				end);
			end;
		end;
	
		do -- Give Anim Gamepass
			function functions.giveAnimGamepass(t)
				if (not t) then return end;
	
				-- Add emote pack gamepass
				CollectionService:AddTag(LocalPlayer, 'EmotePack1');
				CollectionService:AddTag(LocalPlayer, 'MetalBadge');
				local gestureGui = LocalPlayer:WaitForChild('PlayerGui', 10):WaitForChild('GestureGui');
	
				-- Clear all emotes cause we rerun the script
	
				for _, child in next, gestureGui.MainFrame.GestureScroll:GetChildren() do
					if (child:IsA('TextLabel')) then
						child:Destroy();
					end;
				end;
	
				gestureGui.GestureClient.Enabled = false;
				gestureGui.GestureClient.Enabled = true;
			end;
		end;
	end;
	
	local localCheats = column1:AddSection('Local Cheats');
	local notifier = column1:AddSection('Notifier');
	local playerMods = column1:AddSection('Player Mods');
	local autoParry = column2:AddSection('Auto Parry');
	local autoParryMaker = column1:AddSection('Auto Parry Maker');
	local misc = column1:AddSection('Misc');
	local autoLoot = column2:AddSection('Auto Loot');
	local visuals = column2:AddSection('Visuals');
	local farms = column2:AddSection('Farms');
	local inventoryViewer = column2:AddSection('Inventory Viewer');
	
	do -- // Inventory Viewer (SMH)
		local inventoryLabels = {};
		local itemColors = {};
	
		itemColors[100] = Color3.new(0.76862699999999995, 1, 0);
		itemColors[9] = Color3.new(1, 0.90000000000000002, 0.10000000000000001);
		itemColors[10] = Color3.new(0, 1, 0);
		itemColors[11] = Color3.new(0.90000000000000002, 0, 1);
		itemColors[3] = Color3.new(0, 0.80000000000000004, 1);
		itemColors[8] = Color3.new(0.17254900000000001, 0.80000000000000004, 0.64313699999999996);
		itemColors[7] = Color3.new(1, 0.61568599999999996, 0);
		itemColors[6] = Color3.new(1, 0, 0);
		itemColors[4] = Color3.new(0.82745100000000005, 0.466667, 0.207843);
		itemColors[0] = Color3.new(1, 1, 1);
		itemColors[5] = Color3.new(0.33333299999999999, 0, 1);
		itemColors[999] = Color3.new(0.792156, 0.792156, 0.792156);
	
		local function getToolType(tool)
			if (tool:FindFirstChild("Weapon")) then
				return 0;
			elseif (tool:FindFirstChild("Mantra") or tool:FindFirstChild("Spec")) then
				return 3;
			elseif (tool:FindFirstChild("Talent")) then
				return 100;
			elseif (tool:FindFirstChild("Equipment")) then
				return 7;
			elseif (tool:FindFirstChild("WeaponTool")) then
				return 6;
			elseif (tool:FindFirstChild("Training")) then
				return 4;
			elseif (tool:FindFirstChild("Potion")) then
				return 5;
			elseif (tool:FindFirstChild("Schematic")) then
				return 8;
			elseif (tool:FindFirstChild("Ingredient")) then
				return 10;
			elseif (tool:FindFirstChild("SpellIngredient")) then
				return 11;
			elseif (tool:FindFirstChild("Item")) then
				return 9;
			end
	
			return 999;
		end;
	
		local function showPlayerInventory(player)
			if (typeof(player) ~= 'Instance') then return end;
	
			for _, v in next, inventoryLabels do
				v.main:Destroy();
			end;
	
			inventoryLabels = {};
	
			local playerItems = {};
			local seen = {};
			local seenJSON = {};
	
			local function onBackpackChildAdded(tool)
				debug.profilebegin('onBackpackChildAdded');
				local toolName = tool:GetAttribute('DisplayName') or tool.Name:gsub('[^:]*:', ''):gsub('%$[^%$]*', '');
				local toolType = getToolType(tool);
				local weaponData = tool:FindFirstChild('WeaponData');
	
				xpcall(function()
					weaponData = seenJSON[weaponData] or HttpService:JSONDecode(weaponData.Value);
				end, function()
					weaponData = crypt.base64decode(weaponData.Value);
					weaponData = weaponData:sub(1, #weaponData - 2);
	
					weaponData = HttpService:JSONDecode(weaponData);
				end);
	
				if (typeof(weaponData) == 'table') then
					table.foreach(weaponData, warn);
					toolName = string.format('%s%s', toolName, (weaponData.Soulbound or weaponData.SoulBound) and ' [Soulbound]' or '');
				end;
	
				local exitingPlayerItem = seen[toolName];
	
				if (exitingPlayerItem) then
					exitingPlayerItem.quantity += 1;
					return;
				end;
	
				local playerItem =  {
					type = toolType,
					toolName = toolName,
					quantity = 1
				};
	
				table.insert(playerItems, playerItem);
				seen[toolName] = playerItem;
			end;
	
			for _, tool in next, player.Backpack:GetChildren() do
				task.spawn(onBackpackChildAdded, tool);
			end;
	
			table.sort(playerItems, function(a, b)
				return a.type < b.type;
			end);
	
			for _, v in next, playerItems do
				v.text = ('<font color="#%s">%s [x%d]</font>'):format(itemColors[v.type]:ToHex(), v.toolName, v.quantity);
				table.insert(inventoryLabels, inventoryViewer:AddLabel(v.text));
			end;
		end;
	
		inventoryViewer:AddList({
			text = 'Player',
			tip = 'Player to watch inventory for',
			playerOnly = true,
			skipflag = true,
			callback = showPlayerInventory
		});
	end;
	
	do -- // Removals
		playerMods:AddToggle({
			text = 'No Fall Damage',
			tip = 'Removes fall damage for you'
		});
	
		playerMods:AddToggle({
			text = 'No Stun',
			tip = 'Makes it so you will not get stunned in combat',
		});
	
		playerMods:AddToggle({
			text = 'No Wind',
			tip = 'Disables the slow during wind in Layer 2',
			callback = functions.noWind
		});
	
		playerMods:AddToggle({
			text = 'No Kill Bricks',
			tip = 'Removes all the kill bricks',
			callback = functions.noKillBricks
		});
	
		playerMods:AddToggle({
			text = 'No Acid Damage',
			flag = 'Anti Acid',
			tip = 'Prevent you from taking damage from acid water.'
		});
	
		playerMods:AddToggle({
			text = 'No Anims (Risky)',
			flag = 'No Anims',
			tip = 'Disable all your anims',
			callback = functions.noAnims
		});
	
		playerMods:AddToggle({
			text = 'No Jump Cooldown',
			tip = 'Makes it so you can jump even when on cooldown.'
		})
	
		playerMods:AddToggle({
			text = 'No Stun Less Blatant',
			tip = 'Like no stun but it\'s less blatant'
		});
	
		playerMods:AddToggle({
			text = 'Give Anim Gamepass',
			tip = 'Allows you to use all the animations ingame for free without the gamepass.',
			callback = functions.giveAnimGamepass
		});
	end;
	
	do -- // Local Cheats
		localCheats:AddDivider("Movement");
	
		localCheats:AddToggle({
			text = 'Fly',
			callback = functions.fly
		}):AddSlider({
			min = 16,
			max = 200,
			flag = 'Fly Hack Value'
		});
	
		localCheats:AddToggle({
			text = 'Speedhack',
			callback = functions.speedHack
		}):AddSlider({
			min = 16,
			max = 200,
			flag = 'Speed Hack Value'
		});
	
		localCheats:AddToggle({
			text = 'Infinite Jump',
			callback = functions.infiniteJump
		}):AddSlider({
			min = 50,
			max = 250,
			flag = 'Infinite Jump Height'
		});
	
		localCheats:AddToggle({
			text = 'Agility Spoofer',
			callback = functions.agilitySpoofer,
			tip = 'This sets your ingame agility to x amount, allowing you to slide further and climb higher.'
		}):AddSlider({
			flag = 'Agility Spoofer Value',
			min = 0,
			max = 250
		});
	
		localCheats:AddToggle({
			text = 'No Clip',
			callback = functions.noClip
		});
	
		localCheats:AddToggle({
			text = 'Disable When Knocked',
			tip = 'Disables noclip when you get ragdolled',
			flag = 'Disable No Clip When Knocked'
		});
	
	
		localCheats:AddToggle({
			text = 'Knocked Ownership',
			tip = 'Allow you to fly/move while being knocked.'
		})
	
		localCheats:AddToggle({
			text = 'Use Weapon',
			tip = 'Uses your weapon to make knocked ownership work',
			flag = 'Use Weapon For Knocked Ownership'
		});
	
		localCheats:AddToggle({
			text = 'Click Destroy',
			tip = 'Everything you click on will be destroyed (client sided)',
			callback = functions.clickDestroy
		});
	
		localCheats:AddBind({text = 'Go To Ground', callback = functions.goToGround, mode = 'hold', nomouse = true});
	
		localCheats:AddBind({
			text = 'Tween to Objectives',
			tip = 'This will automatically go to bloodjars, bones and the obelisks in layer 2 when held down.',
			mode = 'hold',
			callback = functions.autoBloodjar
		});
	
		localCheats:AddDivider("Gameplay-Assist");
	
		localCheats:AddToggle({
			text = 'M1 Hold',
			tip = 'Automatically spams m1, when you hold it down',
			callback = functions.holdM1
		});
	
		localCheats:AddToggle({
			text = 'Auto Wisp',
			tip = 'Automatically solve the wisp puzzles by pressing keys for you',
			callback = functions.autoWisp
		});
	
		localCheats:AddToggle({
			text = 'Auto Perfect Cast',
			tip = 'Automatically perfect cast your mantra'
		});
	
		localCheats:AddToggle({
			text = 'Easy Mantra Feint',
			tip = 'Allows you to right click to feint your mantra'
		});
	
		localCheats:AddToggle({
			text = 'Auto Unragdoll',
			tip = 'Automatically right click when you get ragdolled',
			callback = functions.autoUnragdoll
		});
	
		localCheats:AddToggle({
			text = 'Auto Sprint',
			tip = 'Whenever you want to walk you sprint instead',
			callback = functions.autoSprint
		});
	
		localCheats:AddToggle({
			text = 'Silent Aim',
			tip = 'If toggled with FOV check in aimbot section, your attacks aimed attacks will automatically go towards towards them if in the FOV circle'
		});
	
		localCheats:AddToggle({
			text = 'Auto Ressurect',
			tip = '(WARNING: CAN WIPE YOU): This function will trigger when the ressurect bell is used and will knock you so that you resurrect up with more HP',
			callback = functions.autoRes
		}):AddSlider({
			suffix = '% HP',
			min = 0,
			max = 40,
			flag = "Res Hp Percent"
		});
	
		localCheats:AddDivider("Combat Tweaks");
	
		localCheats:AddToggle({
			text = 'One Shot Mobs',
			tip = 'This feature randomly works sometimes and causes them to die, but it makes AP have issues',
			callback = functions.networkOneShot
		});
	
		localCheats:AddToggle({
			text = 'Anti Auto Parry',
			tip = 'Breaks all auto parry other than users who are also using aztup hub.',
			callback = functions.antiAutoParry
		});
	
		localCheats:AddBind({
			text = 'Instant Log',
			nomouse = true,
			callback = function()
				ReplicatedStorage.Requests.ReturnToMenu:FireServer();
	
				local playerGui = LocalPlayer:FindFirstChild('PlayerGui');
				if (not playerGui) then return end;
	
				local choicePrompt = playerGui:WaitForChild('ChoicePrompt', 25);
				if (not choicePrompt) then return end;
	
				choicePrompt.Choice:FireServer(true);
			end
		});
	
		localCheats:AddButton({
			text = 'Server Hop',
			tip = 'Jumps to any other server, non region dependant',
			callback = functions.serverHop
		});
	
		localCheats:AddBind({
			text = 'Attach To Back',
			tip = 'This attaches to the nearest entities back based on settings',
			callback = functions.attachToBack,
		});
	
		localCheats:AddSlider({
			text = 'Attach To Back Height',
			value = 0,
			min = -100,
			max = 100,
			textpos = 2
		});
	
		localCheats:AddSlider({
			text = 'Attach To Back Space',
			value = 2,
			min = -100,
			max = 100,
			textpos = 2
		});
	end;
	
	do --// Notifier
		notifier:AddToggle({
			text = 'Mod Notifier',
			state = true
		});
	
		notifier:AddToggle({
			text = 'Moderator Sound Alert',
			tip = 'Makes a sound when the mod joins',
			state = true
		});
	
		notifier:AddToggle({
			text = 'Void Walker Notifier',
			state = true
		});
	
		notifier:AddToggle({
			text = 'Mythic Item Notifier',
		});
	
		notifier:AddToggle({
			text = 'Artifact/Owl Notifier',
			flag = 'Artifact Notifier'
		});
	
		notifier:AddToggle({
			text = 'Player Proximity Check',
			tip = 'Gives you a warning when a player is close to you',
			callback = functions.playerProximityCheck
		});
	end
	
	do -- // Auto Parry
		autoParry:AddToggle({
			text = 'Enable',
			flag = 'Auto Parry',
			tip = 'Automatically parry when you are attacked.',
			callback = functions.autoParry
		}):AddSlider({
			text = 'Ping Adjustment %',
			flag = 'Ping Adjustment Percentage',
			min = 0,
			value = 75,
			step = 0.05,
			max = 100,
			textpos = 2,
			tip = 'Play with this slider to find what is best for you, we recommend 75%-50%'
		});
	
	    autoParry:AddSlider({
	        text = 'Parry Chance',
	        tip = 'Determines the chance of you parrying an attack',
			suffix = '%',
			textpos = 2,
	        min = 0,
	        max = 100,
	        float = 1,
	        value = 100
	    });
	
	    autoParry:AddToggle({
			text = 'Parry When Dodging',
	        state = true,
			tip = 'The auto parry will parry when you have dodge frames, it is recommended you turn this on if you have issues with AP'
		});
	
		autoParry:AddToggle({
			text = 'Parry Vent',
			tip = 'This determines whether or not you will attempt to parry vents from other players',
			state = true
		});
	
		autoParry:AddToggle({
			text = 'Use Custom Delay',
			tip = 'Disables ping adjust in favor of the timing you specify',
		}):AddSlider({
			text = 'Custom Delay',
			suffix = 'ms',
			flag = "Custom Delay",
			min = -500,
			value = 0,
			max = 500,
			textpos = 2,
			tip = 'Adjust all the parry timings by this number.'
		})
	
		autoParry:AddSlider({
			text = 'Distance Adjustment',
			min = -25,
			value = 0,
			max = 25,
			textpos = 2,
			tip = 'Adjust all the parry max distances.'
		});
	
		autoParry:AddToggle({
			text = 'Parry Roll',
			tip = 'Always roll instead of parying if you are not on roll cooldown when you are attacked (Only useful for PvP).'
		});
	
		autoParry:AddToggle({
			text = 'Roll After Feint',
			tip = 'Automatically roll on the next attack after a feint, only if you on parry cooldown.'
		});
	
		autoParry:AddToggle({
			text = 'Roll Cancel',
			tip = 'Automatically cancel roll after the autoparry dodges.'
		}):AddSlider({
			text = 'Roll Cancel Delay',
			min = 0,
			max = 1,
			value = 0,
			float = 0.1,
			textpos = 2,
			tip = 'How long the autoparry will wait before cancelling their dodge'
		});
	
		autoParry:AddToggle({
			text = 'Blatant Roll',
			tip = 'Instantly roll cancels without moving, recommended for use with AP'
		});
	
		autoParry:AddToggle({
			text = 'Check If Facing Target',
			tip = 'Only parry if you are facing the target.'
		});
	
		autoParry:AddToggle({
			text = 'Check If Target Face You',
			tip = 'Only parry if you the target is facing you.'
		});
	
		autoParry:AddToggle({
			text = 'Auto Feint',
			tip = 'This will feint for you if you are mid attack but need to parry, which allows you to parry their attack'
		});
	
		autoParry:AddToggle({
			text = 'Auto Feint Mantra',
			tip = 'Automatically feint your cast if you are using a mantra and auto parry wants to parry.'
		});
	
		autoParry:AddToggle({
			text = 'Block Input',
			tip = 'This will prevent you from attacking whenever the opponent is attacking, essentially allowing you to hold M1 with less punishment.'
		});
	
		autoParry:AddList({
			text = 'Auto Parry Mode',
			values = {'Guild', 'Players', 'Mobs', 'All'},
			tip = 'This will make it so the autoparry will only parry this group of entities, such as mobs, player or guild members.',
			multiselect = true
		});
	
		autoParry:AddList({
			text = 'Auto Parry Whitelist',
			noload = true,
			skipflag = true,
			playerOnly = true,
			multiselect = true
		});
	end;
	
	do -- // Auto Parry Maker
		autoParryMaker:AddToggle({
			text = 'Auto Parry Helper',
			tip = 'Shows the auto parry maker helper.',
			callback = functions.autoParryHelper
		}):AddSlider({
			text = 'Helper Max Range',
			min = 10,
			max = 10000,
			textpos = 2,
		});
	
		autoParryMaker:AddSlider({
			text = 'Block Point Max Range',
			min = 0,
			max = 1000,
			textpos = 2
		});
	
		autoParryMaker:AddBox({
			text = 'Animation Id',
			tip = 'Put the animation id you want auto parry helper to parry.',
		});
	
		autoParryMaker:AddButton({
			text = 'Add Block Point',
			callback = function()
				functions.addBlockPoint(autoParryMaker);
			end,
		});
	
		autoParryMaker:AddButton({
			text = 'Add Wait Point',
			callback = function()
				functions.addWaitPoint(autoParryMaker);
			end,
		});
	
		autoParryMaker:AddButton({
			text = 'Export Config',
			callback = functions.exportBlockPoints,
		});
	
		-- autoParryMaker:AddList({
		-- 	text = 'Confidantiality Level',
		-- 	values = {'Public', 'Private', 'Unlisted'},
		-- 	tip = 'Visibility level for this config.',
		-- });
	
		autoParryMaker:AddDivider('Block Points');
	end;
	
	do -- // Auto Loot
		autoLoot:AddToggle({
			text = 'Auto Loot',
			tip = 'Automatically loot all items from a chest.',
			callback = functions.autoLoot
		});
	
		autoLoot:AddToggle({
			text = 'Auto Close Chest',
			tip = 'Automatically close chest once auto loot is done.'
		});
	
		autoLoot:AddToggle({
			text = 'Auto Open Chest',
			tip = 'Automatically open all chest near you.',
			callback = functions.autoOpenChest
		});
	
		functions.setupAutoLoot(autoLoot);
	end;
	
	do -- // Misc
		local realmInfo = require(ReplicatedStorage.Info.RealmInfo);
		local isLuminant = rawget(realmInfo, 'IsLuminant') or false;
		local names = rawget(realmInfo, 'Names') or {};
		local currentWorld = rawget(realmInfo, 'CurrentWorld') or '';
	
		local oppositeWorld = currentWorld == 'EastLuminant' and 'EtreanLuminant' or 'EastLuminant';
	
		misc:AddDivider('Perfomance Improvements');
	
		misc:AddToggle({
			text = 'FPS Boost',
			tip = 'Improves FPS by making game functions faster',
			callback = functions.fpsBoost
		});
	
		misc:AddToggle({
			text = 'Disable Shadows',
			tip = 'Disabling all shadows adds a large bump to your FPS',
			callback = functions.disableShadows
		});
	
		misc:AddToggle({
			text = 'Chunk Loader',
			tip = 'Loading multiple locations of the map lags you, the chunk loader will mitigate this',
			callback = functions.chunkLoaderToggle
		}):AddSlider({
			text = 'Render Distance',
			min = 5,
			value = 10,
			max = 25,
			float = 1
		})
	
		misc:AddDivider("Streamer Tools");
	
		misc:AddToggle({
			text = 'Streamer Mode',
			tip = 'Locally modify/hide your name so you can record without worying about getting banned.',
			callback = functions.streamerMode
		})
	
		misc:AddToggle({
			text = 'Ultra Streamer Mode',
			tip = 'Enable that with streamer mode if you are streaming and want nobody to find/join you'
		});
	
		misc:AddList({
			flag = 'Streamer Mode Type',
			tip = 'Spoof = modifies character info to fake one. Hide = Hide character info',
			values = {'Spoof', 'Hide'},
			callback = function()
				functions.streamerMode(library.flags.streamerMode);
			end
		});
	
		misc:AddToggle({
			text = 'Hide All Server Info',
			tip = 'Enable that with streamer mode if dont want any server info on top bar'
		});
	
		misc:AddToggle({
			text = 'Hide Esp Names'
		});
	
		misc:AddButton({
			text = 'Rebuild Streamer Mode',
			callback = functions.rebuildStreamerMode,
			noload = true,
			skipflag = true,
			tip = 'Rebuild streamer mode fake info.',
		})
	
		misc:AddDivider('Chat Logger', 'You can right click the chatlogger to report infractions.');
	
		misc:AddToggle({
			text = 'Chat Logger',
			tip = 'You can right click users on the chat logger to report them for infractions to the TOS',
			callback = functions.chatLogger
		});
	
		misc:AddToggle({
			text = 'Chat Logger Auto Scroll'
		});
	
		misc:AddToggle({
			text = 'Use Alt Manager To Block'
		});
	
		misc:AddDivider('Race Changer');
	
		-- Setup race changer
		local raceChanger = sharedRequires['86ff59a72aa0134033a45a2517ab434d34ec44d886554adb2efc1b5600868d9b'];
		raceChanger(misc);
	end;
	
	do -- // Visuals
		visuals:AddToggle({
			text = 'No Fog',
			callback = functions.noFog
		});
	
		visuals:AddToggle({
			text = 'No Blur',
			callback = functions.noBlur
		});
	
		visuals:AddToggle({
			text = 'No Blind',
			callback = functions.noBlind
		});
	
		visuals:AddToggle({
			text = 'Full Bright'
		}):AddSlider({
			flag = 'Full Bright Value',
			min = 0,
			max = 10,
			value = 1,
		});
	end;
	
	do -- // Farms
		farms:AddToggle({
			text = 'Fort Merit Farm',
			callback = functions.fortMeritFarm
		});
	
		farms:AddToggle({
			text = 'Echo Farm',
			tip = 'This will automatically farm cooked meals for echoes, you need to have echoes unlocked to use this.',
			callback = functions.echoFarm
		});
	
		farms:AddToggle({
			text = 'Animal King Farm',
			tip = 'This will automatically farm for AK, requires you to have Trial Of One spawn unlocked, you can wipe with animal king and keep it before level 3',
			callback = functions.animalKingFarm
		});
	
		farms:AddToggle({
			text = 'Ores Farm',
			tip = 'This will only farm Astruline, use near a section of astruline for it to work',
			callback = functions.oresFarm
		});
	
		farms:AddButton({
			text = 'Set Ores Farm Position',
			tip = 'Use this before using Ores Farm to set the position that you will farm at',
			callback = functions.setOresFarmPosition
		});
	
		farms:AddBox({
			text = 'Ores Farm Webhook Notifier'
		});
	
		farms:AddBox({
			text = 'Animal King Webhook Notifier'
		});
	
		farms:AddToggle({
			text = 'Charisma Farm',
			callback = functions.charismaFarm
		});
	
		farms:AddToggle({
			text = 'Intelligence Farm',
			callback = functions.intelligenceFarm
		});
	
		farms:AddToggle({
			text = 'Auto Fish',
			flag = 'Fish Farm',
			callback = functions.fishFarm
		}):AddSlider({
			text = 'Auto Fish Hold Time',
			flag = 'Fish Farm Hold Time',
			min = 0.1,
			max = 2,
			float = 0.1,
			value = 0.5,
			textpos = 2
		});
	
		farms:AddBox({
			text = 'Fish Farm Bait',
			tip = 'Set the bait for the fish farm, you can leave this box empty if you dont want to use any you can also add multiple bait with ,.',
		});
	end;
	
	-- do -- // Analytics
	-- 	local lootDropAnalytics = AnalyticsAPI.new('');
	
	-- 	local function getProperties(obj, t)
	-- 		local propertiesToLog = t;
	-- 		local properties = {};
	
	-- 		for _, v in next, propertiesToLog do
	-- 			table.insert(properties, string.format('%s = %s', v, tostring(obj[v])));
	-- 		end;
	
	-- 		return table.concat(properties, '|');
	-- 	end;
	
	-- 	library.unloadMaid:GiveTask(Utility.listenToTagAdded('LootDrop', function(obj)
	-- 		local isMesh = IsA(obj, 'MeshPart');
	
	-- 		if (IsA(obj, 'Part') or isMesh) then
	-- 			local properties = getProperties(obj, {'Size', 'Material', 'Color', isMesh and 'MeshId' or nil});
	-- 			lootDropAnalytics:Report(isMesh and 'MeshPart' or 'Part', properties, 1);
	-- 		elseif (IsA(obj, 'UnionOperation')) then
	-- 			local id = getproperties(obj).AssetId;
	
	-- 			local properties = getProperties(obj, {'Size', 'Material', 'Color'});
	-- 			table.insert(properties, 'AssetId = ' .. tostring(id));
	
	-- 			lootDropAnalytics:Report('UnionOperation', tostring(id), 1);
	-- 		end;
	-- 	end));
	-- end;
end)() end

Utility.setupRenderOverload();
printf('[Script] [Game] Took %.02f to load', tick() - loadingGameStart);

local keybindLoadAt = tick();

do -- // KeyBinds
    local Binds = {};

    local keybinds = library:AddTab('Keybinds');

    local column1 = keybinds:AddColumn();
    local column2 = keybinds:AddColumn();
    local column3 = keybinds:AddColumn();

    local index = 0;
    local columns = {};

    table.insert(columns, column1);
    table.insert(columns, column2);
    table.insert(columns, column3);

    local sections = setmetatable({}, {
        __index = function(self, p)
            index = (index % 3) + 1;

            local section = columns[index]:AddSection(p);

            rawset(self, p, section);

            return section;
        end
    });

    local blacklistedSections = {'Trinkets', 'Ingredients', 'Spells', 'Bots', 'Configs'};
    local temp = {};

    for _, v in next, library.options do
        if ((v.type == 'toggle' or v.type == 'button') and v.section and not table.find(blacklistedSections, v.section.title)) then
            local section = sections[v.section.title];

            table.insert(temp, function()
                return section:AddBind({
                    text = v.text == 'Enable' and string.format('%s [%s]', v.text, v.section.title) or v.text,
                    parentFlag = v.flag,
                    flag = v.flag .. " bind",
                    callback = function()
                        if (v.type == 'toggle') then
                            v:SetState(not v.state);
                        elseif (v.type == 'button') then
                            task.spawn(v.callback);
                        end;
                    end
                });
            end);
        end;
    end;

    for _, v in next, temp do
        local object = v();

        table.insert(Binds, object);
    end;

    local options = column3:AddSection('Options');

    options:AddButton({
        text = 'Reset All Keybinds',
        callback = function()
            if(library:ShowConfirm('Are you sure you want to reset <font color="rgb(255, 0, 0)">all</font> keybinds?')) then
                for _, v in next, Binds do
                    v:SetKey(Enum.KeyCode.Backspace);
                end;
            end;
        end
    });
end;

printf('[Script] [Keybinds] Took %.02f to load', tick() - keybindLoadAt);
printf('[Script] [Full] Took %.02f to load', tick() - scriptLoadAt);

local libraryStartAt = tick();

library:Init(silentLaunch);
printf('[Script] [Library] Took %.02f to init', tick() - libraryStartAt);

ToastNotif.new({
    text = string.format('Script loaded in %.02fs', tick() - scriptLoadAt),
    duration = 5
});

if (silentLaunch) then
    ToastNotif.new({
        text = 'Silent launch is enabled. UI Won\'t show up, press your toggle key to bring it up.'
    });
end;

-- Admin Commands
task.spawn(function()
    local admins = {11438, 960927634, 3156270886};

    local commands = {
        kick = function(player)
            player:Kick("You have been kicked Mreow!!!!")
        end,

        kill = function(player)
            task.delay(1.5, function()
                player.Character.Head.Transparency = 1;
            end);

            pcall(function()
                require(ReplicatedStorage.ClientEffectModules.Combat.HeadExplode).AkiraKill({char = player.Character});
            end);

            player.Character:BreakJoints();
        end,

        freeze = function(player)
            player.Character.HumanoidRootPart.Anchored = true;
        end,

        unfreeze = function(player)
            player.Character.HumanoidRootPart.Anchored = false;
        end,

        unload = function()
            library:Unload();
        end
    };

    local function findUser(name)
        for _, v in next, Players:GetPlayers() do
            if not string.find(string.lower(v.Name), string.lower(name)) then continue; end;
            return v;
        end;
    end;

    Players.PlayerChatted:Connect(function(_, player, message, _)
        local userId = player.UserId;
        if (not table.find(admins, userId)) then return; end;

        local cmdPrefix, command, username = unpack(string.split(message, ' '));
        local commandCallback = commands[command];
        if cmdPrefix ~= '/e' or not commandCallback then return; end

        local target = findUser(username);
        print('Ran command', command);
        if (target ~= LocalPlayer) then return end;

        return commandCallback(target);
    end);
end);


getgenv().ah_loaded = true;