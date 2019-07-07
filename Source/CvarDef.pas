unit CvarDef;

{$I CSXGuard.inc}

interface

uses HLSDK;

const
 DEFAULT_PROTOCOL = 47;
 SEARCH_RETRY_COUNT = 10;

 MAX_EXPRESSIONS = 64;
 MAX_EXPRESSION_LENGTH = 128;

 DEFAULT_COMMAND_LENGTH = MAX_STRINGCMD + SizeOf(Char);
 DEFAULT_EXPR_LENGTH = MAX_EXPRESSION_LENGTH + SizeOf(Char);

 EXPR_STRCOMP = 1;
 EXPR_STRICOMP = 2;
 EXPR_STRPOS = 3;
 EXPR_STRIPOS = 4;
 EXPR_STREQUAL = 5;
 EXPR_STRIEQUAL = 6;
 EXPR_EXIT = 7;

 PATCH_TYPE_GLOBAL = False;
 PATCH_TYPE_SETINFO = True;

 CMD_COLOR_R = 30;
 CMD_COLOR_G = 230;
 CMD_COLOR_B = 30;

 PREFIX_COLOR_R = 255;
 PREFIX_COLOR_G = 255;
 PREFIX_COLOR_B = 255;

 CMD_SV_PREFIX: Byte = $FF;

 CMD_CL = 0;
 CMD_SV = 1;
 CMD_INVALID = 2;

 HOST_PARSER = 0;
 HOST_CONSOLE = 1;

type
 TCPUType = (CPU_UNKNOWN = 0, CPU_80386, CPU_80486, CPU_DEFAULT = CPU_80486);

 TPrintFlags = packed set of (PRINT_PREFIX = 0, PRINT_LINE_BREAK, PRINT_DEVELOPER);

 PExpression = ^TExpression;
 TExpression = packed record
  ExprType, CmpOffset, CmpLength: Longint;
  Data: packed array[1..DEFAULT_EXPR_LENGTH] of Char;
 end;
 
 PDataArray = ^TDataArray;
 TDataArray = packed array[1..MaxInt div DEFAULT_COMMAND_LENGTH] of packed array[1..DEFAULT_COMMAND_LENGTH] of Char;

 PExprArray = ^TExprArray;
 TExprArray = packed array[1..MaxInt div SizeOf(TExpression)] of TExpression;

 TListType = (LIST_STRING = 0, LIST_CRC, LIST_EXPRESSION, LIST_DEFAULT);

 PStringArray = ^TStringArray;
 TStringArray = packed array[1..MaxInt div DEFAULT_COMMAND_LENGTH] of packed array[1..DEFAULT_COMMAND_LENGTH] of Char;

 PCRCArray = ^TCRCArray;
 TCRCArray = packed array[1..MaxInt div SizeOf(LongWord)] of LongWord;
 
var
 CPUType: TCPUType = CPU_UNKNOWN;

 ThreadID: LongWord = 0;
 MutexID: LongWord = 0;

 HLBase, HLSize, HLBase_End: LongWord;
 CLBase, CLSize, CLBase_End: LongWord;
 RendererType: (RENDERER_UNDEFINED = 0, RENDERER_HARDWARE, RENDERER_SOFTWARE);

 Engine: cl_enginefuncs_t;
 PEngine: ^cl_enginefuncs_t = nil;
 EngineVersion: LongWord = ENGINE_INTERFACE_VERSION;

 Studio: engine_studio_api_t;
 PStudio: ^engine_studio_api_t = nil;
 StudioVersion: LongWord = STUDIO_INTERFACE_VERSION;

 Client: ExportTable_t;
 PClient: ^ExportTable_t = nil;
 ClientVersion: LongWord = CLDLL_INTERFACE_VERSION;

 PStudioInterface: r_studio_interface_s = nil;

 HookUserMsg: function(const Name: PChar; const Callback: TUserMsgHook): Longint; cdecl = nil;
 UserMsgBase: user_msg_s = nil;

 GameName, GameVersion: PChar;
 Protocol: Byte = DEFAULT_PROTOCOL;
 Build: Longint;

 Init: Boolean = False;
 FirstFrame: Boolean = True;
 SW: Boolean = False;

