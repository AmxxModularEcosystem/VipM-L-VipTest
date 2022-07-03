#include <amxmodx>
#include <json>
#include <nvault>
#include <VipModular>
#include "VipM-VipTest/CommandAliases"
#include "VipM-VipTest/Utils"
#include "VipM-VipTest/Cvars"

public stock const PluginName[] = "[VipM][L] Vip Test";
public stock const PluginVersion[] = "1.0.0";
public stock const PluginAuthor[] = "ArKaNeMaN";
public stock const PluginURL[] = "https://github.com/ArKaNeMaN/VipM-L-VipTest";
public stock const PluginDescription[] = "Vip testing for Vip Modular.";

new const VIPM_LIMIT_NAME[] = "VipTest";
new const NVAULT_FILE_NAME[] = "VipM-VipTest";

#define GetSteamId(%1) \
    gUserSteamIds[%1 - 1]

new ghNvault = INVALID_HANDLE;
new gUserSteamIds[MAX_PLAYERS][35];

public VipM_OnInitModules() {
    register_plugin(PluginName, PluginVersion, PluginAuthor);
    register_dictionary("VipM-VipTest.ini");
    InitCvars();

    if ((ghNvault = nvault_open(NVAULT_FILE_NAME)) == INVALID_HANDLE) {
        set_fail_state("[ERROR] Can`t open/create nVault file `%s`.", NVAULT_FILE_NAME);
        return;
    }

    VipM_Limits_RegisterType(VIPM_LIMIT_NAME, true);
    VipM_Limits_RegisterTypeEvent(VIPM_LIMIT_NAME, Limit_OnCheck, "@OnCheck");

    CommandAliases_Open(inl_VipM_GetCfgPath("Cmds/VipTest.json"), true);
    CommandAliases_RegisterClient("viptest", "@Cmd_VipTest");
    CommandAliases_Close();

    register_srvcmd("vipm_viptest_info", "@SrvCmd_Info");
}

@SrvCmd_Info() {
    server_print("%s v%s by %s:", PluginName, PluginVersion, PluginAuthor);
    server_print("  Cvars:");
    server_print("    - Duration = %d seconds", Cvar(Duration));
    if (Cvar(Cooldown)) {
        server_print("    - Cooldown = %d seconds", Cvar(Cooldown));
    } else {
        server_print("    - Cooldown = (disabled)");
    }
}

public client_authorized(UserId, const SteamId[]) {
    copy(GetSteamId(UserId), charsmax(gUserSteamIds[]), SteamId);
}

public plugin_end() {
    nvault_close(ghNvault);
}

bool:@OnCheck(const Trie:Params, const UserId) {
    if (!nvault_has(ghNvault, GetSteamId(UserId))) {
        return false;
    }

    return (nvault_get(ghNvault, GetSteamId(UserId)) + Cvar(Duration) > get_systime());
}

@Cmd_VipTest(const UserId) {
    new tsSysTime = get_systime();

    if (nvault_has(ghNvault, GetSteamId(UserId))) {
        new tsActivatedAt = nvault_get(ghNvault, GetSteamId(UserId));

        new iTimeLeft = (tsActivatedAt + Cvar(Duration)) - tsSysTime;
        if (iTimeLeft > 0) {
            new sFormattedTimeLeft[64];
            TimeLengthFormat(iTimeLeft, sFormattedTimeLeft, charsmax(sFormattedTimeLeft));
            ChatPrintL(UserId, "VIPM_VIPTEST_MSG_ALREADY_ACTIVE", sFormattedTimeLeft);
            return PLUGIN_HANDLED;
        }

        if (
            Cvar(Cooldown) <= 0
            || tsActivatedAt + Cvar(Cooldown) > tsSysTime
        ) {
            ChatPrintL(UserId, "VIPM_VIPTEST_MSG_ALREADY_USED");
            return PLUGIN_HANDLED;
        }
    }

    nvault_pset(ghNvault, GetSteamId(UserId), IntToStr(tsSysTime));

    new sFormattedDuration[64];
    TimeLengthFormat(Cvar(Duration), sFormattedDuration, charsmax(sFormattedDuration));
    ChatPrintL(UserId, "VIPM_VIPTEST_MSG_ACTIVATED", sFormattedDuration);

    return PLUGIN_HANDLED;
}
