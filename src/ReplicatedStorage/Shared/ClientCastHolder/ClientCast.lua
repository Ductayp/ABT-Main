local ClientCast = {}
local Settings = {
	AttachmentName = 'DmgPoint', -- The name of the attachment that this network will raycast from

	DebugMode = true, -- DebugMode visualizes the rays, from last to current position
	DebugColor = Color3.new(1, 0, 0), -- The color of the visualized ray
	DebugLifetime = 1, -- Lifetime of the visualized trail
	AutoSetup = true -- Automatically creates a LocalScript and a RemoteEvent to establish a connection to the server, from the client.
}

if Settings.AutoSetup then
	require(script.Parent.ClientConnection)(ClientCast)
end

ClientCast.Settings = Settings
ClientCast.InitiatedCasters = {}

function AssertType(Object, ExpectedType, Message)
	if typeof(Object) ~= ExpectedType then
		error(string.format(Message, ExpectedType, typeof(Object)), 4)
	end
end

local DebugColorSequence = Settings.DebugColor
local DebugLifetime = Settings.DebugLifetime

function Settings:GetDebugColor()
	return self.DebugColor
end
function Settings:GetDebugMode()
	return self.DebugMode
end
function Settings:GetDebugLifetime()
	return DebugLifetime
end
function Settings:SetDebugLifetime(Lifetime)
	AssertType(Lifetime, 'number', 'Invalid argument #1 to SetDebugLifetime (%s expected, got %s)')
	DebugLifetime = Lifetime
	self.DebugLifetime = Lifetime
end
function Settings:SetDebugColor(Color)
	AssertType(Color, 'Color3', 'Invalid argument #1 to SetDebugColor (%s expected, got %s)')
	DebugColorSequence = ColorSequence.new(self.DebugColor)
	self.DebugColor = Color
end

local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicationRemote = ReplicatedStorage:FindFirstChild('ClientCast-Replication')

local Maid = require(script.Parent.Maid)
local Connection = require(script.Parent.Connection)

function SerializeParams(Params)
	return {
		FilterDescendantsInstances = {},
		FilterType = Params.FilterType.Name,
		IgnoreWater = Params.IgnoreWater,
		CollisionGroup = Params.CollisionGroup
	}
end
function IsA(Object, Type)
	return typeof(Object) == Type
end
function IsValid(SerializedResult)
	if not IsA(SerializedResult, 'table') then
		return false
	end

	return (SerializedResult.Instance:IsA('BasePart') or SerializedResult.Instance:IsA('Terrain')) and
		IsA(SerializedResult.Position, 'Vector3') and
		IsA(SerializedResult.Material, 'EnumItem') and
		IsA(SerializedResult.Normal, 'Vector3')
end

local Replication = {}
local ReplicationBase = {}
ReplicationBase.__index = ReplicationBase

function ReplicationBase:Connect()
	if typeof(self.Owner) == 'Instance' and self.Owner:IsA('Player') then
		ReplicationRemote:FireClient(self.Owner, 'Connect', {
			Owner = self.Owner, 
			Object = self.Object,
			RaycastParams = SerializeParams(self.RaycastParams),
			Id = self.Caster._UniqueId
		})
		self.Connected = true
		self.Connection = ReplicationRemote.OnServerEvent:Connect(function(Player, Code, RaycastResult, Humanoid)
			if Player == self.Owner and IsValid(RaycastResult) and (Code == 'Any' or Code == 'Humanoid') then
				Humanoid = Code == 'Humanoid' and Humanoid or nil
				for Event in next, self.Caster._CollidedEvents[Code] do
					Event:Invoke(RaycastResult, Humanoid)
				end
			end
		end)
	end
end
function ReplicationBase:Disconnect()
	if typeof(self.Owner) == 'Instance' and self.Owner:IsA('Player') then
		ReplicationRemote:FireClient(self.Owner, 'Disconnect', {
			Owner = self.Owner, 
			Object = self.Object,
			Id = self.Caster._UniqueId
		})
	end
	self.Connected = false
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end
function ReplicationBase:Destroy() 
	self:Disconnect() 
