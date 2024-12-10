-----------------------------------------------------------------------------------
-- File     :  /effects/Entities/Cluster01Effect02/Cluster01Effect05_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Nuclear explosion script
-- Copyright � 2005, 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TrashBagAdd = TrashBag.Add

---@class Cluster01Effect05 : NullShell
Cluster01Effect05 = Class(NullShell) {
    ---@param self Cluster01Effect05
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local trash = self.Trash
        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
    end,

    ---@param self Cluster01Effect05
    EffectThread = function(self)
        local army = self.Army

        for _, v in EffectTemplate.TNukeBaseEffects02 do
            CreateEmitterOnEntity(self, army, v):ScaleEmitter(0.03125)
        end
    end,
}

TypeClass = Cluster01Effect05
