-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_PlanetWagon",
    Title = "Planet Wagon (A.K.A. Planet_Dad)",
    Body = "Yo Homie! Glad you stopped by!<br /><br />" ..
            "To get you started, just click the TWITTER button on the left and enter this code to get your first arrow.<br /><br />" ..
            "CODE: <b>StarterArrow</b>",
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
        Display = false,
        --[[
        Display = true,
        Text = "I just need codes",
        Action = {
            Type = "ChangeStage",
            Stage = "Codes"
        }
        ]]--
    },
}

module.Stage.PlanetIntro = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Glad you asked, Planet Milo is our YouTube channel, maybe check it out? Link is on the Game Page. " ..
            "We will be dropping fresh codes and game leaks over there.",
    Choice_1 = {
        Display = true,
        Text = "So, how do I play?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial1"
        }
    },
    Choice_2 = {
        Display = false,
        --[[
        Display = true,
        Text = "Did you say CODES?",
        Action = {
            Type = "ChangeStage",
            Stage = "Codes"
        }
        ]]--
    },
    Choice_3 = {
        Display = false,
    },
}

--[[
module.Stage.Codes = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "EEEYYYY! You like codes too? We I got one right here to get your started. Hit that TWITTER bird button on the left and enter: StarterArrow.",
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

module.Stage.Codes2 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Well, follow us on YouTube and Twitter and we will drop the fresh ones, also dont forget to join the Discord. oh TAGS? Well you know...",
    Choice_1 = {
        Display = true,
        Text = "Aight then",
        Action = {
            Type = "Close",
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}
]]--

module.Stage.QuickTutorial1 = {
    IconName = "Icon_PlanetWagon",
    Title = "PlanetWagon (A.K.A. Planet_Dad)",
    Body = "Well, first you need to find an arrow, they aren't super common but you should be able to find one if you look around. I also have a code for an arrow to get you started.",
    Choice_1 = {
        Display = true,
        Text = "Ok, then what?",
        Action = {
            Type = "ChangeStage",
            Stage = "QuickTutorial2"
        }
    },
    Choice_2 = {
        Display = false,
        --[[
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
    Body = "Next, open your inventory and use it! You will gain a new power called a STAND. Hit the Q key to summon it!",
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
    Body = "Then you gotta GRIND! Your stand will gain XP as you kill mobs and you can SACRIFICE it to gain Soul Orbs.<br/><br/>Pucci Can tell you more about that at his Shop.",
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
    Body = "There are 3 rarities of each stand: Common, Rare and Legendary and each does more damage than the last. You probably need to get pretty lucky to get a Legendary.",
    Choice_1 = {
        Display = true,
        Text = "Wow! Then what?",
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
    Body = "Then grind, explore and have fun! Be sure to talk to all the NPCs on the map to learn more about the game.<br/>Dont forget to sub to Planet Milo on YouTube for codes and leaks.",
    Choice_1 = {
        Display = true,
        Text = "Aight then, thanks!",
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