var
 Cmd_TokenizeString_Orig: HLSDK.Cmd_TokenizeString = nil;
 Cmd_Args: HLSDK.Cmd_Args = nil;
 Sys_Error: HLSDK.Sys_Error = nil;
 COM_Parse: HLSDK.COM_Parse = nil;
 COM_Token: ^HLSDK.COM_Token = nil;
 CBuf_AddText: HLSDK.CBuf_AddText = nil;
 CBuf_Execute: HLSDK.CBuf_Execute = nil;
 Cmd_ExecuteString_Orig: HLSDK.Cmd_ExecuteString = nil;
 Cmd_ExecuteString_Gate: HLSDK.Cmd_ExecuteString = nil;
 CState: ^cactive_t = nil;
 CVar_Command: HLSDK.CVar_Command = nil;
 LastArgString: PPChar = nil;
 
 SVCBase: server_msg_array_s = nil;
 SVCBase_End: Pointer = nil;
 SVCCount: Cardinal = 0;

 MSG_ReadByte: HLSDK.MSG_ReadByte;
 MSG_ReadChar: HLSDK.MSG_ReadChar;
 MSG_ReadShort: HLSDK.MSG_ReadShort;
 MSG_ReadLong: HLSDK.MSG_ReadLong;
 MSG_ReadFloat: HLSDK.MSG_ReadFloat;
 MSG_ReadString: HLSDK.MSG_ReadString;
 MSG_ReadAngle16: HLSDK.MSG_ReadAngle16;
 MSG_ReadBits: HLSDK.MSG_ReadBits;
 MSG_StartBitReading: HLSDK.MSG_StartBitReading;
 MSG_EndBitReading: HLSDK.MSG_EndBitReading;

 MSG_ReadCount: PLongint = nil;
 MSG_CurrentSize: PLongint = nil;
 MSG_BadRead: PLongint = nil;
 MSG_Base: PPointer = nil;
 
 MSG_SavedReadCount: Longint = 0;

 IsValidCmd: HLSDK.IsValidCmd = nil;
 GameConsole003: PGameConsole003 = nil;
 Console_TextColor: PColor24 = nil;
 Console_TextColorDev: PColor24 = nil;
 SetValueForKey: HLSDK.SetValueForKey = nil;
 COM_DefaultExtension: HLSDK.COM_DefaultExtension = nil;
 Spectator: PLongint = nil;
 COM_ExplainDisconnection: HLSDK.COM_ExplainDisconnection = nil;
 CL_ExitGame: HLSDK.CL_ExitGame = nil;
 Host_Error: HLSDK.Host_Error = nil;
 Cmd_Source: PLongint = nil;
 Cmd_Spawn_Orig: TCallback = nil;
 GameUI007: PGameUI007 = nil;
 StopHTTPDownload: HLSDK.StopHTTPDownload = nil;
 GameUI_StopProgressBar: HLSDK.GameUI_StopProgressBar = nil;

 SVC_StuffText_Orig: HLSDK.TCallback = nil;
 SVC_VoiceInit_Orig: HLSDK.TCallback = nil;
 SVC_VoiceData_Orig: HLSDK.TCallback = nil;
 SVC_SendCvarValue_Orig: HLSDK.TCallback = nil;
 SVC_SendCvarValue2_Orig: HLSDK.TCallback = nil;
 SVC_MOTD_Orig: HLSDK.TUserMsgHook = nil;

 CL_CheckCommandBounds: HLSDK.CL_CheckCommandBounds = nil;
 Cmd_ForwardToServer_Orig: HLSDK.Cmd_ForwardToServer = nil;
 CL_Move_Patch_Gate: Pointer = nil;
 IsValidFile_Orig: HLSDK.IsValidFile = nil;
 MOTDFile: cvar_s = nil;
 Cmd_MOTD_Write_Orig: HLSDK.TCallback = nil;
 CL_ParseServerInfo: procedure; cdecl = nil;
 R_CheckVariables: HLSDK.R_CheckVariables = nil;
 Cmd_Argv_Patch_Gate: HLSDK.Cmd_Argv = nil;
 SteamIDPtr: PLongWord = nil;
 Sys_ResetKeyState_Orig: HLSDK.Sys_ResetKeyState = nil;
 Sys_ResetKeyState_Gate: HLSDK.Sys_ResetKeyState = nil; 
 Key_ClearStates: HLSDK.Key_ClearStates = nil;
 KeyBindings: key_bindings_s = nil;
 KeyShift: key_shift_s = nil;
 CL_ParseResourceList: HLSDK.CL_ParseResourceList = nil;
 CL_StartResourceDownloading: HLSDK.CL_StartResourceDownloading = nil;
 CL_ResourceBatchDownload: HLSDK.CL_ResourceBatchDownload = nil;
 CL_ResourceDownload_Orig: HLSDK.CL_ResourceDownload = nil;
 CL_ResourceDownload_Gate: HLSDK.CL_ResourceDownload = nil;

