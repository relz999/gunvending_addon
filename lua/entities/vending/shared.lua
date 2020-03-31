ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vending"
ENT.Spawnable = true
ENT.Category = "Gun Vending Machine"
-- Setup network varibles. 
function ENT:SetupDataTables()
	--Entities
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Entity", 1, "VendOwner")
	--Strings
	self:NetworkVar("String", 0, "GunType")
	self:NetworkVar("String", 1, "GunName")
	self:NetworkVar("String", 2, "GunModel")
	--Intigers
	self:NetworkVar("Int", 0, "ShipmentSize")
	self:NetworkVar("Int", 1, "ShipmentSizeOrig")
	self:NetworkVar("Int", 2, "GunPrice")
	self:NetworkVar("Int", 3, "GunSellPrice")
	self:NetworkVar("Int", 4, "TotalSales")
end