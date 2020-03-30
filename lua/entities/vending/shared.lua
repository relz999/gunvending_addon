ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vending"
ENT.Spawnable = true
ENT.Category = "Gun Vending Machine"
-- Setup network varibles. 
function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("String", 0, "GunType")
	self:NetworkVar("Int", 0, "ShipmentSize")
	self:NetworkVar("Int", 1, "GunPrice")
	self:NetworkVar("String", 1, "GunName")
	self:NetworkVar("Entity", 1, "VendOwner")	
end