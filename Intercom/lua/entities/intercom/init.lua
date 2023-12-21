AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("intercom.sound")
util.AddNetworkString("intercom.chat")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube1x2x025.mdl");
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetMaterial("models/debug/debugwhite")	
	self:SetColor(Color(0,0,0))
    local phys = self:GetPhysicsObject()
    if(phys:IsValid()) then phys:Wake() end
    self.talkers = {}
    self.Active = false
end

local talkers = {}
hook.Add("PlayerCanHearPlayersVoice", "intercom.hearplayers", function(listner, talker)
	if talkers[talker] then return true end
end)

function ENT:Start()
	self.Active = true
	self:SetTimeLeft(CurTime() + 120)
	self:SetNWBool("intercom_allowedchat", true)
	timer.Create("intercom.stop" .. self:EntIndex(), 120, 1, function()
		if !IsValid(self) then return end
		if self.Active then
			self:Stop()
			self:SetTalkCooldown(CurTime() + 120)
		end
	end)

	for k, v in pairs(player.GetAll()) do 
		net.Start("intercom.chat")
        net.WriteUInt(0, 4)
        net.Broadcast()
	end

	net.Start("intercom.sound")
	net.WriteBool(true)
	net.WriteEntity(self)
	net.Broadcast()
end

function ENT:Stop()
	self.Active = false
	self:SetTalkCooldown(CurTime() + 120)
	self:SetTimeLeft(0)
	for k,v in pairs(self.talkers) do
		talkers[k] = nil
	end
	
	for k, v in pairs(player.GetAll()) do 
		net.Start("intercom.chat")
        net.WriteUInt(1, 4)
        net.Broadcast()
	end
	
	table.Empty(self.talkers)
	net.Start("intercom.sound")
	net.WriteBool(false)
	net.WriteEntity(self)
	net.Broadcast()
end

hook.Add("PlayerSay", "intercom.playerchat", function(ply, text)
    local args = string.Explode(" ", text)
	local argument = string.lower(args[1])
	if ply:GetNWBool("intercom_allowedchat") then
	if argument != "/itchat" then return end
	local text = table.concat(args, " ", 2, #args)
	if text != "" then
	    for k, v in pairs(player.GetAll()) do
		     net.Start("intercom.chat")
             net.WriteUInt(2, 4)
		     net.WriteString(ply:Name() .. " - " .. text)
             net.Send(v)
				return ""
			end
		else
			 return ""
		 end
	 end
end)

function ENT:Use(activator, caller)
	if self:GetTalkCooldown() > CurTime() and self.Active == false then return false end
	if self.Active then
		self:Stop()
		activator:SetNWBool("intercom_allowedchat", false)
	else
		self:Start()
		activator:SetNWBool("intercom_allowedchat", true)
	end
end 

function ENT:Think()
	self:NextThink(CurTime() + 0.5)
	if !self.Active then return true end
	for k,v in pairs(self.talkers) do
		if k:GetPos():Distance(self:GetPos()) > 100 then
			self.talkers[k] = nil
			talkers[k] = nil
		end
	end
	for k,v in pairs(player.GetAll()) do
		if !self.talkers[v] and v:GetPos():Distance(self:GetPos()) < 100 then
			self.talkers[v] = true
		end
	end
	table.Merge(talkers, self.talkers)
	return true
end