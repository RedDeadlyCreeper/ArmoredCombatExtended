

AddCSLuaFile() 
--easy management of armor types

ACE_ConfigureMaterial( 0 , {                 -- Unique ID

--general information

        name          = 'RHA' ,              -- Name
		desc          = 'RHA desc',          -- Description

--General config

        massMod       = 1,                   -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.99,                -- Thickness exponential value, used to avoid high thickness

		effectiveness = 1,                   -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		resiliance    = 1,                   -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha

--Spalling config

		spallresist   = 1,                   -- resistance multipler to spall damage
        spallmult	  =	1,                   -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 1

	}
)


if ACF.EnableNewContent and ACF.Year >= 1955 then  --Any other material must go below this


    ACE_ConfigureMaterial( 1 , {             -- Unique ID

     --general information

        name          = 'CHA' ,              -- Name
		desc          = 'Cast desc',         -- Description

     --General config

        massMod       = 1.25,                -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.97,                -- Thickness exponential value, used to avoid high thickness

		effectiveness = 0.98,                -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		resiliance    = 2.25,                -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha

     --Spalling config

		spallresist   = 0.5,                 -- resistance multipler to spall damage
        spallmult	  =	2,                   -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 1

	    }
    )

    ACE_ConfigureMaterial( 2 , {             -- Unique ID

     --general information

        name          = 'Ceramic' ,          -- Name
		desc          = 'Ceramic desc',      -- Description

     --General config

        massMod       = 0.8,                 -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.95,                -- Thickness exponential value, used to avoid high thickness

		effectiveness = 2.4,                 -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		resiliance    = 0.01,                -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha


     --Spalling config

		spallresist   = 1,                   -- resistance multipler to spall damage
        spallmult	  =	2.5,                 -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 1.8

	    }
    )



    ACE_ConfigureMaterial( 3 , {             -- Unique ID

     --general information

        name          = 'Rubber' ,           -- Name
		desc          = 'Rubber desc',       -- Description

     --General config

        massMod       = 0.2,                 -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.95,                -- Thickness exponential value, used to avoid high thickness

		specialeffect = 30,                  -- Caliber of gun in mm where damage mult for catched heat jets are based, above this increase, below decrease

		effectiveness         = 0.02,        -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		specialeffectiveness  = 3,

		resiliance            = 0.1,         -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha
		specialresiliance     = 0.15,        -- same as above, this is special vs HEAT ammunition
		HEresiliance          = 0.3,         -- resiliance vs HE
		Catchresiliance       = 0.05,        -- resiliance from catched AP based bullets. applies when not penetrated

     --Spalling config

		spallresist   = 1,                   -- resistance multipler to spall damage
        spallmult	  =	0.1,                 -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 0.01

	    }
    )

    ACE_ConfigureMaterial( 4 , {             -- Unique ID

     --general information

        name          = 'ERA' ,              -- Name       
		desc          = 'ERA desc',          -- Description

     --General config
		
        massMod       = 2,                   -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.95,                -- Thickness exponential value, used to avoid high thickness
		
		effectiveness = 5,                   -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		HEATeffectiveness = 20,
		resiliance    = 0.25,                -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha
		
     --Spalling config
		
		spallresist   = 1,                   -- resistance multipler to spall damage
        spallmult	  =	1,                   -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 1

	    }
    )

    ACE_ConfigureMaterial( 5 , {             -- Unique ID

     --general information

        name          = 'Aluminum' ,         -- Name
		desc          = 'Aluminum desc',     -- Description

     --General config

        massMod       = 0.221,               -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.93,                -- Thickness exponential value, used to avoid high thickness

		effectiveness = 0.34,                -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		resiliance    = 0.95,                -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha
		HEATMul       = 80,                  -- Define how much damage HEAT will make to this material

     --Spalling config

		spallresist   = 1.5,                 -- resistance multipler to spall damage
        spallmult	  =	2,                   -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 0.334

	    }
    )

    ACE_ConfigureMaterial( 6 , {             -- Unique ID

     --general information

        name          = 'Textolite' ,        -- Name
		desc          = 'Textolite desc',    -- Description

     --General config
		
        massMod       = 0.35,                -- Mass Multipler. 1x is the mass equivalent to rha
		curve         = 0.94,                -- Thickness exponential value, used to avoid high thickness

		effectiveness     = 0.23,            -- penetration resistance multipler. 1x is the effectiveness equivalent to rha
		HEATeffectiveness = 0.55,
		HEeffectiveness   = 0.9,

		resiliance        = 0.005,           -- resiliance factor of this material. Increasing it means less damage. 1x is the resiliance equivalent to rha
		HEATresiliance    = 2,
		HEresiliance      = 1.3,

     --Spalling config

		spallresist   = 1.5,                 -- resistance multipler to spall damage
        spallmult	  =	1.3,                 -- spalling multipler. Higher => causes more spalling
		ArmorMul      = 0.23

	    }
    )

end