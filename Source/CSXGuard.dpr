library CSXGuard;

{$I CSXGuard.inc}

uses CvarDef, HLSDK, MemSearch, Windows, SysUtils, Parser, CMDBlock, MSGBlock, QCCBlock,
     Extended, Detours, VoiceExt, ResBlock, Scripting, Shutdown, MsgAPI, Common;

procedure DebuggerEntryPoint; stdcall;
begin
Sleep(1);
end;

procedure HUD_Frame(const Time: Double); cdecl;
begin
if FirstFrame then
 begin
  GetClientInfo;
  ReadConfig;
  
  Find_GameInfo;
  if VerifyGameName and (StrLIComp(Engine.GetGameDirectory, 'cstrike', Length('cstrike')) <> 0) then
   Error(GameName_Extra);

  Engine.AddCommand('csx_debug', @Debug);
  Engine.AddCommand('csx_debug2', @Debug2);
  Engine.AddCommand('csx_debug3', @Debug3);
  
  Engine.AddCommand('csx_showcvars', @Cmd_ShowCVars);
  Engine.AddCommand('csx_setcvar', @Cmd_SetCvar);
  Engine.AddCommand('csx_debug_parser', @Cmd_Debug_Parser);

  if ExtendedScripting then
   begin
    Engine.AddCommand('if', @Cmd_Condition);
    Engine.AddCommand('loop', @Cmd_Loop);
   end;

  if EmulateSpecialAlias then
   if Protocol = 48 then
    Engine.AddCommand('special', @Cmd_Special)
   else
    Print('EmulateSpecialAlias: "special" alias does not need to be emulated on your client.');

  Find_SVCBase;
  Find_MSGInterface;
  Find_IsValidCmd;
  Find_GameConsole003;
  Find_SetValueForKey;
  Find_COM_DefaultExtension;
  Find_Spectator;
  Find_COM_ExplainDisconnection;
  Find_CL_ExitGame;
  Find_Host_Error;
  Find_Cmd_Source;
  Find_StopHTTPDownload;
  Find_GameUI_StopProgressBar;

  CvarDef.SVC_StuffText_Orig := HookServerMessage(HLSDK.SVC_STUFFTEXT, @CMDBlock.SVC_StuffText);

  if ExtendedVoiceInterface then
   begin
    CvarDef.SVC_VoiceData_Orig := HookServerMessage(HLSDK.SVC_VOICEDATA, @VoiceExt.SVC_VoiceData);
    CvarDef.SVC_VoiceInit_Orig := HookServerMessage(HLSDK.SVC_VOICEINIT, @VoiceExt.SVC_VoiceInit);
   end;

  if SVCCount >= HLSDK.SVC_SENDCVARVALUE then
   begin // QCC
    CvarDef.SVC_SendCvarValue_Orig := HookServerMessage(HLSDK.SVC_SENDCVARVALUE, @QCCBlock.SVC_SendCvarValue);
    if SVCCount >= HLSDK.SVC_SENDCVARVALUE2 then // QCC2
     CvarDef.SVC_SendCvarValue2_Orig := HookServerMessage(HLSDK.SVC_SENDCVARVALUE2, @QCCBlock.SVC_SendCvarValue2)
    else // does not support QCC2
     if BlockCvarQueries then
      Print('BlockCVarQueries: Your client does not support extended CVar queries (QCC2).');
   end
  else // does not support QCC and QCC2
   if BlockCvarQueries then
    Print('BlockCVarQueries: Your client does not support CVar queries (QCC and QCC2).');

  UserMsgBase := PPointer(UserMsgBase)^;
  SVC_MOTD_Orig := HookUserMessage('MOTD', MSGBlock.SVC_MOTD);

  Patch_CL_ConnectionlessPacket;

  if RemoveInterpolationLimit then
   begin
    Find_CommandBounds;
    Patch_CL_CheckCommandBounds;
   end;

  if FPSLimitPatchType <> [] then
   if not SW then
    Patch_Host_FilterTime
   else
    Patch_Host_FilterTime_SW;

  if RemoveAliasCheck then
   if Protocol = 48 then
    Patch_CMD_Alias
   else
    Print('RemoveAliasCheck: Your client does not need to be patched.');

  Cmd_ExecuteString_Gate := Detour(@Cmd_ExecuteString_Orig, @CMDBlock.Cmd_ExecuteString, 8 - Cardinal(SW) * 2);
  Patch_Cmd_ForwardToServer;

  if OverrideFrameMSec then
   Patch_CL_Move;

  if OverrideFileCheck then
   begin
    FileCheckingEnabled := Find_IsValidFile;
    Patch_IsValidFile;
   end;

  if RemoveCVarProtection then
   Patch_CVar_Command;

  if RemoveLocalInfoValidation then
   Patch_SetValueForKey;

  if RemoveCVarValidation then
   begin
    Find_R_CheckVariables;
    Patch_R_CheckVariables;
   end;

  if OverrideMovieRecording then
   Patch_Cmd_StartMovie;

  if EnableSteamIDSpoof then
   if (Protocol = 47) or not Find_SteamIDPtr then
    Print('EnableSteamIDSpoof: SteamID spoofing can''t be done on your client.')
   else
    Engine.AddCommand('csx_steamid', @ChangeSteamID);
    
  if OverrideKeyState then
   begin
    Find_Sys_ResetKeyState;
    Find_Key_ClearStates;
    Find_KeyBindings;
    Find_KeyShift;
    Patch_Sys_ResetKeyState;
   end;
   
  if EnableResourceCheck then
   begin
    Find_CL_ParseResourceList;
    Find_CL_StartResourceDownloading;
    Find_CL_ResourceBatchDownload;
    Find_CL_ResourceDownload;
    CL_ResourceDownload_Gate := Detour(@CL_ResourceDownload_Orig, @ResBlock.CL_ResourceDownload, 6 + Cardinal(SW) * 3);
   end;

  if PatchSpawnCommand then
   Cmd_Spawn_Orig := HookCommand('spawn', @Cmd_Spawn);

  if ExtendedVoiceInterface then
   VX_Init;

  PrintInfo;

  if EmptyConfig then
   COM_ShowMessage(ParserWarning_Extra);

  if ShowConsole then
   COM_ShowConsole;

  ReleaseMessages;
  FirstFrame := False;
 end;

