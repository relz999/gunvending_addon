include("shared.lua")
gunpricenow = 0
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
	draw.DrawText("Gun Price: "..DarkRP.formatMoney(self:GetGunSellPrice()), "Defaults", -150, -50, Color(255, 255, 255, 255))
	draw.DrawText("Use (E) To buy Gun", "Defaults", -150, 0, Color(255, 255, 255, 255))
	cam.End3D2D()

	-- Set Gun Details for Derma.
	Gunmodel = self:GetGunModel()
	GunPrice = self:GetGunPrice()
	GunName = self:GetGunName()
	GunType = self:GetGunType()
	GunSellPrice = self:GetGunSellPrice()
	ShipmentSize = self:GetShipmentSize()
	ShipmentSizeOrig = self:GetShipmentSizeOrig()
	ShipmentPctLeft = (ShipmentSize / ShipmentSizeOrig)
	GunsSold = ShipmentSizeOrig - ShipmentSize
	Profit = (GunSellPrice * GunsSold) - (GunPrice * ShipmentSize)
	-- Updates with gun price set in derma
	self:SetGunSellPrice(gunpricenow)

end

-- Derma Menu to allow Owner to set prices etc.
net.Receive("OwnerMenu", function()
	
	--DebugInfo
	print(ShipmentSize)
	print(ShipmentSizeOrig)
	print(ShipmentPctLeft)

	local Frame = vgui.Create( "DFrame" )
	--Used suggested best practice from Gmod wiki on scaling window.
	--Frame:SetSize( ScrW() * 0.416, ScrH() * 0.554 )
	Frame:SetPos( 0.32083333333333 * ScrW(), 0.16666666666667 * ScrH() )
	Frame:SetSize( 0.26458333333333 * ScrW(), 0.33981481481481 * ScrH() )
	Frame:SetTitle( "Gun Vending Machine Owner Menu" ) 
	Frame:SetVisible( true ) 
	--Frame:Center()
	Frame:SetDraggable( true ) 
	Frame:ShowCloseButton( true )
	Frame:MakePopup()

	-- Show model of gun currently in vending machine.
	local icon = vgui.Create( "DModelPanel", Frame )
	--icon:SetPos( 1, 1 )
	--icon:SetSize( 200, 200 )
	icon:SetPos( 0.062992125984252 * Frame:GetWide(), 0.13896457765668 * Frame:GetTall() )
	icon:SetSize( 0.44291338582677 * Frame:GetWide(), 0.54223433242507 * Frame:GetTall() )
	icon:SetModel( Gunmodel )
	function icon:LayoutEntity( Entity ) return end -- disables default rotation
	function icon.Entity:GetPlayerColor() return Vector (1, 0, 0) end 
	-- Text input.
	TextEntry = vgui.Create( "DTextEntry", Frame )
	TextEntry:SetPos( 0.55708661417323 * Frame:GetWide(), 0.30245231607629 * Frame:GetTall() )
	TextEntry:SetSize( 0.39370078740157 * Frame:GetWide(), 0.05449591280654 * Frame:GetTall() )
	TextEntry:SetValue( GunSellPrice )
	TextEntry.OnEnter = function( self )
	gunpricenowtemp = self:GetValue()	-- print the form's text as server text
	end
	-- Progress bar used to show stock level.
	local DProgress = vgui.Create( "DProgress", Frame )
	DProgress:SetPos( 0.062992125984252 * Frame:GetWide(), 0.71934604904632 * Frame:GetTall() )
	DProgress:SetSize( 0.88779527559055 * Frame:GetWide(), 0.12261580381471 * Frame:GetTall() )
	DProgress:SetFraction( ShipmentPctLeft )			

				
	local DLabel1 = vgui.Create( "DLabel", Frame )
	DLabel1:SetPos( 0.55708661417323 * Frame:GetWide(), 0.13896457765668 * Frame:GetTall() )
	DLabel1:SetSize( 0.39370078740157 * Frame:GetWide(), 0.05449591280654 * Frame:GetTall() )
	DLabel1:SetText( "Gun: "..GunName )
				
	local DLabel2 = vgui.Create( "DLabel", Frame )
	DLabel2:SetPos( 0.062992125984252 * Frame:GetWide(), 0.86920980926431 * Frame:GetTall() )
	DLabel2:SetSize( 0.88779527559055 * Frame:GetWide(), 0.05449591280654 * Frame:GetTall() )
	DLabel2:SetText( "You have sold ".. GunsSold .. " of " ..  ShipmentSizeOrig .. ". You have made " .. DarkRP.formatMoney(Profit) .. " Profit")
				
	local Dbutton1 = vgui.Create( "DButton", Frame )
	Dbutton1:SetPos( 0.55708661417323 * Frame:GetWide(), 0.46866485013624 * Frame:GetTall() )
	Dbutton1:SetSize( 0.39370078740157 * Frame:GetWide(), 0.08991825613079 * Frame:GetTall() )
	Dbutton1:SetText( "Update Price" )
	Dbutton1.DoClick = function()
	gunpricenow = TextEntry:GetValue()
	Frame:Remove()
	end
				
	local DButton2 = vgui.Create( "DButton", Frame )
	DButton2:SetPos( 0.55708661417323 * Frame:GetWide(), 0.57765667574932 * Frame:GetTall() )
	DButton2:SetSize( 0.39370078740157 * Frame:GetWide(), 0.079019073569482 * Frame:GetTall() )
	DButton2:SetText( "Close" )
	DButton2.DoClick = function()
	Frame:Remove()
	end
				
	local DLabel3 = vgui.Create( "DLabel", Frame )
	DLabel3:SetPos( 0.55708661417323 * Frame:GetWide(), 0.23160762942779 * Frame:GetTall() )
	DLabel3:SetSize( 0.39370078740157 * Frame:GetWide(), 0.05449591280654 * Frame:GetTall() )
	DLabel3:SetText( "Base Price: ".. DarkRP.formatMoney(GunPrice) )			

	end)