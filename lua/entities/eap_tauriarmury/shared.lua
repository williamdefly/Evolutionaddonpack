ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName= SGLanguage.GetMessage("ent_tauri_ammo");
ENT.Author= "Matspyder"
ENT.Contact= "N/A"
ENT.Purpose= "To take Zat and Staff Weapon."
ENT.Instructions= "Press E to use."
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = SGLanguage.GetMessage("cat_others");

list.Set("eap.Entity", ENT.PrintName, ENT);