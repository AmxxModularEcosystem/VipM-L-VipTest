#include <amxmodx>
#include <nvault>
#include <VipModular>

public stock const PluginName[] = "[VipM][AM] Vip Test";
public stock const PluginVersion[] = "1.0.0";
public stock const PluginAuthor[] = "ArKaNeMaN";
public stock const PluginURL[] = "t.me/arkaneman";
public stock const PluginDescription[] = "Vip testing for Vip Modular.";

stock const __NUM_STR[] = "%d";
#define IntToStr(%1) \
    fmt(__NUM_STR, %1)

#define Cvar(%1) \
 Cvars[Cvar_%1]

#define CvarReg(%1,%2) \
    create_cvar(fmt("%s%s", CVAR_NAME_PREFIX, %1), %2)

#define CvarRegInt(%1,%2) \
    bind_pcvar_num(CvarReg(%2), Cvar(%1))

stock __nvault_has_TEMP;
#define nvault_has(%1,%2) \
    bool:nvault_lookup(%1, %2, "", 0, __nvault_has_TEMP)

new const VIPM_ACCESS_MODE_NAME[] = "VipTest";
new const NVAULT_FILE_NAME[] = "VipM-VipTest";
new const CVAR_NAME_PREFIX[] = "VipM_VipTest_";

enum E_Cvars {
    Cvar_Duration,
}
new Cvars[E_Cvars];

new ghNvault = INVALID_HANDLE;

public VipM_OnInitModules(){
    register_plugin(PluginName, PluginVersion, PluginAuthor);
    InitCvars();

    if((ghNvault = nvault_open(NVAULT_FILE_NAME)) == INVALID_HANDLE){
        set_fail_state("[ERROR] Can`t open/create nVault file `%s`.", NVAULT_FILE_NAME);
        return;
    }

    VipM_RegisterAccessMode(VIPM_ACCESS_MODE_NAME);
    VipM_RegisterAccessModeEvent(VIPM_ACCESS_MODE_NAME, AccessMode_OnCheck, "@OnCheck");

    RegisterClCmds("viptest", "@OnCmdVipTest");
}

public plugin_end(){
    nvault_close(ghNvault);
}

bool:@OnCheck(const UserId, const Trie:Params){
    static SteamId[64];
    get_user_authid(UserId, SteamId, charsmax(SteamId));

    if(!nvault_has(ghNvault, SteamId))
        return false;

    return (nvault_get(ghNvault, SteamId) + (Cvar(Duration) * 60 * 60) > get_systime());
}

@OnCmdVipTest(const UserId){
    static SteamId[64];
    get_user_authid(UserId, SteamId, charsmax(SteamId));
    
    if(nvault_has(ghNvault, SteamId)){
        client_print_color(UserId, print_team_default, "^4[^3VipTest^4] ^3Вы уже брали тестовую VIP.");
        return PLUGIN_HANDLED;
    }

    nvault_pset(ghNvault, SteamId, IntToStr(get_systime()));
    client_print_color(UserId, print_team_default, "^4[^3VipTest^4] ^3Вы взяли тестовую VIP на ^4%d часа^3.");
    return PLUGIN_HANDLED;
}

RegisterClCmds(const Cmd[], const Handler[], const ChatCmdPrefix[] = "/"){
    register_clcmd(Cmd, Handler);
    register_clcmd(fmt("say %s%s", ChatCmdPrefix, Cmd), Handler);
    register_clcmd(fmt("say_team %s%s", ChatCmdPrefix, Cmd), Handler);
}

InitCvars(){
    CvarRegInt(Duration, "Duration", "24", _, "Длительность теста в часах", true, 1.0);

    AutoExecConfig(true, "VipM-VipTest");
}