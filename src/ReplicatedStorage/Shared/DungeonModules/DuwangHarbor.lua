-- AncientArena

local Workspace = game:GetService("Workspace")

local module = {}

module.EnterPrompt = Workspace:FindFirstChild("DungeonPrompt_Koichi_Enter", true)
module.LeavePrompt = Workspace:FindFirstChild("DungeonPrompt_Koichi_Leave", true)
module.IconName = "Icon_Koichi"
module.Title = "Smol Person"
module.NPCText = "Akira and Hot Tamale have been shooting arrows all over the island!<br/><br/>I can get you in for <b>1 DUNGEON KEY.</b>"

module.DungeonName = "Duwang Harbor"
module.DungeonId = script.Name 

module.Section_A_Header = "<b>BOSS:</b> Hot Tamale"
module.Section_A_Body = "    Drops: Broken Arrows, Gold Star"

module.Section_B_Header = "<b>MOBS:</b> Akira"
module.Section_B_Body = "    Drops: Arrows, Cash"

module.Section_C_Header = "<b>ITEM SPAWNS</b>"
module.Section_C_Body = "    Arrows, Broken Arrows, Gold Star, Soul Orbs, Cash"


return module