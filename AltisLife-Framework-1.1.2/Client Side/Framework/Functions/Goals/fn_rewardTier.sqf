/*
** Author: Jack "Scarso" Farhall
** Description: 
*/
#include "..\..\script_macros.hpp"
scopeName "fn_rewardTier";

if (canSuspend) exitWith {
    [ULP_fnc_rewardTier, _this] call ULP_fnc_directCall;
};

_this params [
	["_cfg", configNull, [configNull]],
	["_tier", 0, [0]]
];

private _title = getText (_cfg >> "title");

["GoalReward", [format ["You have achieved tier %1 in the personal goal, '%2'", _tier, getText (_cfg >> "title")]]] call BIS_fnc_showNotification;
playSound "FD_Finish_F";

[(_tier - 1), format["reaching tier %1 in %2...", _tier, _title]] call ULP_fnc_grantReward;

[getPlayerUID player, "Goal", [_title, _tier]] remoteExecCall ["ULP_SRV_fnc_logPlayerEvent", RSERV];