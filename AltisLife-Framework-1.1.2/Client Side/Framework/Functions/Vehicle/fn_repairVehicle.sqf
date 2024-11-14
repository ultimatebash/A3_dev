/*
** Author: Jack "Scarso" Farhall
** Description: 
*/
#include "..\..\script_macros.hpp"
scopeName "fn_repairVehicle";

_this params [
	["_vehicle", objNull, [objNull]]
];

private _cfg = [typeOf _vehicle] call ULP_fnc_vehicleCfg;
if (isNull _vehicle || { _cfg isEqualTo [] }) exitWith { if (dialog) then { closeDialog 0; }; };

_cfg params [
	"", "_missionCfg", "_picture", "_name", "_topSpeed", "_armor", "_seats", "_power", "_fuel"
];

if !(isClass _missionCfg) exitWith {};
if !("ToolKit" in (items player)) exitWith {
	["You require a tool kit to repair a vehicle!"] call ULP_fnc_hint;
};

private _time = 40;
if (isNumber (_missionCfg >> "repairTime")) then {
	_time = _time + getNumber (_missionCfg >> "repairTime");
};

private _profession = ["Repairing"] call ULP_fnc_getProfessionCalculation;
if (_profession > 0) then {
	_time = _time - (_time * (_profession / 100));
};

if !([format["Repairing %1", _name], _time, [_vehicle, _name], {
	!(isNull (_this select 0)) && { alive (_this select 0) } && { "ToolKit" in (items player) } && { (player distance (_this select 0)) <= 5 }
}, {
	_this params [ "_vehicle", "_name" ];

	if (isNull _vehicle || { !(alive _vehicle) } || { !("ToolKit" in (items player)) }) exitWith {
		[format["You failed to repair the <t color='#B92DE0'>%1</t> as it's either beyond repair or you didn't have the correct tools."]] call ULP_fnc_hint;
	};
	
	if !([player, ["Hato"]] call ULP_fnc_isFaction) then {

		// No Perk - 0, L1 Perk - 0.25, L2 - .5, L3 - .75, L4 - 1
		private _perkValue = ["GeneralMechanic", 0] call ULP_fnc_activatePerk;

		// For everyone but HATO apply "General Mechanic" Perk
		if ((1 - _perkValue) <= (random 1)) exitWith {
			["You kept your toolkit."] call ULP_fnc_hint;
		};

		player removeItem "Toolkit";
	};

	_vehicle setDamage 0;
	[format["You've repaired <t color='#B92DE0'>%1</t> using a toolkit.", _name]] call ULP_fnc_hint;

	if (time >= (_vehicle getVariable ["ProfessionCooldown", time - 120])) then {
		["Repairing", 1, 40] call ULP_fnc_increaseProfession;
		_vehicle setVariable ["ProfessionCooldown", time + 120];
	};
}, {}, ["GRAB", "CROUCH"]] call ULP_UI_fnc_startProgress) exitWith {
	["You can't repair a vehicle while performing another action!"] call ULP_fnc_hint;
};

closeDialog 0;