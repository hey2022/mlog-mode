;;; mlog-mode.el --- Major mode for editing Mindustry logic (mlog) -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Yiheng He

;; Author: Yiheng He <yiheng.he@proton.me>
;; Version: 0.1.0
;; Keywords: faces languages
;; Homepage: https://github.com/hey2022/mlog-mode
;; Package-Requires: ((emacs "24.3") (string-inflection "1.1.0"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; mlog-mode is a major mode for editing Mindustry logic (mlog) code.
;; This package provides syntax highlighting for mlog.

;;; Code:

(require 'string-inflection)

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/ConditionOp.java
(defvar mlog-conditional-operators
  '("equal" "notEqual" "lessThan" "lessThanEq" "greaterThan" "greaterThanEq" "strictEqual" "always"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/GlobalVars.java
(defvar mlog-global-variables
  '(;; processor
    "@this" "@thisx" "@thisy" "@links" "@ipt"

    ;; time
    "@time" "@tick" "@second" "@minute" "@waveNumber" "@waveTime"

    "@mapw" "@maph" "@wait"

    ;; network
    "@server" "@client"
    "@clientLocale" "@clientUnit" "@clientName" "@clientTeam" "@clientMobile"

    ;; special enums
    "@ctrlProcessor" "@ctrlPlayer" "@ctrlCommand"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/GlobalVars.java
(defvar mlog-constants
  '("false" "true" "null"

    ;; math
    "@pi" "π" "@e" "@degToRad" "@radToDeg"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LAccess.java
(defvar mlog-access
  '("totalItems" "firstItem" "totalLiquids" "totalPower" "itemCapacity" "liquidCapacity" "powerCapacity" "powerNetStored" "powerNetCapacity" "powerNetIn" "powerNetOut" "ammo" "ammoCapacity" "currentAmmoType" "health" "maxHealth" "heat" "shield" "armor" "efficiency" "progress" "timescale" "rotation" "x" "y" "velocityX" "velocityY" "shootX" "shootY" "cameraX" "cameraY" "cameraWidth" "cameraHeight" "size" "solid" "dead" "range" "shooting" "boosting" "mineX" "mineY" "mining" "speed" "team" "type" "flag" "controlled" "controller" "name" "payloadCount" "payloadType" "id"

    ;; values with parameters are considered controllable
    "enabled" "shoot" "shootp" "config" "color"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LAssembler.java
(defvar mlog-assembler
  '("@coutner" "@unit" "@this"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LLocate.java
(defvar mlog-locate
  '("ore" "building" "spawn" "damaged"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LMarkerControl.java
(defvar mlog-marker-controls
  '("remove" "world" "minimap" "autoscale" "pos" "endPos" "drawLayer" "color" "radius" "stroke" "rotation" "shape" "arc" "flushText" "fontSize" "textHeight" "labelFlags" "texture" "textureSize" "posi" "uvi" "colori"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LCategory.java
;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LStatements.java
(defvar mlog-statements
  '(;; unknown
    "noop"

    ;; io
    "read" "write" "draw" "print" "format" "drawflush" "printflush"

    ;; block
    "getlink" "control" "radar" "sensor"

    ;; operations
    "set" "op"  "lookup" "packcolor"

    ;; control
    "wait" "stop" "end" "jump"

    ;; unit
    "ubind" "ucontrol" "uradar" "ulocate"

    ;; world
    "getblock" "setblock" "spawn" "status" "weathersense" "weatherset" "spawnwave" "setrule" "message" "cutscene" "effect" "explosion" "setrate" "fetch" "sync" "clientdata" "getflag" "setflag" "setprop" "playsound" "setmarker" "makemarker" "localeprint"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LUnitControl.java
(defvar mlog-unit-controls
  '("idle" "stop" "move" "approach" "pathfind" "autoPathfind" "boost" "target" "targetp" "itemDrop" "itemTake" "payDrop" "payTake" "payEnter" "mine" "flag" "build" "getBlock" "within" "unbind"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/LogicOp.java
(defvar mlog-logic-operators
  '("add" "sub" "mul" "div" "idiv" "mod" "pow"
    "equal" "notEqual" "land" "lessThan" "lessThanEq" "greaterThan" "greaterThanEq" "strictEqual"
    "shl" "shr" "or" "and" "xor" "not"
    "max" "min" "angle" "angleDiff" "len" "noise" "abs" "log" "log10" "floor" "ceil" "sqrt" "rand"
    "sin" "cos" "tan"
    "asin" "acos" "atan"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/RadarSort.java
(defvar mlog-radar-sort
  '("distance" "health" "shield" "armor" "maxHealth"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/RadarTarget.java
(defvar mlog-radar-target
  '("any" "enemy" "ally" "player" "attacker" "flying" "boss" "ground"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/logic/TileLayer.java
(defvar mlog-tile-layer
  '("floor" "ore" "block" "building"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/content/Blocks.java
(defvar mlog-blocks
  '(;; environment
    "air" "spawn" "removeWall" "removeOre" "cliff" "deepwater" "water" "taintedWater" "deepTaintedWater" "tar" "slag" "cryofluid" "stone" "craters" "charr" "sand" "darksand" "dirt" "mud" "ice" "snow" "darksandTaintedWater" "space" "empty"
    "dacite" "rhyolite" "rhyoliteCrater" "roughRhyolite" "regolith" "yellowStone" "redIce" "redStone" "denseRedStone"
    "arkyciteFloor" "arkyicStone"
    "redmat" "bluemat"
    "stoneWall" "dirtWall" "sporeWall" "iceWall" "daciteWall" "sporePine" "snowPine" "pine" "shrubs" "whiteTree" "whiteTreeDead" "sporeCluster"
    "redweed" "purbush" "yellowCoral"
    "rhyoliteVent" "carbonVent" "arkyicVent" "yellowStoneVent" "redStoneVent" "crystallineVent"
    "regolithWall" "yellowStoneWall" "rhyoliteWall" "carbonWall" "redIceWall" "ferricStoneWall" "beryllicStoneWall" "arkyicWall" "crystallineStoneWall" "redStoneWall" "redDiamondWall"
    "ferricStone" "ferricCraters" "carbonStone" "beryllicStone" "crystallineStone" "crystalFloor" "yellowStonePlates"
    "iceSnow" "sandWater" "darksandWater" "duneWall" "sandWall" "moss" "sporeMoss" "shale" "shaleWall" "grass" "salt"
    "coreZone"
    ;; boulders
    "shaleBoulder" "sandBoulder" "daciteBoulder" "boulder" "snowBoulder" "basaltBoulder" "carbonBoulder" "ferricBoulder" "beryllicBoulder" "yellowStoneBoulder"
    "arkyicBoulder" "crystalCluster" "vibrantCrystalCluster" "crystalBlocks" "crystalOrbs" "crystallineBoulder" "redIceBoulder" "rhyoliteBoulder" "redStoneBoulder"
    "metalFloor" "metalFloorDamaged" "metalFloor2" "metalFloor3" "metalFloor4" "metalFloor5" "basalt" "magmarock" "hotrock" "snowWall" "saltWall"
    "darkPanel1" "darkPanel2" "darkPanel3" "darkPanel4" "darkPanel5" "darkPanel6" "darkMetal"
    "pebbles" "tendrils"

    ;; ores
    "oreCopper" "oreLead" "oreScrap" "oreCoal" "oreTitanium" "oreThorium"
    "oreBeryllium" "oreTungsten" "oreCrystalThorium" "wallOreThorium"

    ;; wall ores
    "wallOreBeryllium" "graphiticWall" "wallOreTungsten"

    ;; crafting
    "siliconSmelter" "siliconCrucible" "kiln" "graphitePress" "plastaniumCompressor" "multiPress" "phaseWeaver" "surgeSmelter" "pyratiteMixer" "blastMixer" "cryofluidMixer"
    "melter" "separator" "disassembler" "sporePress" "pulverizer" "incinerator" "coalCentrifuge"

    ;; crafting - erekir
    "siliconArcFurnace" "electrolyzer" "oxidationChamber" "atmosphericConcentrator" "electricHeater" "slagHeater" "phaseHeater" "heatRedirector" "heatRouter" "slagIncinerator"
    "carbideCrucible" "slagCentrifuge" "surgeCrucible" "cyanogenSynthesizer" "phaseSynthesizer" "heatReactor"

    ;; sandbox
    "powerSource" "powerVoid" "itemSource" "itemVoid" "liquidSource" "liquidVoid" "payloadSource" "payloadVoid" "illuminator" "heatSource"

    ;; defense
    "copperWall" "copperWallLarge" "titaniumWall" "titaniumWallLarge" "plastaniumWall" "plastaniumWallLarge" "thoriumWall" "thoriumWallLarge" "door" "doorLarge"
    "phaseWall" "phaseWallLarge" "surgeWall" "surgeWallLarge"

    ;; walls - erekir
    "berylliumWall" "berylliumWallLarge" "tungstenWall" "tungstenWallLarge" "blastDoor" "reinforcedSurgeWall" "reinforcedSurgeWallLarge" "carbideWall" "carbideWallLarge"
    "shieldedWall"

    "mender" "mendProjector" "overdriveProjector" "overdriveDome" "forceProjector" "shockMine"
    "scrapWall" "scrapWallLarge" "scrapWallHuge" "scrapWallGigantic" "thruster"

    ;; defense - erekir
    "radar"
    "buildTower"
    "regenProjector" "barrierProjector" "shockwaveTower"
    ;; campaign only
    "shieldProjector"
    "largeShieldProjector"
    "shieldBreaker"

    ;; transport
    "conveyor" "titaniumConveyor" "plastaniumConveyor" "armoredConveyor" "distributor" "junction" "itemBridge" "phaseConveyor" "sorter" "invertedSorter" "router"
    "overflowGate" "underflowGate" "massDriver"

    ;; transport - alternate
    "duct" "armoredDuct" "ductRouter" "overflowDuct" "underflowDuct" "ductBridge" "ductUnloader"
    "surgeConveyor" "surgeRouter"

    "unitCargoLoader" "unitCargoUnloadPoint"

    ;; liquid
    "mechanicalPump" "rotaryPump" "impulsePump" "conduit" "pulseConduit" "platedConduit" "liquidRouter" "liquidContainer" "liquidTank" "liquidJunction" "bridgeConduit" "phaseConduit"

    ;; liquid - reinforced
    "reinforcedPump" "reinforcedConduit" "reinforcedLiquidJunction" "reinforcedBridgeConduit" "reinforcedLiquidRouter" "reinforcedLiquidContainer" "reinforcedLiquidTank"

    ;; power
    "combustionGenerator" "thermalGenerator" "steamGenerator" "differentialGenerator" "rtgGenerator" "solarPanel" "largeSolarPanel" "thoriumReactor"
    "impactReactor" "battery" "batteryLarge" "powerNode" "powerNodeLarge" "surgeTower" "diode"

    ;; power - erekir
    "turbineCondenser" "ventCondenser" "chemicalCombustionChamber" "pyrolysisGenerator" "fluxReactor" "neoplasiaReactor"
    "beamNode" "beamTower" "beamLink"

    ;; production
    "mechanicalDrill" "pneumaticDrill" "laserDrill" "blastDrill" "waterExtractor" "oilExtractor" "cultivator"
    "cliffCrusher" "plasmaBore" "largePlasmaBore" "impactDrill" "eruptionDrill"

    ;; storage
    "coreShard" "coreFoundation" "coreNucleus" "vault" "container" "unloader"
    ;; storage - erekir
    "coreBastion" "coreCitadel" "coreAcropolis" "reinforcedContainer" "reinforcedVault"

    ;; turrets
    "duo" "scatter" "scorch" "hail" "arc" "wave" "lancer" "swarmer" "salvo" "fuse" "ripple" "cyclone" "foreshadow" "spectre" "meltdown" "segment" "parallax" "tsunami"

    ;; turrets - erekir
    "breach" "diffuse" "sublimate" "titan" "disperse" "afflict" "lustre" "scathe" "smite" "malign"

    ;; units
    "groundFactory" "airFactory" "navalFactory"
    "additiveReconstructor" "multiplicativeReconstructor" "exponentialReconstructor" "tetrativeReconstructor"
    "repairPoint" "repairTurret"

    ;; units - erekir
    "tankFabricator" "shipFabricator" "mechFabricator"

    "tankRefabricator" "shipRefabricator" "mechRefabricator"
    "primeRefabricator"

    "tankAssembler" "shipAssembler" "mechAssembler"
    "basicAssemblerModule"

    "unitRepairTower"

    ;; payloads
    "payloadConveyor" "payloadRouter" "reinforcedPayloadConveyor" "reinforcedPayloadRouter" "payloadMassDriver" "largePayloadMassDriver" "smallDeconstructor" "deconstructor" "constructor" "largeConstructor" "payloadLoader" "payloadUnloader"

    ;; logic
    "message" "switchBlock" "microProcessor" "logicProcessor" "hyperProcessor" "largeLogicDisplay" "logicDisplay" "memoryCell" "memoryBank"
    "canvas" "reinforcedMessage"
    "worldProcessor" "worldCell" "worldMessage" "worldSwitch"

    ;; campaign
    "launchPad" "interplanetaryAccelerator"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/content/Items.java
(defvar mlog-items
  '("scrap" "copper" "lead" "graphite" "coal" "titanium" "thorium" "silicon" "plastanium"
    "phaseFabric" "surgeAlloy" "sporePod" "sand" "blastCompound" "pyratite" "metaglass"
    "beryllium" "tungsten" "oxide" "carbide" "fissileMatter" "dormantCyst"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/content/Liquids.java
(defvar mlog-liquids
  '("water" "slag" "oil" "cryofluid"
    "arkycite" "gallium" "neoplasm"
    "ozone" "hydrogen" "nitrogen" "cyanogen"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/content/UnitTypes.java
(defvar mlog-units
  '(;; mech
    "mace" "dagger" "crawler" "fortress" "scepter" "reign" "vela"

    ;; mech legacy
    "nova" "pulsar" "quasar"

    ;; legs
    "corvus" "atrax"
    "merui" "cleroi" "anthicus"
    "tecta" "collaris"

    ;; legs legacy
    "spiroct" "arkyid" "toxopid"

    ;; hover
    "elude"

    ;; air
    "flare" "eclipse" "horizon" "zenith" "antumbra"
    "avert" "obviate"

    ;; air legacy
    "mono"

    ;; air legacy
    "poly"

    ;; air + payload
    "mega"
    "evoke" "incite" "emanate" "quell" "disrupt"

    ;; air + payload legacy
    "quad"

    ;; air + payload + legacy (different branch)
    "oct"

    ;; air legacy
    "alpha" "beta" "gamma"

    ;; naval
    "risso" "minke" "bryde" "sei" "omura" "retusa" "oxynoe" "cyerce" "aegires" "navanax"

    ;; special block unit type
    "block"

    ;; special building tethered (has payload capability because it's necessary sometimes)
    "manifold" "assemblyDrone"

    ;; tank
    "stell" "locus" "precept" "vanquish" "conquer"))

;; https://github.com/Anuken/Mindustry/blob/master/core/src/mindustry/world/meta/BlockFlag.java
(defvar mlog-block-flag
  '("core" "storage" "generator" "turret" "factory" "repair" "battery" "reactor" "extinguisher" "drill" "shield"))

(defvar mlog-keywords
  (let* ((variables (append mlog-global-variables (mapcar (lambda (variable) (concat "@" variable)) mlog-access) mlog-assembler))
         (keywords mlog-statements)
         (types (append mlog-locate mlog-radar-target mlog-tile-layer (mapcar (lambda (variable) (concat "@" (string-inflection-kebab-case-function variable))) (append mlog-blocks mlog-items mlog-liquids mlog-units)) mlog-block-flag))
         (constants mlog-constants)
         (builtins (append mlog-marker-controls mlog-unit-controls mlog-radar-sort))
         (operators (append mlog-conditional-operators mlog-logic-operators)))
    `(("^ *\\(\\w+\\): *$" . (1 font-lock-function-name-face))
      ("^ *jump \\(\\w+\\)" . (1 font-lock-function-name-face))
      (,(regexp-opt variables 'symbols) . font-lock-variable-name-face)
      (,(regexp-opt keywords 'words) . font-lock-keyword-face)
      ("#.*" . font-lock-comment-face)
      (,(regexp-opt types 'symbols) . font-lock-type-face)
      (,(regexp-opt constants 'symbols) . font-lock-constant-face)
      (,(regexp-opt builtins 'words) . font-lock-builtin-face)
      (,(regexp-opt operators 'words) . font-lock-builtin-face))))

(defvar mlog-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\# ". 124b" table)
    (modify-syntax-entry ?\@ "_" table)
    table)
  "Syntax table for `mlog-mode'.")

;;;###autoload
(define-derived-mode mlog-mode asm-mode "mlog"
  "Major mode for editing Mindustry logic."
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults  '(mlog-keywords)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(mlog\\|masm\\)\\'" . mlog-mode))

(provide 'mlog-mode)
;;; mlog-mode.el ends here
