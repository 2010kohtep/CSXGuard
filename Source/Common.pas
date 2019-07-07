unit Common;

{$I CSXGuard.inc}

interface

uses HLSDK, CvarDef;

function GetCPUType: TCPUType;

function Min(Value1, Value2: LongWord): LongWord;
function Max(Value1, Value2: LongWord): LongWord;

function GetModuleSize(Address: LongWord): LongWord;
procedure GetRendererInfo;
procedure GetClientInfo;

function CRC32_ProcessBuffer(Sequence: LongWord; const Buffer: Pointer; Size: LongWord): LongWord;
function CRC32_ProcessString(const Str: String): LongWord;

function StrComp(const Str1, Str2: PChar): Longint;
function StrIComp(const Str1, Str2: PChar): Longint;
function StrLComp(const Str1, Str2: PChar; MaxLen: LongWord): Longint;
function StrLIComp(const Str1, Str2: PChar; MaxLen: LongWord): Longint;
function StrLen(const Str: PChar): LongWord;

procedure COM_FixSlashes(var Str: String);
procedure COM_FixSlashes2(var Str: String);
function COM_GetFileList(const BaseDir: String; const RecursiveCall: Boolean = False): String;
procedure COM_DefaultExtension(var Str: String; const Extension: String; DefaultLength: LongWord = 0);
procedure COM_StripTrailingSlash(var Str: String; const TrimRight: Boolean = False);
function COM_HasExtension(const Str: String): Boolean;
procedure COM_StripExtension(var Str: String);
procedure COM_IncludeStr(SubStr: Char; var Dest: String);
procedure COM_ExcludeStr(SubStr: Char; var Dest: String);

procedure TrimRight(var Str: String);
function COM_IntToHex(Value: LongWord): String; overload;
function COM_IntToHex(const Value: Pointer): String; overload;

procedure AddToLinkedList(var Base: Pointer; const Item: Pointer; const Offset: LongWord = 0);

procedure Delay(MSec: LongWord);

procedure Alert(const Msg: String); overload;
procedure Alert(const Addr: Pointer); overload;
procedure Error(const Msg: String); overload;
procedure Error(const Str1, Str2: String); overload;
procedure Error(const Str1, Str2, Str3: String); overload;
procedure Error(const Str1, Str2, Str3, Str4: String); overload;
procedure Error(const Str1, Str2, Str3, Str4, Str5: String); overload;

function Address(Ptr: LongWord): String; overload;
function Address(const Ptr: Pointer): String; overload;
function Address(const Name: String; Ptr: LongWord): String; overload;
function Address(const Name: String; const Ptr: Pointer): String; overload;

procedure PrintVariable(const Name: String; Value: Boolean); overload;
procedure PrintVariable(const Name: String; Value: Longint); overload;
procedure PrintVariable(const Name: String; Value: Single); overload;
procedure PrintVariable(const Name, Value: String); overload;

procedure PrintAddress(const Name: String; const Ptr: Pointer);
procedure PrintSearchError(const S: PChar);

procedure COM_ShowMessage(const Str: String);

procedure COM_Munge(const Data: Pointer; Size, Sequence: LongWord); cdecl;
procedure COM_UnMunge(const Data: Pointer; Size, Sequence: LongWord); cdecl;

function CheckRelativePath(const Str: PChar): Boolean;
procedure COM_FillChar(const Dest: Pointer; Size: LongWord; Value: Byte);
procedure StringReplace(var Str: String; OldChar, NewChar: Char);

procedure Debug; cdecl;
procedure Debug2; cdecl;
procedure Debug3; cdecl;
procedure Cmd_SetCvar; cdecl;
procedure Cmd_Special; cdecl;
procedure ChangeSteamID; cdecl;

procedure PrintStatus(const Name: PChar; const Status: String; R: Byte = CMD_COLOR_R; G: Byte = CMD_COLOR_G; B: Byte = CMD_COLOR_B);
procedure PrintInfo;

procedure COM_ShowConsole;

procedure SaveClassPointer;
procedure RestoreClassPointer;

function CommandByName(const Name: String; const Error: Boolean = True): cmd_s;
function UserMsgByName(const Name: String): user_msg_s;

procedure CheckCallback(const Cmd: cmd_s; const UseClientBounds: Boolean = False; const CheckAlign: Boolean = True);

function HookServerMessage(const Index: Cardinal; const Callback: TCallback): TCallback; overload;
function HookServerMessage(const ServerMsg: server_msg_s; const Callback: TCallback): TCallback; overload;
function HookServerMessage(const Name: String; const Callback: TCallback): TCallback; overload;

function HookUserMessage(const Name: String; const Callback: TUserMsgHook): TUserMsgHook; overload;
function HookUserMessage(const UserMsg: user_msg_s; const Callback: TUserMsgHook): TUserMsgHook; overload;

function GetCallback(Index: LongWord): LongWord;

procedure MSG_SaveReadCount;
procedure MSG_RestoreReadCount;

function HookCommand(const Name: String; const Callback: TCallback): TCallback;

function Expr_Process(const List: PExprArray; Count: LongWord; const Str: PChar; StrLength: LongWord; const StrLC: PChar = nil): Boolean;

function Initialized: Boolean;

implementation

uses Windows, SysUtils, Parser, MsgAPI, MemSearch, VoiceExt;

const
 EncodeTable: array[1..16] of Byte =
             ($8A, $64, $05, $F1, $1B, $9B, $A0, $B5,
              $CA, $ED, $61, $0D, $4A, $DF, $8E, $C7);

