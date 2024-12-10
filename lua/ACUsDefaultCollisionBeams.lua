local EffectTemplate = import('/lua/EffectTemplates.lua')
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local TrashBagAdd = TrashBag.Add

-- Base class that defines supreme commander specific defaults
---@class HawkCollisionBeam : CollisionBeam
HawkCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactLand = {},
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
    FxImpactProp = {},
    FxImpactShield = {},
    FxImpactNone = {},
}

---@class PDLaserCollisionBeam : HawkCollisionBeam
PDLaserCollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {'/effects/emitters/em_pdlaser_beam_01_emit.bp'},
    FxBeamEndPoint = {
        '/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
    },

    FxBeamStartPoint = {
        '/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },

    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,

    ---@param self PDLaserCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        local trash = self.Trash

        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = TrashBagAdd(trash, ForkThread(self.ScorchThread, self))
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self PDLaserCollisionBeam
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        local trash = self.Trash

        if self.Scorching == nil then
            self.Scorching = TrashBagAdd(trash, ForkThread(self.ScorchThread, self))
        end
    end,

    ---@param self PDLaserCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self PDLaserCollisionBeam
    ScorchThread = function(self)
    end,
}

---@class CEMPArrayBeam01CollisionBeam : HawkCollisionBeam
CEMPArrayBeam01CollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {'/mods/BlackOpsFAF-ACUs/effects/emitters/cemparraybeam01_emit.bp'},
    FxBeamEndPoint = {},
    FxBeamStartPoint = {},
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,
}

---@class CEMPArrayBeam02CollisionBeam : HawkCollisionBeam
CEMPArrayBeam02CollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {'/mods/BlackOpsFAF-ACUs/effects/emitters/cemparraybeam02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,
}

---@class PDLaser2CollisionBeam : HawkCollisionBeam
PDLaser2CollisionBeam = Class(CollisionBeam) {
    FxBeamStartPoint = EffectTemplate.TDFHiroGeneratorMuzzle01,
    FxBeam = EffectTemplate.TDFHiroGeneratorBeam,
    FxBeamEndPoint = EffectTemplate.TDFHiroGeneratorHitLand,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,
    FxBeamStartPointScale = 0.75,
    FxBeamEndPointScale = 0.75,

    ---@param self PDLaser2CollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        local trash = self.Trash

        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = TrashBagAdd(trash, ForkThread(self.ScorchThread, self))
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self PDLaser2CollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self PDLaser2CollisionBeam
    ScorchThread = function(self)
    end,
}

---@class AeonACUPhasonLaserCollisionBeam : HawkCollisionBeam
AeonACUPhasonLaserCollisionBeam = Class(HawkCollisionBeam) {
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsFAF-ACUs/effects/emitters/phason_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,
    FxBeamStartPointScale = 0.25,
    FxBeamEndPointScale = 0.5,

    ---@param self AeonACUPhasonLaserCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        local trash = self.Trash

        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = TrashBagAdd(trash, ForkThread(self.ScorchThread, self))
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self AeonACUPhasonLaserCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self AeonACUPhasonLaserCollisionBeam
    ScorchThread = function(self)
    end,
}
