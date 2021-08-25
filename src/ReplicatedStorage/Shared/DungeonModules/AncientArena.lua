-- AncientArena

local Workspace = game:GetService("Workspace")

local module = {}

module.EnterPrompt = Workspace:FindFirstChild("DungeonPrompt_Joseph_Enter", true)
module.LeavePrompt = Workspace:FindFirstChild("DungeonPrompt_Joseph_Leave", true)
module.IconName = "Icon_Joseph"
module.Title = "Young Joseph"
module.NPCText = "Wait! Your next line is, 'Where do I get Dungeon Keys?'<br/>" .. 
                    "You find them on the map or buy them in the shop!"
module.DungeonName = "Ancient Arena"
module.DungeonId = script.Name -- "AncientArena" -- must match module name

module.Section_A_Header = "<b>BOSS:</b> Kars (Coming Soon)"
module.Section_A_Body = "    Drops: Aja Stone, Gold Star"

module.Section_B_Header = "<b>MOBS:</b> Wham!"
module.Section_B_Body = "    Drops: Antidote, Mask Fragments"

module.Section_C_Header = "<b>ITEM SPAWNS</b>"
module.Section_C_Body = "    Mask Fragments, Gold Star, Soul Orbs, Cash"


return module