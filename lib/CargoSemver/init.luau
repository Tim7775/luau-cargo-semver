--!optimize 2
--!strict
--[[
	* Copyright (c) 2025 Tim7775
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

local BuildMetadata = require("@self/BuildMetadata")
local Comparator = require("@self/Comparator")
local Ordering = require("@self/Ordering")
local Prerelease = require("@self/Prerelease")
local Version = require("@self/Version")
local VersionReq = require("@self/VersionReq")

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