var
 Enabled: Boolean = True;
 ShowConsole: Boolean = True;
 VerifyGameName: Boolean = True;

 LogBlocks: Boolean = True;
 LogForwards: Boolean = False;
 LogDeveloper: Boolean = False;
 BlockCommands: Boolean = True;
 BlockCVarQueries: Boolean = True;
 BlockMOTD: Boolean = True;

 RemoveInterpolationLimit: Boolean = False;

 ExtendedForwarding: Boolean = True;
 BlockAllForwards: Boolean = False;
 EnableAllForwards: Boolean = False;

 RemoveAliasCheck: Boolean = True;
 EmulateSpecialAlias: Boolean = True;
 FastSpecialAlias: Boolean = False;

 OverrideFileCheck: Boolean = True;
 MaxExtensionLength: LongWord = 3;

 RemoveCVarProtection: Boolean = True;
 RemoveCVarValidation: Boolean = True;
 RemoveLocalInfoValidation: Boolean = True;
 LocalInfoPatchType: Boolean = PATCH_TYPE_SETINFO;

 OverrideFrameMSec: Boolean = False;
 FrameMSec_Min: Byte = 0;

 // v2
 OverrideMovieRecording: Boolean = True;
 ExtendedVoiceInterface: Boolean = True;
 ShowCommandParameters: Boolean = False;
 EnableSteamIDSpoof: Boolean = False;

 // v3
 OverrideKeyState: Boolean = True;
 EnableResourceCheck: Boolean = True;

 // v4
 FPSLimitPatchType: packed set of (PATCH_30FPS = 0, PATCH_100FPS, PATCH_1000FPS) = [PATCH_30FPS, PATCH_1000FPS];
 PatchSpawnCommand: Boolean = True;
 ExtendedScripting: Boolean = True;

var
 FileCheckingEnabled: Boolean = True;
 KeyStateActive: Boolean = False;
 HTTPDownloadEnabled: Boolean = True;

 Cmd_AlreadyForwarded: Boolean = False;
 Cmd_Processing: Boolean = False;
 Cmd_LastCmdType: Byte = CMD_INVALID;

 Commands, BlockFWD_CL, BlockFWD_SV, EnableFWD_CL, EnableFWD_SV, QCC, KeyBinds: PDataArray;

 CommandCount: LongWord = 0;
 BlockFWD_CL_Count: LongWord = 0;
 BlockFWD_SV_Count: LongWord = 0;
 EnableFWD_CL_Count: LongWord = 0;
 EnableFWD_SV_Count: LongWord = 0;
 QCC_Count: LongWord = 0;
 KeyBinds_Count: LongWord = 0;

 FileExpr: PExprArray;
 FileExpr_Count: LongWord = 0;

 EmptyConfig: Boolean = False;

const
 Prefix = 'CSXGuard';
 Name = Prefix + ' v4';

 GameName_Extra = 'FATAL ERROR: Incorrect game name.' + sLineBreak + sLineBreak +

                  'Notice: ' + sLineBreak +
                  'This software was designed for Counter-Strike 1.6.' + sLineBreak +
                  'Sorry, but there is really no way to make it work under any other GoldSource game.' + sLineBreak;

 ExportTable_Extra = sLineBreak + sLineBreak +
                    'This error usually occurs if the renderer was not yet initialized.' + sLineBreak +
                    'You should try injecting this software with different method (native *.asi-loader, as example).';

 ParserWarning_Extra = 'Couldn''t find the configuration file (CSXGuard.ini).' + #$A + 
                       'Some features (command blocking and forwarding) may not be avaliable.';

 Madotsuki_WelcomeMsg = #$D0#$9F#$D1#$80#$D0#$B8#$D0#$B2#$D0#$B5#$D1#$82#$20#$D0#$BE#$D1#$82#$20#$D0#$9C#$D0#$B0#$D0#$B4#$D0#$BE#$D1#$86#$D1#$83#$D0#$BA#$D0#$B8#$20#$5E#$5F#$5E;

const
 BaseHook_Version = 7;

implementation

end.