end

function Replication.new(Player, Object, RaycastParameters, Caster)
	return setmetatable({
		Owner = Player,
		Object = Object,
		RaycastParams = RaycastParameters,
		Connected = false,
		Caster = Caster
	}, ReplicationBase)
end

function AssertClass(Object, ExpectedClass, Message)
	AssertType(Object, 'Instance', Message)
	if not Object:IsA(ExpectedClass) then
		error(string.format(Message, ExpectedClass, Object.Class), 4)
	end
end
function IsValidOwner(Value)
	local IsInstance = typeof(Value) == 'Instance'
	if not IsInstance and Value ~= nil then
		error('Unable to cast value to Object', 3)
	elseif IsInstance and not Value:IsA('Player') then
		error('SetOwner only takes player or \'nil\' instance as an argument.', 3)
	end
end

local ClientCaster = {}
local DebugObject = {}

local VisualizedAttachments = {}
local TrailTransparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1)
})

function DebugObject:Disable(Attachment)
	local SavedAttachment = VisualizedAttachments[Attachment]
	if SavedAttachment then
		SavedAttachment.Trail.Enabled = false
	end
end

local OffsetPosition = Vector3.new(0, 0, 0.1)
function DebugObject:Visualize(CasterDebug, Attachment)
	local SavedAttachment = VisualizedAttachments[Attachment]

	if (Settings.DebugMode or CasterDebug) and not SavedAttachment then
		local Trail = Instance.new('Trail')
		local TrailAttachment = Instance.new('Attachment')

		TrailAttachment.Name = 'DebugAttachment'
		TrailAttachment.Position = Attachment.Position - OffsetPosition

		Trail.Color = DebugColorSequence
		Trail.LightEmission = 1
		Trail.Transparency = TrailTransparency
		Trail.FaceCamera = true
		Trail.Lifetime = DebugLifetime

		Trail.Attachment0 = Attachment
		Trail.Attachment1 = TrailAttachment

		Trail.Parent = TrailAttachment
		TrailAttachment.Parent = Attachment.Parent

		VisualizedAttachments[Attachment] = TrailAttachment
	elseif SavedAttachment then
		if not Settings.DebugMode and not CasterDebug then
			SavedAttachment:Destroy()
			VisualizedAttachments[Attachment] = nil
		elseif not SavedAttachment.Trail.Enabled then
			SavedAttachment.Trail.Enabled = true
		end
	end
end

local CollisionBaseName = {
	Collided = 'Any',
	HumanoidCollided = 'Humanoid'
}

function ClientCaster:Start()
	if self._ReplicationConnection and not self._ReplicationConnection.Connected then
		self._ReplicationConnection:Connect()
	end
	ClientCast.InitiatedCasters[self] = {}
end
function ClientCaster:Destroy()
	if self._ReplicationConnection then
		self._ReplicationConnection:Destroy()
	end
	ClientCast.InitiatedCasters[self] = nil
	self.RaycastParams = nil
	self.Object = nil

	self._Maid:Destroy()
end
function ClientCaster:Stop()
	ClientCast.InitiatedCasters[self] = nil
end
function ClientCaster:SetOwner(NewOwner)
	IsValidOwner(NewOwner)
	local OldConn = self._ReplicationConnection
	local ReplConn = NewOwner ~= nil and Replication.new(NewOwner, self.Object, self.RaycastParams, self)
	self._ReplicationConnection = ReplConn

	if OldConn then
		OldConn:Destroy()
	end
	self.Owner = NewOwner

	if NewOwner ~= nil and ReplConn then
		ReplConn:Connect()
	end
	for _, Attachment in next, self.Object:GetChildren() do
		if Attachment.ClassName == 'Attachment' and Attachment.Name == Settings.AttachmentName then
			DebugObject:Disable(Attachment)
		end
	end
