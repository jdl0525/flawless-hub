local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- 1. Turn off 3D Rendering (Blank Black Screen)
-- Your scripts, webhooks, and auto-farms still run perfectly in the background!
RunService:Set3dRenderingEnabled(false)

-- 2. Lower Terrain Physics/Detail in memory
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

-- 3. Kill all heavy lights, shadows, and skyboxes to free up RAM
pcall(function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Clouds") or effect:IsA("Sky") then
            effect:Destroy()
        end
    end
end)

-- 4. Clean-up function to delete textures, decals, and particles from RAM
local function purgeVisuals(object)
    if object:IsA("Decal") or object:IsA("Texture") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Sparkles") or object:IsA("Fire") or object:IsA("Smoke") then
        object:Destroy()
    elseif object:IsA("BasePart") and not object:IsA("MeshPart") then
        object.Material = Enum.Material.SmoothPlastic
        object.Color = Color3.fromRGB(120, 120, 120)
    elseif object:IsA("MeshPart") or object:IsA("SpecialMesh") then
        pcall(function()
            object.TextureID = ""
            if object:IsA("MeshPart") then
                object.Material = Enum.Material.SmoothPlastic
                object.Color = Color3.fromRGB(120, 120, 120)
            end
        end)
    end
end

-- Run the initial purge
for _, desc in ipairs(workspace:GetDescendants()) do
    purgeVisuals(desc)
end

-- Purge any new map assets that try to load in while playing
workspace.DescendantAdded:Connect(purgeVisuals)