Client.HUD_Frame(Time);
end;

function Main(const Parameter: Pointer): Longint;
var
 I: LongWord;
label Return;
begin
for I := 1 to SEARCH_RETRY_COUNT do
 if FindEngineAndClient then
  goto Return;
Error('Couldn''t find default scanning pattern.', ExportTable_Extra);

Return:

while not Initialized do
 Delay(90);

FindStudio;

Move(PEngine^, Engine, SizeOf(Engine));
Move(PStudio^, Studio, SizeOf(Studio));
Move(PClient^, Client, SizeOf(Client));
SW := Studio.IsHardware = 0;

UserMsgBase := PPointer(Cardinal(@HookUserMsg) + 13 - Cardinal(SW) * 3)^;

Find_Cmd_TokenizeString;
Find_Cmd_Args;
Find_Sys_Error;
Find_COM_Parse;
Find_COM_Token;
Find_CBuf_AddText;
Find_CBuf_Execute;
Find_Cmd_ExecuteString;
Find_CState;
Find_CVar_Command;
Find_LastArgString;

PClient.HUD_Frame := HUD_Frame;

Init := True;
Result := 0;
EndThread(0);
end;

begin
{$IFDEF DEBUG} DebuggerEntryPoint; {$ENDIF}

CPUType := GetCPUType;
Set8087CW($133F);
RandSeed := GetTickCount;
DecimalSeparator := '.';
IsMultiThread := True;

MutexID := CreateMutex(nil, True, PChar('CSXGuard_Mutex' + IntToHex(GetCurrentProcessID, 8)));
if GetLastError <> ERROR_ALREADY_EXISTS then
 begin
  GetRendererInfo;
  ThreadID := BeginThread(nil, 0, @Main, nil, 0, LongWord(nil^));
 end;
end.
