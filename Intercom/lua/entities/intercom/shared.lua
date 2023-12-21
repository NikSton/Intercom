ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "Intercom" 
ENT.Author = "NikSton" 
ENT.Category = "NikWorks"

ENT.Spawnable = true 
ENT.AdminSpawnable = false 

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "TalkCooldown")
	self:NetworkVar("Int", 1, "TimeLeft")
end