include("shared.lua")

surface.CreateFont("TheDefaultSettings", {
	font = "Arial",
	size = 13,
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


function ENT:Draw()
	self:DrawModel()
	
end

