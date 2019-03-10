
-- Thanks to Kogitsune
-- http://facepunch.com/showthread.php?t=1442021&p=46720911&viewfull=1#post46720911

function duplicator.Deny( class )
    local name, val
    local i = 1
    
    while true do
        name, val = debug.getupvalue( duplicator.Allow, i )
        if name == "DuplicateAllowed" then break end
        if not name then error( "duplicator.Deny could not locate the DuplicateAllowed table!" ) end
        i = i + 1
    end
    
    val[ class ] = false
    
    if AdvDupe2 and AdvDupe2.duplicator.WhiteList then
        AdvDupe2.duplicator.WhiteList[class] = nil
    end
    
    if AdvDupe then
        AdvDupe.AdminSettings.ChangeDisallowedClass( class, true, true )
    end

end