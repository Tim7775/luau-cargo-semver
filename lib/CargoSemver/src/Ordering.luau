--!optimize 2
--!strict
--[[
	* Copyright (c) 2024 Tim7775
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

return table.freeze(setmetatable(
	{ Less = -1, Equal = 0, Greater = 1 },
	table.freeze({
		__index = function(_, index)
			error(`{index} is not a valid member of Ordering`)
		end,
	})
))