procedure Debug; cdecl;
begin
Print(Name + #$A, 80, 255, 50, [PRINT_LINE_BREAK]);

Print('Engine: $' + Address(@Engine) + '; PEngine: $' + Address(PEngine) + '; EngineVersion: ' + IntToStr(EngineVersion), [PRINT_LINE_BREAK]);
Print('Studio: $' + Address(@Studio) + '; PStudio: $' + Address(PStudio) + '; StudioVersion: ' + IntToStr(StudioVersion), [PRINT_LINE_BREAK]);
Print('Client: $' + Address(@Client) + '; PClient: $' + Address(PClient) + '; ClientVersion: ' + IntToStr(ClientVersion), [PRINT_LINE_BREAK]);
PrintAddress('HookUserMsg', @CvarDef.HookUserMsg);
PrintAddress('UserMsgBase', CvarDef.UserMsgBase);
PrintAddress('PStudioInterface', PStudioInterface);
Print('', [PRINT_LINE_BREAK]);

PrintAddress('Cmd_TokenizeString', @CvarDef.Cmd_TokenizeString_Orig);
PrintAddress('Cmd_Args', @CvarDef.Cmd_Args);
PrintAddress('Sys_Error', @CvarDef.Sys_Error);
PrintAddress('COM_Parse', @CvarDef.COM_Parse);
PrintAddress('COM_Token', CvarDef.COM_Token);
PrintAddress('CBuf_AddText', @CvarDef.CBuf_AddText);
PrintAddress('CBuf_Execute', @CvarDef.CBuf_Execute);
PrintAddress('Cmd_ExecuteString', @CvarDef.Cmd_ExecuteString_Orig);
PrintAddress('CState', CvarDef.CState);
PrintAddress('CVar_Command', @CvarDef.CVar_Command);
PrintAddress('LastArgString', CvarDef.LastArgString);
Print('', [PRINT_LINE_BREAK]);

PrintAddress('SVCBase', CvarDef.SVCBase);
PrintAddress('SVCBase_End', CvarDef.SVCBase_End);
Print('SVCCount: ' + IntToStr(CvarDef.SVCCount), [PRINT_LINE_BREAK]);
PrintAddress('MSG_ReadByte', @CvarDef.MSG_ReadByte);
PrintAddress('MSG_ReadChar', @CvarDef.MSG_ReadChar);
PrintAddress('MSG_ReadShort', @CvarDef.MSG_ReadShort);
PrintAddress('MSG_ReadLong', @CvarDef.MSG_ReadLong);
PrintAddress('MSG_ReadFloat', @CvarDef.MSG_ReadFloat);
PrintAddress('MSG_ReadString', @CvarDef.MSG_ReadString);
PrintAddress('MSG_ReadAngle16', @CvarDef.MSG_ReadAngle16);
PrintAddress('MSG_StartBitReading', @CvarDef.MSG_StartBitReading);
PrintAddress('MSG_EndBitReading', @CvarDef.MSG_EndBitReading);
PrintAddress('MSG_ReadCount', CvarDef.MSG_ReadCount);
PrintAddress('MSG_CurrentSize', CvarDef.MSG_CurrentSize);
PrintAddress('MSG_BadRead', CvarDef.MSG_BadRead);
PrintAddress('MSG_Base', CvarDef.MSG_Base);
Print('', [PRINT_LINE_BREAK]);

PrintAddress('IsValidCmd', @CvarDef.IsValidCmd);
PrintAddress('GameConsole003', CvarDef.GameConsole003);
PrintAddress('Console_TextColor', CvarDef.Console_TextColor);
PrintAddress('Console_TextColorDev', CvarDef.Console_TextColorDev);
PrintAddress('SetValueForKey', @CvarDef.SetValueForKey);
PrintAddress('COM_DefaultExtension', @CvarDef.COM_DefaultExtension);
PrintAddress('Spectator', CvarDef.Spectator);
PrintAddress('COM_ExplainDisconnection', @CvarDef.COM_ExplainDisconnection);
PrintAddress('CL_ExitGame', @CvarDef.CL_ExitGame);
PrintAddress('Host_Error', @CvarDef.Host_Error);
PrintAddress('Cmd_Source', CvarDef.Cmd_Source);
PrintAddress('GameUI007', CvarDef.GameUI007);
PrintAddress('StopHTTPDownload', @CvarDef.StopHTTPDownload);
PrintAddress('GameUI_StopProgressBar', @CvarDef.GameUI_StopProgressBar);
Print('', [PRINT_LINE_BREAK]);

PrintAddress('SVC_StuffText', @CvarDef.SVC_StuffText_Orig);
PrintAddress('SVC_SendCvarValue', @CvarDef.SVC_SendCvarValue_Orig);
PrintAddress('SVC_SendCvarValue2', @CvarDef.SVC_SendCvarValue2_Orig);
PrintAddress('SVC_MOTD', @CvarDef.SVC_MOTD_Orig);
Print('', [PRINT_LINE_BREAK]);

PrintAddress('CL_CheckCommandBounds', @CvarDef.CL_CheckCommandBounds);
PrintAddress('Cmd_ForwardToServer', @CvarDef.Cmd_ForwardToServer_Orig);
PrintAddress('IsValidFile_Orig', @CvarDef.IsValidFile_Orig);
PrintAddress('MOTDFile', CvarDef.MOTDFile);
PrintAddress('Cmd_MOTD_Write_Orig', @CvarDef.Cmd_MOTD_Write_Orig);
PrintAddress('CL_ParseServerInfo', @CvarDef.CL_ParseServerInfo);
PrintAddress('R_CheckVariables', @CvarDef.R_CheckVariables);
PrintAddress('Cmd_Argv_Patch_Gate', @CvarDef.Cmd_Argv_Patch_Gate);
PrintAddress('SteamIDPtr', CvarDef.SteamIDPtr);
PrintAddress('Sys_ResetKeyState', @CvarDef.Sys_ResetKeyState_Orig);
PrintAddress('Key_ClearStates', @CvarDef.Key_ClearStates);
PrintAddress('KeyBindings', CvarDef.KeyBindings);
PrintAddress('KeyShift', CvarDef.KeyShift);
PrintAddress('CL_ParseResourceList', @CvarDef.CL_ParseResourceList);
PrintAddress('CL_StartResourceDownloading', @CvarDef.CL_StartResourceDownloading);
PrintAddress('CL_ResourceBatchDownload', @CvarDef.CL_ResourceBatchDownload);
PrintAddress('CL_ResourceDownload_Orig', @CvarDef.CL_ResourceDownload_Orig);
PrintAddress('CL_ResourceDownload_Gate', @CvarDef.CL_ResourceDownload_Gate);

if ExtendedVoiceInterface then
 begin
  Print(#$A + 'Voice interface: ', [PRINT_LINE_BREAK]);
  VX_Debug;
 end;
end;

procedure Cmd_SetCvar; cdecl;
begin
if Engine.Cmd_Argc <= 2 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <name> <value>')
else
 Parser.ProcessCommand(Engine.Cmd_Argv(1), Engine.Cmd_Argv(2), HOST_CONSOLE);
end;

procedure Cmd_Special; cdecl;
begin
CBuf_AddText('_special'#$A);
if FastSpecialAlias then
 CBuf_Execute;
end;

procedure Debug2; cdecl;
var
 S: String;
begin
S := Engine.Cmd_Argv(1);
if S = '' then
 COM_ShowMessage(Madotsuki_WelcomeMsg)
else
 COM_ShowMessage(S);
end;

procedure Debug3; cdecl;
begin
with Engine do
 if Cmd_Argc < 5 then
  Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <message> <r> <g> <b>')
 else
  Print(Cmd_Argv(1), StrToIntDef(Cmd_Argv(2), High(Byte)), StrToIntDef(Cmd_Argv(3), High(Byte)), StrToIntDef(Cmd_Argv(4), High(Byte)));
end;

procedure ChangeSteamID; cdecl;
var
 Str: String;
 SteamID: LongWord;
begin
if Engine.Cmd_Argc < 2 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <steamid/"current"/"random">')
else
 begin
  Str := LowerCase(Engine.Cmd_Argv(1));
  if Str = 'current' then
   Print('SteamID = ', IntToStr(SteamIDPtr^))
  else
   if Str = 'random' then
    begin
     SteamIDPtr^ := Random(High(Cardinal));
     Print('SteamID changed to ', IntToStr(SteamIDPtr^), '.');
    end
   else
    begin
     if not TryStrToInt(Str, Longint(SteamID)) then
      Print('Invalid SteamID.')
     else
      begin
       SteamIDPtr^ := StrToIntDef(Str, SteamIDPtr^);
       Print('SteamID changed to ', IntToStr(SteamIDPtr^), '.');
      end;
    end;
 end;
end;

procedure PrintStatus(const Name: PChar; const Status: String; R: Byte = CMD_COLOR_R; G: Byte = CMD_COLOR_G; B: Byte = CMD_COLOR_B);
begin
Print('"', [PRINT_PREFIX]);
Print(Name, R, G, B, []);
Print('": ', Status, [PRINT_LINE_BREAK]);
end;

function CommandByName(const Name: String; const Error: Boolean = True): cmd_s;
begin
Result := Engine.GetCmdList;

while not (Result = nil) do
 if StrComp(Result.Name, Pointer(Name)) = 0 then
  Exit
 else
  Result := Result.Next;

Result := nil;
if Error then
 Common.Error('Couldn''t find "', Name, '" command pointer.');
end;

procedure CheckCallback(const Cmd: cmd_s; const UseClientBounds: Boolean = False; const CheckAlign: Boolean = True);
begin
if not UseClientBounds then
 if Bounds(@Cmd.Callback, HLBase, HLBase_End, CheckAlign) then
  Error('Couldn''t find "', Cmd.Name, '" command callback.')
 else
else
 if Bounds(@Cmd.Callback, CLBase, CLBase_End, CheckAlign) then
  Error('Couldn''t find "', Cmd.Name, '" command callback.');
end;

function ServerMsgByName(const Name: String): server_msg_s;
var
 I: LongWord;
begin
for I := 0 to SVCCount - 1 do
 if StrIComp(SVCBase[I].Name, Pointer(Name)) = 0 then
  begin
   Result := @SVCBase[I];
   Exit;
  end;
Result := nil;
end;

function HookServerMessage(const ServerMsg: server_msg_s; const Callback: TCallback): TCallback;
begin
if ServerMsg = nil then
 Error('HookServerMsg: Invalid message pointer.')
else
 if @Callback = nil then
  Error('HookServerMsg: Invalid callback.');

Result := @ServerMsg.Callback;
ServerMsg.Callback := @Callback;
end;

function HookServerMessage(const Index: Cardinal; const Callback: TCallback): TCallback;
begin
if Index > SVCCount then
 Error('HookServerMsg: Invalid message index.')
else
 if @Callback = nil then
  Error('HookServerMsg: Invalid callback.');

Result := @SVCBase[Index].Callback;
SVCBase[Index].Callback := @Callback;
end;

function HookServerMessage(const Name: String; const Callback: TCallback): TCallback;
var
 Addr: server_msg_s;
begin
if Name = '' then
 Error('HookServerMsg: Invalid message name.')
else
 if @Callback = nil then
  Error('HookServerMsg: Invalid callback.');

Addr := ServerMsgByName(Name);
if Addr = nil then
 Error('Couldn''t find "', Name, '" message pointer.');

Result := @Addr.Callback;
Addr.Callback := @Callback;
end;

function GetCallback(Index: LongWord): LongWord;
begin
if (SVCBase = nil) or (SVCBase_End = nil) then
 Error('Couldn''t find callback for message #', IntToStr(Index), ': message interface is not yet initialized.')
else
 if (Index > SVCCount - 1) or (@SVCBase[Index].Callback = nil) then
  Error('Couldn''t find callback for message #', IntToStr(Index), '.');
Result := Cardinal(@SVCBase[Index].Callback);
end;

procedure MSG_SaveReadCount;
begin
MSG_SavedReadCount := MSG_ReadCount^;
end;

procedure MSG_RestoreReadCount;
begin
MSG_ReadCount^ := MSG_SavedReadCount;
end;

function UserMsgByName(const Name: String): user_msg_s;
var
 L: Cardinal;
begin
if UserMsgBase = nil then
 begin
  Result := nil;
  Exit;
 end;

Result := UserMsgBase;
L := Length(Name);
while not (Result.Next = nil) do
 if StrLComp(@Result.Name, Pointer(Name), L) = 0 then
  Exit
 else
  Result := Result.Next;

Result := nil;
Error('Couldn''t find "', Name, '" message pointer.');
end;
 
function HookUserMessage(const Name: String; const Callback: TUserMsgHook): TUserMsgHook;
var
 Addr: user_msg_s;
begin
if @Callback = nil then
 Error('HookUserMsg: Invalid callback.');

Addr := UserMsgByName(Name);
if Addr = nil then
 Error('Couldn''t find "', Name, '" message pointer.');

Result := @Addr.Callback;
Addr.Callback := @Callback;
end;
 
function HookUserMessage(const UserMsg: user_msg_s; const Callback: TUserMsgHook): TUserMsgHook;
begin
if UserMsg = nil then
 Error('HookUserMsg: Invalid message pointer.')
else
 if @Callback = nil then
  Error('HookUserMsg: Invalid callback.');

Result := @UserMsg.Callback;
UserMsg.Callback := @Callback;
end;

function HookCommand(const Name: String; const Callback: TCallback): TCallback;
var
 Cmd: cmd_s;
begin
if Name = '' then
 Error('HookCommand: Invalid command name.')
else
 if @Callback = nil then
  Error('HookCommand: Invalid callback.');

Cmd := CommandByName(Name);
CheckCallback(Cmd);

Result := @Cmd.Callback;
Cmd.Callback := @Callback;
end;

function Expr_Process(const List: PExprArray; Count: LongWord; const Str: PChar; StrLength: LongWord; const StrLC: PChar = nil): Boolean;
begin // returns False if the file is invalid
case List[Count].ExprType of
 EXPR_STRCOMP:
  Result := StrLComp(PChar(Cardinal(Str) + Cardinal(List[Count].CmpOffset) - 1), @List[Count].Data, List[Count].CmpLength) <> 0;
 EXPR_STRICOMP:
  Result := StrLIComp(PChar(Cardinal(Str) + Cardinal(List[Count].CmpOffset) - 1), @List[Count].Data, List[Count].CmpLength) <> 0;
 EXPR_STRPOS:
  Result := StrPos(Str, @List[Count].Data) = nil;
 EXPR_STRIPOS:
  Result := StrPos(StrLC, @List[Count].Data) = nil;
 EXPR_STREQUAL:
  Result := StrComp(Str, PChar(@List[Count].Data)) <> 0;
 EXPR_STRIEQUAL:
  Result := StrComp(StrLC, PChar(@List[Count].Data)) <> 0;
 EXPR_EXIT:
  Result := List[Count].Data[1] = Chr($1);
 else
  Result := False;
end;
end;

{$IFNDEF ASM}
function GetModuleSize(Address: LongWord): LongWord;
begin
Result := PImageNtHeaders(Address + Cardinal(PImageDosHeader(Address)._lfanew)).OptionalHeader.SizeOfImage;
end;
{$ELSE}
function GetModuleSize(Address: LongWord): LongWord;
asm
 add eax, dword ptr [eax.TImageDosHeader._lfanew]
 mov eax, dword ptr [eax.TImageNtHeaders.OptionalHeader.SizeOfImage]
end;
{$ENDIF}

function GetCPUType: TCPUType;
asm
 pushfd
 pop ecx

 // 80386
 mov edx, ecx
 xor edx, 1 shl 18
 push edx
 popfd
 pushfd
 pop edx
 cmp edx, ecx
 je @80386

 // 80486
 mov edx, ecx
 xor edx, 1 shl 21
 push edx
 popfd
 pushfd
 pop edx
 cmp edx, ecx
 je @80486

 mov eax, CPU_DEFAULT // > 80486
 jmp @Return

@80386:
 mov eax, CPU_80386
 jmp @Return

@80486:
 mov eax, CPU_80486

@Return:
 push ecx
 popfd
end;

function Min(Value1, Value2: LongWord): LongWord;
asm
 cmp eax, edx
 jb @Return
 mov eax, edx

@Return:
end;

function Max(Value1, Value2: LongWord): LongWord;
asm
 cmp eax, edx
 jnb @Return
 mov eax, edx

@Return:
end;

function Initialized: Boolean;
var
 I: LongWord;
begin
for I := Cardinal(PClient) to Cardinal(PClient) + (SizeOf(ExportTable_t) - 9) do
 if I and 3 > 0 then
  Continue
 else
  if PCardinal(I)^ <= 1 then
   begin
    Result := False;
    Exit;
   end;
Result := True;
end;

procedure GetRendererInfo;
begin
HLBase := GetModuleHandle('hw.dll');
if HLBase = 0 then
 begin
  HLBase := GetModuleHandle('sw.dll');
  if HLBase = 0 then
   begin
    HLBase := GetModuleHandle(nil);
    if HLBase = 0 then
     Error('Invalid module handle.')
    else
     RendererType := RENDERER_UNDEFINED;
   end
  else
   RendererType := RENDERER_SOFTWARE;
 end
else
 RendererType := RENDERER_HARDWARE;

HLSize := GetModuleSize(HLBase);
if HLSize = 0 then
 begin
  Print('Failed to determine the renderer module size; using pre-defined constants.');
  case RendererType of
   RENDERER_HARDWARE: HLSize := $122A000;
   RENDERER_UNDEFINED: HLSize := $2116000;     
   RENDERER_SOFTWARE: HLSize := $B53000;
   else Error('Invalid renderer type.');
  end;
 end;

HLBase_End := HLBase + HLSize - 1;
Protocol := DEFAULT_PROTOCOL + Byte(RendererType <> RENDERER_UNDEFINED);
end;

procedure GetClientInfo;
begin
CLBase := GetModuleHandle('client.dll');
if CLBase = 0 then
 begin
  CLBase := HLBase;
  CLSize := HLSize;
 end
else
 begin
  CLSize := GetModuleSize(CLBase);
  if CLSize = 0 then
   begin
    Print('Failed to determine the client module size; using pre-defined constant.');
    CLSize := $159000;
   end;
 end;
CLBase_End := CLBase + CLSize - 1;
end;

function CRC32_ProcessBuffer(Sequence: LongWord; const Buffer: Pointer; Size: LongWord): LongWord;
asm
 test edx, edx
 je @Return
 test ecx, ecx
 je @Return

 push ebx
 push edi
 mov ebx, 0 // alignment
 mov edi, offset @CRCTable

@Loop:
 mov bl, al
 shr eax, 8
 xor bl, byte ptr [edx]
 xor eax, dword ptr [edi + ebx * type LongWord]
 inc edx
 dec ecx
 jne @Loop

 pop edi
 pop ebx
 ret

@Return:
 xor eax, eax
 ret

@CRCTable:
 dd $000000000, $077073096, $0EE0E612C, $0990951BA
 dd $0076DC419, $0706AF48F, $0E963A535, $09E6495A3
 dd $00EDB8832, $079DCB8A4, $0E0D5E91E, $097D2D988
 dd $009B64C2B, $07EB17CBD, $0E7B82D07, $090BF1D91
 dd $01DB71064, $06AB020F2, $0F3B97148, $084BE41DE
 dd $01ADAD47D, $06DDDE4EB, $0F4D4B551, $083D385C7
 dd $0136C9856, $0646BA8C0, $0FD62F97A, $08A65C9EC
 dd $014015C4F, $063066CD9, $0FA0F3D63, $08D080DF5
 dd $03B6E20C8, $04C69105E, $0D56041E4, $0A2677172
 dd $03C03E4D1, $04B04D447, $0D20D85FD, $0A50AB56B
 dd $035B5A8FA, $042B2986C, $0DBBBC9D6, $0ACBCF940
 dd $032D86CE3, $045DF5C75, $0DCD60DCF, $0ABD13D59
 dd $026D930AC, $051DE003A, $0C8D75180, $0BFD06116
 dd $021B4F4B5, $056B3C423, $0CFBA9599, $0B8BDA50F
 dd $02802B89E, $05F058808, $0C60CD9B2, $0B10BE924
 dd $02F6F7C87, $058684C11, $0C1611DAB, $0B6662D3D
 dd $076DC4190, $001DB7106, $098D220BC, $0EFD5102A
 dd $071B18589, $006B6B51F, $09FBFE4A5, $0E8B8D433
 dd $07807C9A2, $00F00F934, $09609A88E, $0E10E9818
 dd $07F6A0DBB, $0086D3D2D, $091646C97, $0E6635C01
 dd $06B6B51F4, $01C6C6162, $0856530D8, $0F262004E
 dd $06C0695ED, $01B01A57B, $08208F4C1, $0F50FC457
 dd $065B0D9C6, $012B7E950, $08BBEB8EA, $0FCB9887C
 dd $062DD1DDF, $015DA2D49, $08CD37CF3, $0FBD44C65
 dd $04DB26158, $03AB551CE, $0A3BC0074, $0D4BB30E2
 dd $04ADFA541, $03DD895D7, $0A4D1C46D, $0D3D6F4FB
 dd $04369E96A, $0346ED9FC, $0AD678846, $0DA60B8D0
 dd $044042D73, $033031DE5, $0AA0A4C5F, $0DD0D7CC9
 dd $05005713C, $0270241AA, $0BE0B1010, $0C90C2086
 dd $05768B525, $0206F85B3, $0B966D409, $0CE61E49F
 dd $05EDEF90E, $029D9C998, $0B0D09822, $0C7D7A8B4
 dd $059B33D17, $02EB40D81, $0B7BD5C3B, $0C0BA6CAD
 dd $0EDB88320, $09ABFB3B6, $003B6E20C, $074B1D29A
 dd $0EAD54739, $09DD277AF, $004DB2615, $073DC1683
 dd $0E3630B12, $094643B84, $00D6D6A3E, $07A6A5AA8
 dd $0E40ECF0B, $09309FF9D, $00A00AE27, $07D079EB1
 dd $0F00F9344, $08708A3D2, $01E01F268, $06906C2FE
 dd $0F762575D, $0806567CB, $0196C3671, $06E6B06E7
 dd $0FED41B76, $089D32BE0, $010DA7A5A, $067DD4ACC
 dd $0F9B9DF6F, $08EBEEFF9, $017B7BE43, $060B08ED5
 dd $0D6D6A3E8, $0A1D1937E, $038D8C2C4, $04FDFF252
 dd $0D1BB67F1, $0A6BC5767, $03FB506DD, $048B2364B
 dd $0D80D2BDA, $0AF0A1B4C, $036034AF6, $041047A60
 dd $0DF60EFC3, $0A867DF55, $0316E8EEF, $04669BE79
 dd $0CB61B38C, $0BC66831A, $0256FD2A0, $05268E236
 dd $0CC0C7795, $0BB0B4703, $0220216B9, $05505262F
 dd $0C5BA3BBE, $0B2BD0B28, $02BB45A92, $05CB36A04
 dd $0C2D7FFA7, $0B5D0CF31, $02CD99E8B, $05BDEAE1D
 dd $09B64C2B0, $0EC63F226, $0756AA39C, $0026D930A
 dd $09C0906A9, $0EB0E363F, $072076785, $005005713
 dd $095BF4A82, $0E2B87A14, $07BB12BAE, $00CB61B38
 dd $092D28E9B, $0E5D5BE0D, $07CDCEFB7, $00BDBDF21
 dd $086D3D2D4, $0F1D4E242, $068DDB3F8, $01FDA836E
 dd $081BE16CD, $0F6B9265B, $06FB077E1, $018B74777
 dd $088085AE6, $0FF0F6A70, $066063BCA, $011010B5C
 dd $08F659EFF, $0F862AE69, $0616BFFD3, $0166CCF45
 dd $0A00AE278, $0D70DD2EE, $04E048354, $03903B3C2
 dd $0A7672661, $0D06016F7, $04969474D, $03E6E77DB
 dd $0AED16A4A, $0D9D65ADC, $040DF0B66, $037D83BF0
 dd $0A9BCAE53, $0DEBB9EC5, $047B2CF7F, $030B5FFE9
 dd $0BDBDF21C, $0CABAC28A, $053B39330, $024B4A3A6
 dd $0BAD03605, $0CDD70693, $054DE5729, $023D967BF
 dd $0B3667A2E, $0C4614AB8, $05D681B02, $02A6F2B94
 dd $0B40BBE37, $0C30C8EA1, $05A05DF1B, $02D02EF8D
 dd $074726F50, $0736E6F69, $0706F4320, $067697279
 dd $028207468, $031202963, $020393939, $048207962
 dd $06E656761, $064655220, $06E616D64, $06FBBA36E
end;

function CRC32_ProcessString(const Str: String): LongWord;
asm
 mov edx, eax
 call System.@LStrLen
 mov ecx, eax
 xor eax, eax
 call CRC32_ProcessBuffer
end;

procedure COM_FixSlashes(var Str: String);
var
 I: LongWord;
begin
for I := 1 to Length(Str) do
 if Str[I] = '/' then
  Str[I] := '\';
end;

procedure COM_FixSlashes2(var Str: String);
var
 I: LongWord;
begin
for I := 1 to Length(Str) do
 if Str[I] = '\' then
  Str[I] := '/';
end;

function COM_GetFileList(const BaseDir: String; const RecursiveCall: Boolean = False): String;
var
 Str: String;
 I: LongWord;
 SearchRec: TSearchRec;
begin
Result := '';
Str := BaseDir;
COM_FixSlashes(Str);
if Str[Length(Str)] <> '\' then
 Str := Str + '\';

I := FindFirst(Str + '*.*', faAnyFile, SearchRec);
while not Boolean(I) do
 begin
  if (SearchRec.Attr and faDirectory) = faDirectory then
   Result := Result + '> ' + SearchRec.Name + #$A + COM_GetFileList(BaseDir, True)
  else
   if SearchRec.Name[1] <> '.' then
    Result := Result + SearchRec.Name + #$A;
  I := FindNext(SearchRec);
 end;
FindClose(SearchRec);
end;

procedure COM_DefaultExtension(var Str: String; const Extension: String; DefaultLength: LongWord = 0);
var
 I: LongWord;
begin
if (Str = '') or (Extension = '') then
 Exit;
if DefaultLength = 0 then
 begin
  DefaultLength := Length(Str);
  if DefaultLength = 0 then
   Exit;
 end;
for I := DefaultLength downto 1 do
 if (Str[I] = '\') or (Str[I] = '/') or (Str[I] = ':') then
  begin
   Str := Str + '.' + Extension;
   Exit;
  end
 else
  if Str[I] = '.' then
   Exit;
Str := Str + '.' + Extension;
end;

procedure COM_StripTrailingSlash(var Str: String; const TrimRight: Boolean = False);
var
 L: LongWord;
begin
if TrimRight then
 Str := SysUtils.TrimRight(Str);

L := Length(Str);
if (L > 0) and (Str[L] in ['\', '/']) then
 SetLength(Str, L - 1);
end;

function COM_HasExtension(const Str: String): Boolean;
var
 I, L: LongWord;
begin
L := Length(Str);
if (L > 0) and (Str[L] <> '.') then
 for I := L - 1 downto 2 do
  case Str[I] of
   '.':
    begin
     Result := True;
     Exit;
    end;
   '\', '/', ':':
    begin
     Result := False;
     Exit;
    end;
   else Continue;
  end;
Result := False;
end;

procedure COM_StripExtension(var Str: String);
var
 I: LongWord;
begin
for I := Length(Str) downto 1 do
 case Str[I] of
  '.':
   begin
    SetLength(Str, I - 1);
    Exit;
   end;
  '\', '/', ':': Exit;
 end;
end;

procedure COM_IncludeStr(SubStr: Char; var Dest: String);
var
 L: LongWord;
begin
L := Length(Dest);
if L = 0 then
 Exit
else
 if Dest[L] <> SubStr then
  Dest := Dest + SubStr;
end;

procedure COM_ExcludeStr(SubStr: Char; var Dest: String);
var
 L: LongWord;
begin
L := Length(Dest);
if L = 0 then
 Exit
else
 if Dest[L] = SubStr then
  Delete(Dest, L, 1);
end;

procedure TrimRight(var Str: String);
var
 I: LongWord;
begin
for I := Length(Str) downto 1 do
 if Str[I] <> ' ' then
  begin
   SetLength(Str, I);
   Exit;
  end;
end;

function COM_IntToHex(Value: LongWord): String;
begin
Result := '$' + SysUtils.IntToHex(Value, 0);
end;

function COM_IntToHex(const Value: Pointer): String;
begin
Result := '$' + SysUtils.IntToHex(Cardinal(Value), 0);
end;

procedure AddToLinkedList(var Base: Pointer; const Item: Pointer; const Offset: LongWord = 0);
begin
PPointer(Cardinal(Item) + Offset)^ := Base;
Base := Item;
end;

procedure Delay(MSec: LongWord);
var
 Handle: THandle;
begin
Handle := CreateEvent(nil, True, False, nil);
WaitForSingleObject(Handle, MSec);
CloseHandle(Handle);
end;

procedure Alert(const Msg: String);
begin
MessageBox(0, PChar(Msg), 'Alert', MB_OK or MB_ICONWARNING or MB_SYSTEMMODAL);
end;

procedure Alert(const Addr: Pointer);
begin
MessageBox(0, PChar(COM_IntToHex(Addr)), 'Alert', MB_OK or MB_ICONWARNING or MB_SYSTEMMODAL);
end;

procedure Error(const Msg: String);
begin
MessageBox(0, PChar(Msg), PChar(Name + ': Error'), MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
Halt;
end;

procedure Error(const Str1, Str2: String);
begin
Error(Str1 + Str2);
end;

procedure Error(const Str1, Str2, Str3: String);
begin
Error(Str1 + Str2 + Str3);
end;

procedure Error(const Str1, Str2, Str3, Str4: String);
begin
Error(Str1 + Str2 + Str3 + Str4);
end;

procedure Error(const Str1, Str2, Str3, Str4, Str5: String);
begin
Error(Str1 + Str2 + Str3 + Str4 + Str5);
end;

function Address(Ptr: LongWord): String;
begin
Result := IntToHex(Ptr, 8);
end;

function Address(const Ptr: Pointer): String;
begin
Result := IntToHex(Cardinal(Ptr), 8);
end;

function Address(const Name: String; Ptr: LongWord): String;
begin
Result := Name + ': ' + IntToHex(Ptr, 8);
end;

function Address(const Name: String; const Ptr: Pointer): String;
begin
Result := Name + ': ' + IntToHex(Cardinal(Ptr), 8);
end;

procedure PrintAddress(const Name: String; const Ptr: Pointer);
begin
Print(Name, ': $', IntToHex(Cardinal(Ptr), 8), [PRINT_LINE_BREAK]);
end;

procedure PrintVariable(const Name: String; Value: Boolean);
begin
Print(Name, ' = ', BoolToStr(Value, True), [PRINT_LINE_BREAK]);
end;

procedure PrintVariable(const Name: String; Value: Longint);
begin
Print(Name, ' = ', IntToStr(Value), [PRINT_LINE_BREAK]);
end;

procedure PrintVariable(const Name: String; Value: Single);
begin
Print(Name, ' = ', FloatToStr(Value), [PRINT_LINE_BREAK]);
end;

procedure PrintVariable(const Name, Value: String);
begin
Print(Name, ' = ', Value, [PRINT_LINE_BREAK]);
end;

procedure COM_Munge(const Data: Pointer; Size, Sequence: LongWord); cdecl;
asm
 db $5D
 dd $8B08EC83, $53102444, $DB33FC24, $03E28399, $F8C1C203, $89C08502
 dd $7E082444, $24448B74, $6C8B5518, $F7561424, $448957D0, $04EB1024
 dd $1024448B, $50004533, $9090C80F, $24448990, $8DFB8B24, $83242444
 dd $C93304C4, $748DF82B, $C18A200C, $148DE0D2, $0FE28337
 dw $928A
 dd offset EncodeTable
 dd $068AD00A, $CA80D10A, $41C232A5, $8804F983, $8BD97C06, $8B202444
 dd $33242474, $458943C6, $24448B00, $04C58314, $A27CD83B, $5B5D5E5F
 dd $C308C483
end;

procedure COM_UnMunge(const Data: Pointer; Size, Sequence: LongWord); cdecl;
asm
 db $5D
 dd $24448B51, $FC24550C, $8399ED33, $C20303E2, $8502F8C1, $244489C0
 dd $53697E04, $10245C8B, $038B5756, $20244C8B, $FD8BC133, $1C24548D
 dd $4489C933, $FA2B1C24, $1C0C748D, $E2D2D18A, $8337048D, $808A0FE0
 dd offset EncodeTable
 dd $168AC20A, $A50CC10A, $8341D032, $168804F9, $4C8BDA7C, $0F511C24
 dd $90C18BC9, $2424548B, $F704C483, $45C233D2, $448B0389, $C3831024
 dd $7CE83B04, $5B5E5FA1
 dw $595D
 db $C3
end;

function CheckRelativePath(const Str: PChar): Boolean;
begin
Result := (StrPos(Str, '..') <> nil) or (StrPos(Str, ':') <> nil);
end;

procedure COM_FillChar(const Dest: Pointer; Size: LongWord; Value: Byte);
asm
 cmp edx, 32
 mov ch, cl
 jl @Small
 mov [eax], cx
 mov [eax+2], cx
 mov [eax+4], cx
 mov [eax+6], cx
 sub edx, 16
 fld qword ptr [eax]
 fst qword ptr [eax+edx]
 fst qword ptr [eax+edx+8]
 mov ecx, eax
 and ecx, 7
 sub ecx, 8
 sub eax, ecx
 add edx, ecx
 add eax, edx
 neg edx
@Loop:
 fst qword ptr [eax+edx]
 fst qword ptr [eax+edx+8]
 add edx, 16
 jl @Loop
 ffree st(0)
 ret
 nop
 nop
 nop
@Small:
 test edx, edx
 jle @Done
 mov [eax+edx-1], cl
 and edx, -2
 neg edx
 lea edx, [@SmallFill + 60 + edx * 2]
 jmp edx
 nop
 nop
@SmallFill:
 mov [eax+28], cx
 mov [eax+26], cx
 mov [eax+24], cx
 mov [eax+22], cx
 mov [eax+20], cx
 mov [eax+18], cx
 mov [eax+16], cx
 mov [eax+14], cx
 mov [eax+12], cx
 mov [eax+10], cx
 mov [eax+8], cx
 mov [eax+6], cx
 mov [eax+4], cx
 mov [eax+2], cx
 mov [eax], cx
 ret
@Done:
end;

procedure StringReplace(var Str: String; OldChar, NewChar: Char);
var
 I: LongWord;
begin
for I := 1 to Length(Str) do
 if Str[I] = OldChar then
  Str[I] := NewChar;
end;

function StrComp(const Str1, Str2: PChar): Longint;
asm
 sub eax, edx
 je @Exit

@Loop:
 movzx ecx, [eax+edx]
 cmp cl, [edx]
 jne @SetResult
 inc edx
 test cl, cl
 jnz @Loop
 xor eax, eax
 ret

@SetResult:
 sbb eax, eax
 or al, 1

@Exit:
end;

function StrIComp(const Str1, Str2: PChar): Longint;
asm
 push ebx
 sub eax, edx
 mov ecx, eax

@Check:
 test eax, eax
 je @Exit

@Loop:
 movzx eax, [ecx+edx]
 movzx ebx, [edx]
 inc edx
 cmp eax, ebx
 je @Check
 add eax, $9f
 add ebx, $9f
 cmp al, $1a
 jnb @1
 sub eax, $20

@1:
 cmp bl, $1a
 jnb @2
 sub ebx, $20

@2:
 sub eax, ebx
 je @Loop
 
@Exit:
 pop ebx
end;

function StrLComp(const Str1, Str2: PChar; MaxLen: LongWord): Longint;
asm
 push ebx
 sub eax, edx
 je @Exit
 add ecx, edx

@Loop:
 cmp ecx, edx
 je @Zero
 movzx ebx, [eax+edx]
 cmp bl, [edx]
 jne @SetResult
 inc edx
 test bl, bl
 jne @Loop

@Zero:
 xor eax, eax
 pop ebx
 ret

@SetResult:
 sbb eax, eax
 or al, 1
 
@Exit:
 pop ebx
end;

function StrLIComp(const Str1, Str2: PChar; MaxLen: LongWord): Longint;
asm
 push ebx
 sub eax, edx
 je @Exit
 add ecx, edx

@Loop:
 cmp ecx, edx
 je @Zero
 movzx ebx, [eax+edx]
 cmp bl, [edx]
 je @Same
 add bl, $9f
 cmp bl, $1a
 jnb @1
 sub bl, $20

@1:
 sub bl, $9f 
 mov bh, [edx]
 add bh, $9f 
 cmp bh, $1a
 jnb @2
 sub bh, $20

@2:
 sub bh, $9f
 cmp bl, bh
 jne @SetResult

@Same:
 add edx, 1 
 test bl, bl
 jne @Loop

@Zero:
 xor eax, eax
 pop ebx
 ret

@SetResult:
 sbb eax, eax
 or al, 1

@Exit:
 pop ebx
end;

function StrLen(const Str: PChar): LongWord;
asm
 cmp byte ptr [eax], 0
 je @0
 cmp byte ptr [eax+1], 0
 je @1
 cmp byte ptr [eax+2], 0
 je @2
 cmp byte ptr [eax+3], 0
 je @3
 push eax
 and eax, -4

@Loop:
 add eax, 4
 mov edx, [eax]
 lea ecx, [edx-$01010101]
 not edx
 and edx, ecx
 and edx, $80808080
 je @Loop

@SetResult:
 pop ecx
 bsf edx, edx
 shr edx, 3
 add eax, edx
 sub eax, ecx
 ret

@0:
 xor eax, eax
 ret

@1:
 mov eax, 1
 ret

@2:
 mov eax, 2
 ret

@3:
 mov eax, 3
end;

procedure PrintInfo;
begin
Print('-- ' + Name + ' by ratwayer / [2010] KOHTEP' + #$A +
      '-- http://madotsuki.ru | ratwayer@madotsuki.ru', 80, 255, 50, [PRINT_LINE_BREAK]);
end;

procedure PrintSearchError(const S: PChar);
begin
Error('Couldn''t find ', S, ' pointer.');
end;

procedure COM_ShowMessage(const Str: String);
begin
COM_ExplainDisconnection(0, Pointer(Str));
GameUI_StopProgressBar;
end;

procedure COM_ShowConsole;
asm
 mov ecx, dword ptr [GameConsole003]
 mov eax, dword ptr [ecx]
 call dword ptr [eax].VGameConsole003.IsConsoleVisible
 test al, al
 jne @Return

 push offset [@Command]
 call dword ptr [Engine].cl_enginefuncs_t.ClientCmd
 add esp, 4
 ret

@Command:
 db 'toggleconsole', $0

@Return:
end;

procedure SaveClassPointer;
asm
 push ecx
end;

procedure RestoreClassPointer;
asm
 pop ecx
end;

end.
