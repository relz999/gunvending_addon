include("shared.lua")

surface.CreateFont("Defaults", {
	font = "Arial",
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
local draw = draw

function ENT:Draw()
	 local ang = self:GetAngles()
	-- Position as floating above model vertically.
	ang:RotateAroundAxis(self:GetAngles():Up() ,90)
	ang:RotateAroundAxis(self:GetAngles():Right() ,270)
	self:DrawModel()
	local owner = self:Getowning_ent()
	-- Position Above model.
	cam.Start3D2D(self:GetPos()  + (ang:Up() *0) + (ang:Right() * -30), ang, 0.1)
	draw.RoundedBox(25, -225, -190, 450, 370, Color(59, 59, 69, 190))
	surface.SetFont("Defaults")
	-- Text to display on rounded box.
	draw.DrawText("Gun Vending Machine", "Defaults", -150, -190, Color(255, 255, 255, 255))
	draw.DrawText("Number Remaining: "..self:GetShipmentSize(), "Defaults", -150, -160, Color(255, 255, 255, 255))
	draw.DrawText("Gun: "..self:GetGunName(), "Defaults", -150, -25, Color(255, 255, 255, 255))
	draw.DrawText("Gun Price: "..DarkRP.formatMoney(self:GetGunPrice(GunName)), "Defaults", -150, -50, Color(255, 255, 255, 255))
	draw.DrawText("Use (E) To buy Gun", "Defaults", -150, 0, Color(255, 255, 255, 255))
	cam.End3D2D()


end

