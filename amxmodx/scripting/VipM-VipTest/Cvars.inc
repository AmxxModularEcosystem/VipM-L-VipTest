#include <amxmodx>

new const CVAR_NAME_PREFIX[] = "VipM_VipTest_";
#define CvarReg(%1,%2) \
    create_cvar(fmt("%s%s", CVAR_NAME_PREFIX, %1), %2)

enum E_Cvars {
    Cvar_Duration,
    Cvar_Cooldown,
}
new gCvars[E_Cvars];

#define Cvar(%1) \
    gCvars[Cvar_%1]

InitCvars() {
    new pDuration, pCooldown;
    hook_cvar_change(pDuration = CvarReg("Duration", "1d1h30i59", FCVAR_NONE, Lang("VIPM_VIPTEST_CVAR_DURATION")), "@Cvar_Duration");
    hook_cvar_change(pCooldown = CvarReg("Cooldown", "0", FCVAR_NONE, Lang("VIPM_VIPTEST_CVAR_COOLDOWN")), "@Cvar_Cooldown");

    AutoExecConfig(true, "VipM-VipTest");

    new sVal[32];
    get_pcvar_string(pDuration, sVal, charsmax(sVal));
    Cvar(Duration) = ParseTimeLength(sVal);
    
    get_pcvar_string(pCooldown, sVal, charsmax(sVal));
    Cvar(Cooldown) = ParseTimeLength(sVal);
}

@Cvar_Duration(pCvar, const sOldValue[], const sNewValue[]) {
    Cvar(Duration) = ParseTimeLength(sNewValue);
}

@Cvar_Cooldown(pCvar, const sOldValue[], const sNewValue[]) {
    Cvar(Cooldown) = ParseTimeLength(sNewValue);
}