AddCSLuaFile("shared.lua")
include("shared.lua")
-- Set intial values



function ENT:Initialize()

	-- Model of vending machine
	self:SetModel("models/Items/ammocrate_ar2.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self.Entity:SetUseType( SIMPLE_USE )
	self:SetUseType(SIMPLE_USE)
	self.DarkRPCanLockpick = true
	-- Make entity a fading door to fudge allowing it to be lockpicked // Credit to Apollo for idea.
	self.isFadingDoor = true;
	self.fadeActivate = false
	self.fadeDeactivate = true
	self.fadeToggleActive = true
	self.m_bInitialized = true
	-- Moved under initialise so that each vending machine holds variables for Alarm fitted, etc 
	-- Issue noted in conversation with Hydro.
	self.canBuy = true
	self.AlarmExists = false
	self.AlarmUsesNumber = 0
	self.FiretrapExists = false
	self.FiretrapUsesNumber = 0

	self.Profit = 0
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
	self:SetVendOwner(ply)

end


function ENT:StartTouch(ent)

	if ent:GetClass() == "spawned_shipment" and self.isVending == false then
		-- Debug Information
		print(CustomShipments[ent:Getcontents()].name)
		print(CustomShipments[ent:Getcontents()].entity)
		print(CustomShipments[ent:Getcontents()].model)
		print(CustomShipments[ent:Getcontents()].price)
		print(CustomShipments[ent:Getcontents()].amount)
		-- Key shipment details
		local ShipmentSize = CustomShipments[ent:Getcontents()].amount
		-- Mark up prices by 20%
		local GunPrice = CustomShipments[ent:Getcontents()].price * 1.2
		local GunName = CustomShipments[ent:Getcontents()].name
		self:SetShipmentSize(ShipmentSize)
		self:SetGunPrice(GunPrice)
		self:SetGunName(GunName)
		vGunType = CustomShipments[ent:Getcontents()].entity
		self:SetGunType(vGunType)
		-- Networkvar output to allow me to test and understand the usage.
		print("Networkvar Debug")
		print(self:GetGunType())
		print(self:GetShipmentSize())
		print(self:GetGunPrice())
		print(self:GetGunName())
		-- Remove Shipment
		ent:Remove()
		self.isVending = true
		--
		-- Second Touch Condition to check for alarm addon.
		--
		elseif ent:GetClass() == "alarm_addon" then
		print("Alarm has been installed")
		if self.AlarmExists == false then
			self.AlarmExists = true
			self.AlarmUsesNumber = 3
			ent:Remove()	
		else
			print("You already have an alarm fitted")
		end
		elseif ent:GetClass() == "firetrap_addon" then
		print("Firetrap has been installed")
		if self.FiretrapExists == false then
			self.FiretrapExists = true
			self.FiretrapUsesNumber = 1
			ent:Remove()	
		else
			print("You already have an alarm fitted")
		end
	end
end

function ENT:Use(activator, caller)

-- Check 5 second rebuy timer has expired
if self.canBuy == true && IsValid(caller) && activator:IsPlayer() then
-- Check that player has enough money to buy gun, else provide chat message to say they can't
if caller:canAfford(self:GetGunPrice()) then			
	if self:GetShipmentSize() > 0 then
		-- Take money from player
		caller:addMoney(-self:GetGunPrice())
		self.Profit = self.Profit + self:GetGunPrice()
		--self.profit = self.profit + self:GetGunPrice()
		local GuntoVend = self:GetGunType()
		-- Debug info
		print("NetVar "..self:GetGunType())
		print("varible "..GuntoVend)
		local gun = ents.Create(GuntoVend)
		gun:SetPos(self:GetPos() + Vector(0,0,25))
		gun:Spawn()
		self.canBuy = false
		-- Reduce number of guns left in vending machine.
		self:SetShipmentSize(self:GetShipmentSize() - 1)
		-- 5 second rebuy timer
		timer.Simple(5, function()
		self.canBuy = true 
		end)

		local owner = self:Getowning_ent()
		
		owner:addMoney(100000)
		


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
	caller:ChatPrint("You do not have enough funds to purchase. Please have atleast ("..DarkRP.formatMoney(self:GetGunPrice())..")")
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
		
		ply:wanted(ent:Getowning_ent(),"Stealing Gun from vending machine!!")
	
	end
end

-- Function and Hook to check alarm when lockpicked
function RunAlarmFire(ply, ent, table)
	if ent.FiretrapExists == true && ent.FiretrapUsesNumber ~= 0 && ent.AlarmExists == true && AlarmUsesNumber ~= 0 then
	-- Alarm initiated.
	ply:wanted(ent:Getowning_ent(),"Stealing Gun from vending machine!!")
	ent:StartLoopingSound("school_alarm.mp3")
	ent.AlarmUsesNumber = ent.AlarmUsesNumber - 1	
	if ent.AlarmUsesNumber == 0 then
		ent.AlarmExists = false
	end
	--Firetrap initiated
	ply:wanted(ent:Getowning_ent(),"Someone is getting crispy!!")
	ent:Ignite(30,20)
	ent.FiretrapUsesNumber = ent.FiretrapUsesNumber - 1	
	if ent.FiretrapUsesNumber == 0 then
		ent.FiretrapExists = false
	end
	elseif ent.FiretrapExists == true && FiretrapUsesNumber ~= 0 then
	--Firetrap initiated
	ply:wanted(ent:Getowning_ent(),"Someone is getting crispy!!")
	ent:Ignite(30,20)
	ent.FiretrapUsesNumber = ent.FiretrapUsesNumber - 1	
	if ent.FiretrapUsesNumber == 0 then
		ent.FiretrapExists = false
	end
	elseif ent.AlarmExists == true && AlarmUsesNumber ~= 0 then
	ply:wanted(ent:Getowning_ent(),"Stealing Gun from vending machine!!")
	ent:StartLoopingSound("f")
	ent.AlarmUsesNumber = ent.AlarmUsesNumber - 1	
	if ent.AlarmUsesNumber == 0 then
		ent.AlarmExists = false
	end
	end
end
-- Hook for completed lockpick.
hook.Add("onLockpickCompleted", "UniqueName1", DepositGun)
-- Hook for lockpick started
hook.Add("lockpickStarted", "UniqueName2", RunAlarmFire)

