include("shared.lua")

local create_font = surface.CreateFont
create_font("Intercom_Text", {
  font = "Tahoma",
  extended = false,
  size = 20,
  weight = 1000,
  antialias = true,
} )

local function NikBox(x, y, w, h, color)
	local surface_color = surface.SetDrawColor
	local rect = surface.DrawRect
    surface_color(color)
    rect(x, y, w, h)
end

local function NikRect(x, y, w, h, t)
	if not t then t = 1 end
	local rect = surface.DrawRect
	rect(x, y, w, t)
	rect(x, y + (h - t), w, t)
	rect(x, y, t, h)
	rect(x + (w - t), y, t, h)
end

local function NikDrawOutlines(x, y, w, h, col, thickness)
	local surface_color = surface.SetDrawColor
	surface_color(col)
	NikRect(x, y, w, h, thickness)
end

local function NikShadowText(text, font, x, y, col1, col2, align)
	if align != 0 then
		local draw_text = draw.DrawText
		draw_text(text, font, x + 1, y + 1, col2, align) 
		draw_text(text, font, x, y, col1, align)
	else
		local surface_font = surface.SetFont
		local surface_color = surface.SetTextColor
		local surface_text = surface.DrawText
		local surface_pos = surface.SetTextPos
		surface_font(font)
		surface_color(col2)
		surface_pos(x + 1, y + 1)
		surface_text(text)
		surface_color(col1)
		surface_pos(x, y)
		surface_text(text)
	end
end

function ENT:Draw()
	self:DrawModel()
    local pos = self:GetPos()
	local ang = self:GetAngles()
	local distance = LocalPlayer():GetPos():Distance(self:GetPos())
	local Start3D2D = cam.Start3D2D
	local End3D2D = cam.End3D2D
	ang:RotateAroundAxis(ang:Up(), 50);
	ang:RotateAroundAxis(ang:Forward(), 90);
	if distance < 900 then
    Start3D2D(self:LocalToWorld(Vector(-14, -22, 6)), self:LocalToWorldAngles(Angle(0, 90, 0)), 0.4)
	NikBox(-63, -24, 236, 118, Color(35, 35, 35, 255))
	NikDrawOutlines(-63, -24, 236, 118, Color(255, 255, 255, 255))
		NikShadowText("Intercom", 'Intercom_Text', 54, -4, Color(255,255,255), Color(0, 0, 0), 1, 1)
		if self.enable then
			NikShadowText("We broadcast - " .. math.max(0, math.floor(self:GetTimeLeft() - CurTime())), 'Intercom_Text', 54, 56, Color(255, 157, 0), Color(0, 0, 0), 1, 1)
			NikShadowText("Data transfer...", 'Intercom_Text',  54, 16, Color(255, 157, 0), Color(0, 0, 0), 1, 1)
		else
			if self:GetTalkCooldown() > CurTime() then
				NikShadowText("Reboot - " .. math.Round(self:GetTalkCooldown() - CurTime()), "Intercom_Text", 54, 56, Color(200,0,0), Color(0, 0, 0), 1, 1)
				NikShadowText("System not connected!", 'Intercom_Text',  54, 16, Color(200,0,0), Color(0, 0, 0), 1, 1)
			else
				NikShadowText("Ready to broadcast!", 'Intercom_Text',  54, 56, Color(0, 200, 0), Color(0, 0, 0), 1, 1)
				NikShadowText("System connected!", 'Intercom_Text',  54, 16, Color(0, 200, 0), Color(0, 0, 0), 1, 1)
			end
		end
	End3D2D()
	end
end

local sound_func = EmitSound
local start_sound = Sound("intercom/start.wav")
local end_sound = Sound("intercom/end.wav")
net.Receive("intercom.sound", function()
	local start = net.ReadBool()
	local ent = net.ReadEntity()
	ent.enable = start
	local needsound
	if start then
		needsound = start_sound
	else
		needsound = end_sound
	end
	sound_func(needsound, Vector(), -1, CHAN_AUTO, 1, 50, 0, 100)
end)

net.Receive("intercom.chat", function()
    local mode = net.ReadUInt(4)
	local player_text = net.ReadString()
    local text = ""

    if mode == 0 then
        text = "Broadcast started!"
    elseif mode == 1 then
        text = "Broadcast ended!"
	elseif mode == 2 then
        text = player_text
    end

    text = "" .. text .. " - "

	local chat_text = chat.AddText

    chat_text(
        Color(255, 255, 255),    "[",
        Color(0, 255, 0),     "Intercom",
        Color(255, 255, 255),    "] ",
        Color(255, 255, 255), text,
        Color(255, 100, 100), os.date("%H:%M", os.time())
    )
end)
