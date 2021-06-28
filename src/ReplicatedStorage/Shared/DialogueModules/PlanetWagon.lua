-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- nothing here yet
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_PlanetWagon",
    Title = "Planet Wagon (A.K.A. Planet_Dad)",
    Body = "Yo Homie! Glad you stopped by!<br /><br />" ..
            "To get you started, just click the TWITTER button on the left and enter this code to get 3 arrows.<br /><br />" ..
            "CODE: <b>StarterArrows</b>",
    Choice_1 = {
        Display = true,
        Text = "Planet WHO?",
        Action = {
            Type = "ChangeStage",
            Stage = "PlanetIntro"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "How do I play?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial1"
        }
    },
    Choice_3 = {
        Display = true,
        Text = "More codes?",
        Action = {
            Type = "ChangeStage",
            Stage = "Codes2"
        }
    },
}

module.Stage.PlanetIntro = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Glad you asked, Planet Milo is our YouTube channel, maybe check it out? Link is on the Game Page. " ..
            "<br/><br/>We will be dropping fresh codes and game leaks over there.",
    Choice_1 = {
        Display = true,
        Text = "How do I play?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial1"
        }
    },
    Choice_2 = {
        Display = false,
        Display = true,
        Text = "Did you say CODES?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Codes2"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

--[[
module.Stage.Codes = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "EEEYYYY! You like codes too? We I got one right here to get your started. Hit that TWITTER bird button on the left and enter: StarterArrows.",
    Choice_1 = {
        Display = true,
        Text = "Aight then",
        Action = {
            Type = "Close",
        }
    },
    Choice_2 = {
        Display = true,
        Text = "you got any more?",
        Action = {
            Type = "ChangeStage",
            Stage = "Codes2"
        }
    },
    Choice_3 = {
        Display = false,
    },
}
]]--

module.Stage.Codes2 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Just use the starter code for 3 arrows: <b>StarterArrows</b><br/><br/>Follow us on YouTube, Twitter, and join Dis-cord for fresh codes. Links are on the Roblox game page.",
    Choice_1 = {
        Display = true,
        Text = "How do I play?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial1"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Planet WHO?",
        Action = {
            Type = "ChangeStage",
            Stage = "PlanetIntro"
        }
    },
    Choice_3 = {
        Display = false,
    },
}


module.Stage.QuickTutorial1 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Well, first you need to find an arrow, there should always be a few on the map.<br/><br/>When someone grabs one, another one spawns.",
    Choice_1 = {
        Display = true,
        Text = "Ok, then what?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial2"
        }
    },
    Choice_2 = {
        Display = false
        --[[
        Display = false,
        Display = true,
        Text = "Did you say codes?",
        Action = {
            Type = "ChangeStage", 
            Stage = "Codes"
        }
        ]]--
    },
    Choice_3 = {
        Display = false
    },
}

module.Stage.QuickTutorial2 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Next, open your inventory and use it! You will gain a new power called a STAND.<br/><br/>Hit the Q key to summon it!",
    Choice_1 = {
        Display = true,
        Text = "Ok, then what?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial3"
        }
    },
    Choice_2 = {
        Display = false
    },
    Choice_3 = {
        Display = false
    },
}

module.Stage.QuickTutorial3 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Then you gotta EXPLORE! Your stand will gain XP and SOUL ORBS as you kill mobs. When your stand reaches max XP, you use a GOLD STAR to EVOLVE it.<br/><br/><b>Enrico Can tell you more about that at his Shop.</b>",
    Choice_1 = {
        Display = true,
        Text = "And then? ...",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial4"
        }
    },
    Choice_2 = {
        Display = false
    },
    Choice_3 = {
        Display = false
    },
}

module.Stage.QuickTutorial4 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "ALL stands have 3 Ranks and each has a different color. Each does more damage than the last and looks different.<br/><br/><b>Talk to Enrico at his shop for more info.</b>",
    Choice_1 = {
        Display = true,
        Text = "Wow! Then what?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial5"
        }
    },
    Choice_2 = {
        Display = false
    },
    Choice_3 = {
        Display = false
    },
}

module.Stage.QuickTutorial5 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "If you need to remove your stand, you can TRASH it anywhere or to STORE it for later, go to Enrico's Shop.<br/><br/><b>You really should go visit the place, its just down the road by the Harbor!!!</b>",
    Choice_1 = {
        Display = true,
        Text = "I will go see Enrico, Then what?",
        CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial6"
        }
    },
    Choice_2 = {
        Display = false
    },
    Choice_3 = {
        Display = false
    },
}

module.Stage.QuickTutorial6 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Then grind, explore and have fun! Be sure to talk to all the NPCs on the map to learn more about the game.<br/><br/>Dont forget to sub to Planet Milo on YouTube for codes and leaks.",
    Choice_1 = {
        Display = true,
        Text = "A'ight then, thanks!",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Close",
        }
    },
    Choice_2 = {
        Display = false
    },
    Choice_3 = {
        Display = false
    },
}

return module