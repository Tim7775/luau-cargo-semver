--!optimize 2
--!strict
--[[
	* Copyright (c) 2023 Tim7775
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]

local BuildMetadata = require("./BuildMetadata") -->require(script.BuildMetadata)
local Comparator = require("./Comparator") -->require(script.Comparator)
local Ordering = require("./Ordering") -->require(script.Ordering)
local Prerelease = require("./Prerelease") -->require(script.Prerelease)
local Version = require("./Version") -->require(script.Version)
local VersionReq = require("./VersionReq") -->require(script.VersionReq)

local CargoSemver = {
	Version = Version,
	VersionReq = VersionReq,
	Prerelease = Prerelease,
	BuildMetadata = BuildMetadata,
	Comparator = Comparator,
	Ordering = Ordering,
}

export type BuildMetadata = BuildMetadata.BuildMetadata
export type Prerelease = Prerelease.Prerelease
export type Version = Version.Version
export type VersionReq = VersionReq.VersionReq
export type Comparator = Comparator.Comparator

return table.freeze(CargoSemver)