end
function ClientCaster:GetOwner()
	return self.Owner
end
function ClientCaster:SetObject(Object)
	AssertType(Object, 'Instance', 'Unexpected argument #1 to \'ClientCaster:SetObject\' (%s expected, got %s)')
	self.Object = Object
	ClientCaster:SetOwner(self.Owner)
end
function ClientCaster:GetObject()
	return self.Object
end
function ClientCaster:EditRaycastParams(RaycastParameters)
	self.RaycastParams = RaycastParameters
	ClientCaster:SetOwner(self.Owner)
end
function ClientCaster:Debug(Bool)
	self.Debug = Bool
	ClientCaster:SetOwner(self.Owner)
end
function ClientCaster:__index(Index)
	local CollisionIndex = CollisionBaseName[Index]
	if CollisionIndex then
		local CollisionEvent = Connection.new()
		self._CollidedEvents[CollisionIndex][CollisionEvent] = true

		return CollisionEvent.Invoked
	end

	return ClientCaster[Index]
end

local UniqueId = 0
function GenerateId()
	UniqueId += 1
	return UniqueId
end
function ClientCast.new(Object, RaycastParameters, NetworkOwner)
	IsValidOwner(NetworkOwner)
	AssertType(Object, 'Instance', 'Unexpected argument #2 to \'CastObject.new\' (%s expected, got %s)')
	AssertType(RaycastParameters, 'RaycastParams', 'Unexpected argument #3 to \'CastObject.new\' (%s expected, got %s)')
	
	local MaidObject = Maid.new()
	local CasterObject = setmetatable({
		RaycastParams = RaycastParameters,
		Object = Object,
		Debug = false,
		Owner = NetworkOwner,

		_CollidedEvents = {
			Humanoid = {},
			Any = {}
		},
		_ToClean = {},
		_Maid = MaidObject,
		_ReplicationConnection = false,
		_UniqueId = GenerateId()
	}, ClientCaster)
	CasterObject._ReplicationConnection = NetworkOwner ~= nil and Replication.new(NetworkOwner, Object, RaycastParameters, CasterObject)

	MaidObject:GiveTask(CasterObject)
	return CasterObject
end

function UpdateCasterEvents(Caster, RaycastResult)
	if RaycastResult then
		for CollisionEvent in next, Caster._CollidedEvents.Any do
			CollisionEvent:Invoke(RaycastResult)
		end

		local ModelAncestor = RaycastResult.Instance:FindFirstAncestorOfClass('Model')
		local Humanoid = ModelAncestor and ModelAncestor:FindFirstChildOfClass('Humanoid')
		if Humanoid then
			for HumanoidEvent in next, Caster._CollidedEvents.Humanoid do
				HumanoidEvent:Invoke(RaycastResult, Humanoid)
			end
		end
	end
end
function UpdateAttachment(Attachment, Caster, LastPositions)
	if Attachment.ClassName == 'Attachment' and Attachment.Name == Settings.AttachmentName then
		local CurrentPosition = Attachment.WorldPosition
		local LastPosition = LastPositions[Attachment] or CurrentPosition

		if CurrentPosition ~= LastPosition then
			local RaycastResult = workspace:Raycast(CurrentPosition, CurrentPosition - LastPosition, Caster.RaycastParams)

			UpdateCasterEvents(Caster, RaycastResult)
			DebugObject:Visualize(Caster.Debug, Attachment)
		end

		LastPositions[Attachment] = CurrentPosition
	end
end
RunService.Heartbeat:Connect(function()
	for Caster, LastPositions in next, ClientCast.InitiatedCasters do
		if Caster.Owner == nil then
			for _, Attachment in next, Caster.Object:GetChildren() do
				UpdateAttachment(Attachment, Caster, LastPositions)
			end
		end
	end
end)

return ClientCast