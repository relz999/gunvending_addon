AddCSLuaFile("shared.lua")
include("shared.lua")
-- Set intial values
gunType = ""
canBuy = true







function ENT:Initialize()
	-- Model of vending machine
	self:SetModel("models/props_interiors/vendingmachinesoda01a_door.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.isRunning = false
	self.DarkRPCanLockpick = true
	-- Make entity a fading door to fudge allowing it to be lockpicked // Credit to Apollo for idea.
	self.isFadingDoor = true;
	self.fadeActivate = false
	self.fadeDeactivate = true
	self.fadeToggleActive = true
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.isVending = false
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "spawned_shipment" and self.isVending == false then
		-- Key shipment details
        GunType = CustomShipments[ent:Getcontents()].entity
        ShipmentSize = CustomShipments[ent:Getcontents()].amount
        GunPrice = CustomShipments[ent:Getcontents()].price
        GunName = CustomShipments[ent:Getcontents()].name
        -- Debug Information
		print(CustomShipments[ent:Getcontents()].name)
		print(CustomShipments[ent:Getcontents()].entity)
		print(CustomShipments[ent:Getcontents()].model)
		print(CustomShipments[ent:Getcontents()].price)
		print(CustomShipments[ent:Getcontents()].amount)
		print(GunType)
		ent:Remove()
		self.isVending = true
	end
end

function ENT:Use(act, caller)
-- Check 5 second rebuy timer has expired
if canBuy == true then
-- Check that player has enough money to buy gun, else provide chat message to say they can't
if caller:canAfford(GunPrice) then			
	if ShipmentSize > 0 then
		-- Take money from player
		caller:addMoney(GunPrice * -1)
		local gun = ents.Create(GunType)
		gun:SetPos(self:GetPos() + Vector(0,0,25))
		gun:Spawn()
		canBuy = false
		-- Reduce number of guns left in vending machine.
		ShipmentSize = ShipmentSize - 1
		-- 5 second rebuy timer
		timer.Simple(5, function()
		canBuy = true 
		end)


		if ShipmentSize == 0 then
			-- Resets ability to load more shipments into the vending machine.
			self.isVending = false
			return
		end
			caller:ChatPrint("Thank you for your purchase, enjoy your ("..GunName..")")
		return
	end
else
	caller:ChatPrint("You do not have enough funds to purchase. Please have atleast ("..GunPrice..")")
	return
end 

end
return
end


function ENT:Think()
	if self.isVending == true then
		self:SetColor(Color(255,0,0))
	else
		self:SetColor(Color(0,225,0))
	end
-- if self.isVending == true then
-- 	if self.finishVendTime <= CurTime() then
-- 		self.isVending = false

-- 		local gun = ents.Create(GunType)
-- 		gun:SetPos(self:GetPos() + Vector(0,0,25))
-- 		gun:Spawn()
-- 	end
end
-- Function and Hook to dispense a gun if lockpicked.
function DepositGun(ply, success, ent)

	-- if successfully picked 
	if success == true then
		local gun = ents.Create(GunType)
		gun:SetPos(ent:GetPos() + Vector(0,0,25))
		gun:Spawn()
	end
end
-- Hook for completed lockpick.
hook.Add("onLockpickCompleted", "UniqueName", DepositGun)