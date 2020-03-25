AddCSLuaFile("shared.lua")
include("shared.lua")
-- Set intial values
local canBuy = true
local AlarmExists = false
local AlarmUsesNumber = 0

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
	-- Set networkvar's
	self:SetGunType("")
	self:SetShipmentSize(0)
	self:SetGunPrice(0)
	self:SetGunName("")

end

function ENT:StartTouch(ent)
	print(ent:GetClass())
	if ent:GetClass() == "spawned_shipment" and self.isVending == false then
		ent:Setowning_ent(ent.Owner)

		-- Debug Information
		print(CustomShipments[ent:Getcontents()].name)
		print(CustomShipments[ent:Getcontents()].entity)
		print(CustomShipments[ent:Getcontents()].model)
		print(CustomShipments[ent:Getcontents()].price)
		print(CustomShipments[ent:Getcontents()].amount)
		-- Key shipment details
		local ShipmentSize = CustomShipments[ent:Getcontents()].amount
		local GunPrice = CustomShipments[ent:Getcontents()].price
		local GunName = CustomShipments[ent:Getcontents()].name
		self:SetShipmentSize(ShipmentSize)
        self:SetGunPrice(GunPrice)
        self:SetGunName(GunName)

		vGunType = CustomShipments[ent:Getcontents()].entity
		print("what is this? "..vGunType)
        self:SetGunType(vGunType)
        print("what is this also? "..self:GetGunType())
        
        print("Networkvar Debug")
        print(self:GetGunType())
        print(self:GetShipmentSize())
        print(self:GetGunPrice())
		print(self:GetGunName())
		ent:Remove()
		self.isVending = true

		elseif ent:GetClass() == "alarm_addon" then
		print("Alarm be adding")
		if AlarmExists == false then
			AlarmExists = true
			AlarmUsesNumber = 3
			ent:Remove()	
		else
			print("You already have an alarm fitted")
		end
	end
end

function ENT:Use(act, caller)
-- Check 5 second rebuy timer has expired
if canBuy == true then
-- Check that player has enough money to buy gun, else provide chat message to say they can't
if caller:canAfford(self:GetGunPrice()) then			
	if self:GetShipmentSize() > 0 then
		-- Take money from player
		caller:addMoney(self:GetGunPrice() * -1)
		local GuntoVend = self:GetGunType()
		print("NetVar "..self:GetGunType())
		print("varible "..GuntoVend)
		local gun = ents.Create(GuntoVend)
		gun:SetPos(self:GetPos() + Vector(0,0,25))
		gun:Spawn()
		canBuy = false
		-- Reduce number of guns left in vending machine.
		self:SetShipmentSize(self:GetShipmentSize() - 1)
		-- 5 second rebuy timer
		timer.Simple(5, function()
		canBuy = true 
		end)


		if self:GetShipmentSize() == 0 then
			-- Resets ability to load more shipments into the vending machine.
			DarkRP.notify(self:Getowning_ent(), 1, 4, "All your guns are now sold, refill the vending machine.")
			self.isVending = false
			return
		end
			DarkRP.notify(self:Getowning_ent(), 1, 4, "You sold another gun!")
			caller:ChatPrint("Thank you for your purchase, enjoy your ("..self:GetGunName()..")")
		return
	end
else
	caller:ChatPrint("You do not have enough funds to purchase. Please have atleast ("..self:GetGunPrice()..")")
	return
end 

end
return
end


function ENT:Think()
	
end
-- Function and Hook to dispense a gun if lockpicked.
function DepositGun(ply, success, ent)

	-- if successfully picked and there are guns left
	if success == true && ent:GetShipmentSize() ~= 0 then
		local gun = ents.Create(ent:GetGunType())
		gun:SetPos(ent:GetPos() + Vector(0,0,25))
		gun:Spawn()
		ent:SetShipmentSize(ent:GetShipmentSize() - 1)
		DarkRP.notify(ent:Getowning_ent(), 1, 4, "Someone lockpicked your vending machine!!")
		if ply:isWanted() == false then
		ply:wanted(ent:Getowning_ent(),"Stealing Gun from vending machine!!")
	end
	end
end

-- Function and Hook to check alarm when lockpicked
function RunAlarm(ply, ent, table)
	if AlarmExists == true && AlarmUsesNumber ~= 0 then
	ply:wanted(ent:Getowning_ent(),"Stealing Gun from vending machine!!")
	ent:StartLoopingSound("school_alarm.mp3")
	AlarmUsesNumber = AlarmUsesNumber - 1	
	if AlarmUsesNumber == 0 then
		AlarmExists = false
	end
	end
end
-- Hook for completed lockpick.
hook.Add("onLockpickCompleted", "UniqueName1", DepositGun)
-- Hook for lockpick started
hook.Add("lockpickStarted", "UniqueName2", RunAlarm)