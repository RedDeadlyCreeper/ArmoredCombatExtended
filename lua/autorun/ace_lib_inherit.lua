
inherit = inherit or {}
local this = inherit


/**
	Base of the inheritance system for this project.
	adapted from	http://lua-users.org/wiki/InheritanceTutorial	, creds to those guys.
	Args;
		baseClass	Table
			the table which a new class should be derived from.
 */
function this.doInherit( child, baseClass )

    local new_class = child or {}
    local class_mt = { __index = new_class }

    function new_class:__new()
        local newinst = {}
        setmetatable( newinst, class_mt )
		newinst:Init()
        return newinst
    end
	
	class_mt.__call = new_class.__new

	
	function new_class:Init()
        
    end
	
	
    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass, __call = new_class.__new } )
	else
		setmetatable( new_class, { __call = new_class.__new } )
    end


    function new_class:class()
        return new_class
    end

	
    function new_class:super()
        return baseClass
    end
	
	
	function new_class:instanceof(class)
		if new_class == class then return true end
		if baseClass == nil then return false end
		return baseClass:instanceof(class)
	end
	
	/*
	function new_class:printITree()
		print(new_class)
		if baseClass then baseClass:printITree() end
	end
	//*/

    return new_class, class_mt
end



function this.NewBaseClass()
	local ret = {}
	return this.NewSubOf(nil)
end



function this.NewSubOf( base )
	return this.doInherit(nil, base)
end



function this.SetSuper(child, base)
	return this.doInherit(child, base)
end