-----------------------------------------------------------------------------------
-- File     :  /effects/Entities/Cluster01Effect03/Cluster01Effect03_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Nuclear explosion script
-- Copyright � 2005, 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TrashBagAdd = TrashBag.Add

---@class Cluster01Effect03 : NullShell
Cluster01Effect03 = Class(NullShell) {
    ---@param self Cluster01Effect03
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local trash = self.Trash
        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
    end,

    ---@param self Cluster01Effect03
    EffectThread = function(self)
        local army = self.Army
        for _, v in EffectTemplate.TNukeHeadEffects03 do
            CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(0.03125)
        end

        WaitSeconds(6)
        for _, v in EffectTemplate.TNukeHeadEffects02 do
            CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(0.03125)
        end
    end,
}

TypeClass = Cluster01Effect03
