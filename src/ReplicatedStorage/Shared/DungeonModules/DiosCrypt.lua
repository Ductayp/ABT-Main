-- DiosCrypt

local Workspace = game:GetService("Workspace")

local module = {}

module.EnterPrompt = Workspace:FindFirstChild("DungeonPrompt_Zeppeli_Enter", true)
module.LeavePrompt = Workspace:FindFirstChild("DungeonPrompt_Zeppeli_Leave", true)
module.IconName = "Icon_Zeppeli"
module.Title = "Hamon and Cheese"
module.NPCText = "What is Courage? Courage is knowing fear and making that fear your own!<br/><br/>Dio awaits within, as do his minions."

module.DungeonName = "Dios Crypt"
module.DungeonId = script.Name 

module.Section_A_Header = "<b>BOSS:</b> Dio Brando"
module.Section_A_Body = "    Drops: Dios Bone, Gold Star"

module.Section_B_Header = "<b>MOBS:</b> Zombie"
module.Section_B_Body = "    Drops: Green Goo, Dungeon Key, Cash"

module.Section_C_Header = "<b>ITEM SPAWNS</b>"
module.Section_C_Body = "    Green Goo, Gold Star, Soul Orbs, Cash"

return module