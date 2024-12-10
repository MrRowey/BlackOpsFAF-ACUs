-----------------------------------------------------------------------------------------------------------------------------
-- File     :  /mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01EffectController01/Cluster01EffectController01_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Nuclear explosion script
-- Copyright � 2005, 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Util = import('/lua/utilities.lua')

local Cluster01Shockwave01_proj = '/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Shockwave01/Cluster01Shockwave01_proj.bp'
local Cluster02Shockwave02_proj = '/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Shockwave02/Cluster01Shockwave02_proj.bp'
local Cluster01FlavorPlume01_proj = '/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01FlavorPlume01/Cluster01FlavorPlume01_proj.bp'
local Cluster01Effect03_proj = '/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Effect03/Cluster01Effect03_proj.bp'
local Cluster01Effect04_proj = '/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Effect04/Cluster01Effect05_proj.bp'

local RandomFloat = Util.GetRandomFloat

-- Upvalue for performance
local CreateEmitterAtEntity = CreateEmitterAtEntity
local MathSin = math.sin
local MathCos = math.cos
local MathPi = math.pi
local TrashBagAdd = TrashBag.Add
local ForkThread = ForkThread


---@class Cluster01EffectController01 : NullShell
Cluster01EffectController01 = Class(NullShell) {

    ---@param self Cluster01EffectController01
    PassData = function(self)
        self:CreateNuclearExplosion()
    end,

    ---@param self Cluster01EffectController01
    CreateNuclearExplosion = function(self)
        local bp = self.Blueprint
        local trash = self.Trash

        -- Play the "NukeExplosion" sound
        if bp.Audio.NukeExplosion then
            self:PlaySound(bp.Audio.NukeExplosion)
        end

        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
    end,

    ---@param self Cluster01EffectController01
    EffectThread = function(self)
        local army = self.Army
        local trash = self.Trash

        -- Create full-screen glow flash
        WaitSeconds(0.015625)

        -- Create initial fireball dome effect
        local FireballDomeYOffset = -0.15625
        self:CreateProjectile('/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Effect01/Cluster01Effect01_proj.bp', 0, FireballDomeYOffset, 0, 0, 0, 1)

        -- Create projectile that controls plume effects
        local PlumeEffectYOffset = 0.0625
        self:CreateProjectile('/mods/BlackOpsFAF-ACUs/effects/Entities/Cluster01Effect02/Cluster01Effect02_proj.bp', 0, PlumeEffectYOffset, 0, 0, 0, 1)

        for _, v in EffectTemplate.TNukeRings01 do
            CreateEmitterAtEntity(self, army, v):ScaleEmitter(0.03125)
        end

        self:CreateInitialFireballSmokeRing()
        TrashBagAdd(trash, ForkThread(self.CreateOuterRingWaveSmokeRing, self))
        TrashBagAdd(trash, ForkThread(self.CreateHeadConvectionSpinners, self))
        TrashBagAdd(trash, ForkThread(self.CreateFlavorPlumes, self))

        WaitSeconds(0.034375)
    end,

    ---@param self Cluster01EffectController01
    CreateInitialFireballSmokeRing = function(self)
        local sides = 12
        local angle = (2 * MathPi) / sides
        local velocity = 0.41667
        local OffsetMod = 0.25

        for i = 0, sides - 1 do
            local X = MathSin(i * angle)
            local Z = MathCos(i * angle)
            self:CreateProjectile(Cluster01Shockwave01_proj, X * OffsetMod, 0.09375, Z * OffsetMod, X, 0, Z):SetVelocity(velocity):SetAcceleration(-0.015625)
        end
    end,

    ---@param self Cluster01EffectController01
    CreateOuterRingWaveSmokeRing = function(self)
        local sides = 32
        local angle = (2 * math.pi) / sides
        local velocity = 0.21875
        local OffsetMod = 0.25
        local projectiles = {}

        for i = 0, sides - 1 do
            local X = MathSin(i * angle)
            local Z = MathCos(i * angle)
            local proj =  self:CreateProjectile(Cluster02Shockwave02_proj, X * OffsetMod, 0.15625, Z * OffsetMod, X, 0, Z):SetVelocity(velocity)
            table.insert(projectiles, proj)
        end
        WaitSeconds(0.1875)

        -- Slow projectiles down to normal speed
        for _, v in projectiles do
            v:SetAcceleration(-0.0140625)
        end
    end,

    ---@param self Cluster01EffectController01
    CreateFlavorPlumes = function(self)
        local numProjectiles = 8
        local angle = (2 * MathPi) / numProjectiles
        local angleInitial = RandomFloat(0, angle)
        local angleVariation = angle * 0.75
        local projectiles = {}

        local xVec = 0
        local yVec = 0
        local zVec = 0
        local velocity = 0

        -- yVec -0.2, requires 2 initial velocity to start
        -- yVec 0.3, requires 3 initial velocity to start
        -- yVec 1.8, requires 8.5 initial velocity to start

        -- Launch projectiles at semi-random angles away from the sphere, with enough
        -- initial velocity to escape sphere core
        for i = 0, numProjectiles - 1 do
            xVec = MathSin(angleInitial + (i * angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.2, 1)
            zVec = MathCos(angleInitial + (i * angle) + RandomFloat(-angleVariation, angleVariation))
            velocity = 0.10625 + (yVec * RandomFloat(2, 5))
            table.insert(projectiles, self:CreateProjectile(Cluster01FlavorPlume01_proj, 0, 0, 0, xVec, yVec, zVec):SetVelocity(velocity))
        end

        WaitSeconds(0.1875)

        -- Slow projectiles down to normal speed
        for _, v in projectiles do
            v:SetVelocity(0.0625):SetBallisticAcceleration(-0.0046875)
        end
    end,

    ---@param self Cluster01EffectController01
    CreateHeadConvectionSpinners = function(self)
        local sides = 10
        local angle = (2 * math.pi) / sides
        local HeightOffset = -0.15625
        local velocity = 0.03125
        local OffsetMod = 0.3125
        local projectiles = {}

        for i = 0, sides - 1 do
            local x = MathSin(i * angle) * OffsetMod
            local z = MathCos(i * angle) * OffsetMod
            local proj = self:CreateProjectile(Cluster01Effect03_proj, x, HeightOffset, z, x, 0, z):SetVelocity(velocity)
            table.insert(projectiles, proj)
        end

        WaitSeconds(0.0625)
        for i = 0, sides - 1 do
            local x = MathSin(i * angle)
            local z = MathCos(i * angle)
            local proj = projectiles[i + 1]
            proj:SetVelocityAlign(false)
            proj:SetOrientation(OrientFromDir(Util.Cross(Vector(x, 0, z), Vector(0, 1, 0))), true)
            proj:SetVelocity(0, 0.09375, 0)
            proj:SetBallisticAcceleration(-0.0015625)
        end
    end,

    ---@param self Cluster01EffectController01
    ---@param army Army
    CreateGroundPlumeConvectionEffects = function(self, army)
        for _, v in EffectTemplate.TNukeGroundConvectionEffects01 do
            CreateEmitterAtEntity(self, army, v):ScaleEmitter(0.03125)
        end

        local sides = 10
        local angle = (2 * MathPi) / sides
        local outer_lower_limit = 0.0625
        local outer_upper_limit = 0.0625
        local outer_lower_height = 0.0625
        local outer_upper_height = 0.09375

        sides = 8
        angle = (2 * MathPi) / sides
        for i = 0, sides - 1 do
            local magnitude = RandomFloat(outer_lower_limit, outer_upper_limit)
            local x = MathSin(i * angle + RandomFloat(-angle / 2, angle / 4)) * magnitude
            local z = MathCos(i * angle + RandomFloat(-angle / 2, angle / 4)) * magnitude
            local velocity = RandomFloat(1, 3) * 0.09375 -- Last Number
            self:CreateProjectile(Cluster01Effect05_proj, x, RandomFloat(outer_lower_height, outer_upper_height), z, x, 0, z):SetVelocity(x * velocity, 0, z * velocity)
        end
    end,
}

TypeClass = Cluster01EffectController01
