unit MemSearch;

{$I CSXGuard.inc}

interface

function Absolute(const BaseAddr, RelativeAddr: LongWord): LongWord; overload;
function Absolute(const BaseAddr, RelativeAddr: Pointer): LongWord; overload;
function Absolute(const Addr: LongWord): LongWord; overload;
function Absolute(const Addr: Pointer): LongWord; overload;
function Relative(const Addr, NewFunc: LongWord): LongWord; overload;
function Relative(const Addr, NewFunc: Pointer): LongWord; overload;

function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean; overload;
function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean; overload;

function CompareMemory(Address, Pattern, Size: LongWord): Boolean; overload;
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean; overload;

procedure ReplaceMemory(Address, Pattern, Size: LongWord); overload;
procedure ReplaceMemory(const Address, Pattern: Pointer; Size: LongWord); overload;

function FindPattern(StartAddr, EndAddr: LongWord; const Pattern: Pointer; PatternSize: LongWord; const Offset: Longint): Pointer; overload;
function FindPattern(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; const Offset: Longint): Pointer; overload;

function CheckByte(Address: LongWord; Value: Byte; const Offset: Longint = 0): Boolean; overload;
function CheckByte(const Address: Pointer; Value: Byte; const Offset: Longint = 0): Boolean; overload;
function CheckWord(Address: LongWord; Value: Word; const Offset: Longint = 0): Boolean; overload;
function CheckWord(const Address: Pointer; Value: Word; const Offset: Longint = 0): Boolean; overload;
function CheckLongWord(Address, Value: LongWord; const Offset: Longint = 0): Boolean; overload;
function CheckLongWord(const Address: Pointer; Value: LongWord; const Offset: Longint = 0): Boolean; overload;

function FindEngineAndClient: Boolean;
procedure FindStudio;

procedure Find_Cmd_TokenizeString;
procedure Find_Cmd_Args;
procedure Find_Sys_Error;
procedure Find_SVCBase;
procedure Find_MSGInterface;
procedure Find_COM_Parse;
procedure Find_COM_Token;
procedure Find_CBuf_AddText;
procedure Find_CBuf_Execute;
procedure Find_IsValidCmd;
procedure Find_CommandBounds;
procedure Find_Cmd_ExecuteString;
procedure Find_CState;
function Find_IsValidFile: Boolean;
procedure Find_GameConsole003;
procedure Find_CVar_Command;
procedure Find_SetValueForKey;
procedure Find_R_CheckVariables;
procedure Find_LastArgString;
function Find_SteamIDPtr: Boolean;
procedure Find_COM_DefaultExtension;
procedure Find_Sys_ResetKeyState;
procedure Find_Key_ClearStates;
procedure Find_KeyBindings;
procedure Find_KeyShift;
procedure Find_Spectator;
procedure Find_GameInfo;
procedure Find_COM_ExplainDisconnection;
procedure Find_CL_ExitGame;
procedure Find_CL_ParseResourceList;
procedure Find_CL_StartResourceDownloading;
procedure Find_CL_ResourceBatchDownload;
procedure Find_CL_ResourceDownload;
procedure Find_Host_Error;
procedure Find_Cmd_Source;
procedure Find_StopHTTPDownload;
procedure Find_GameUI_StopProgressBar;

procedure Patch_CL_ConnectionlessPacket;
procedure Patch_Host_FilterTime;
procedure Patch_Host_FilterTime_SW;
procedure Patch_Cmd_Alias;
procedure Patch_Cmd_ForwardToServer;
procedure Patch_CL_Move;
procedure Patch_CVar_Command;
procedure Patch_SetValueForKey;
procedure Patch_R_CheckVariables;
procedure Patch_Cmd_StartMovie;
procedure Patch_CL_CheckCommandBounds;
procedure Patch_Sys_ResetKeyState;
procedure Patch_IsValidFile;

const
 EngineString: String = 'ScreenShake';
 StudioString: String = 'Couldn''t get client .dll studio model rendering interface.  Version mismatch?';

 Pattern_Engine_WriteOffset = 9;
 Pattern_Studio_WriteOffset = 3;

 Pattern_Engine: array[1..14] of Byte =
                    ($83, $C4, $04,
                     $68, $FF, $FF, $FF, $FF,
                     $68, $00, $00, $00, $00,
                     $E8);

 Pattern_Studio: array[1..15] of Byte =
                    ($75, $12,
                     $68, $00, $00, $00, $00,
                     $E8, $FF, $FF, $FF, $FF,
                     $83, $C4, $04);

 Pattern_CommandBounds: array[1..28] of Byte =
                    ($51,
                     $D9, $05, $FF, $FF, $FF, $FF,
                     $D8, $1D, $FF, $FF, $FF, $FF,
                     $53,
                     $56,
                     $57,
                     $BF, $32, $00, $00, $00,
                     $BB, $64, $00, $00, $00,
                     $DF, $E0);

 Pattern_Host_FilterTime: array[1..43] of Byte =
                    ($C7, $44, $24, $04, $00, $00, $E0, $3F,
                     $EB, $08,
                     $D9, $44, $24, $00,
                     $DD, $5C, $24, $00,
                     $DD, $44, $24, $00,
                     $D9, $5C, $24, $00,
                     $D9, $05, $FF, $FF, $FF, $FF,
                     $D8, $1D, $FF, $FF, $FF, $FF,
                     $DF, $E0,
                     $F6, $C4, $FF);

 Pattern_Host_FilterTime_SW: array[1..38] of Byte =
                    ($C7, $45, $FC, $00, $00, $E0, $3F,
                     $EB, $06,
                     $D9, $45, $08,
                     $DD, $5D, $F8,
                     $DD, $45, $F8,
                     $D9, $5D, $08,
                     $D9, $05, $FF, $FF, $FF, $FF,
                     $D8, $1D, $FF, $FF, $FF, $FF,
                     $DF, $E0,
                     $F6, $C4, $FF);

 Pattern_Host_FilterTime_3: array[1..39] of Byte =
                    ($DD, $05, $FF, $FF, $FF, $FF,
                     $DC, $1D, $FF, $FF, $FF, $FF,
                     $DF, $E0,
                     $F6, $C4, $FF,
                     $FF, $14,
                     $C7, $05, $FF, $FF, $FF, $FF, $FC, $A9, $F1, $D2,
                     $C7, $05, $FF, $FF, $FF, $FF, $4D, $62, $50, $3F);

 Pattern_Cmd_ForwardToServer: array[1..15] of Byte =
                    ($83, $F8, $05,
                     $74, $FF,
                     $83, $F8, $03,
                     $74, $FF,
                     $83, $F8, $04,
                     $75, $FF);

 Pattern_CL_Move: array[1..33] of Byte =
                    ($EB, $10,
                     $8B, $44, $24, $2C,
                     $8B, $4C, $24, $30,
                     $89, $44, $24, $24,
                     $89, $4C, $24, $28,
                     $DD, $44, $24, $24,
                     $E8, $FF, $FF, $FF, $FF,
                     $B9, $0D, $00, $00, $00,
                     $BF);

 Pattern_CL_Move_SW: array[1..28] of Byte =
                    ($EB, $0C,
                     $8B, $45, $D8,
                     $8B, $4D, $DC,
                     $89, $45, $E4,
                     $89, $4D, $E8,
                     $DD, $45, $E4,
                     $E8, $FF, $FF, $FF, $FF,
                     $B9, $0D, $00, $00, $00,
                     $BF);

 Pattern_R_CheckVariables: array[1..51] of Byte =
                    ($83, $EC, $18,
                     $83, $F8, $01,
                     $0F, $FF, $FF, $FF, $FF, $FF,
                     $D9, $05, $FF, $FF, $FF, $FF,
                     $D8, $1D, $FF, $FF, $FF, $FF,
                     $DF, $E0,
                     $F6, $C4, $44,
                     $7B, $12,
                     $68, $FF, $FF, $FF, $FF,
                     $68, $FF, $FF, $FF, $FF,
                     $E8, $FF, $FF, $FF, $FF,
                     $83, $C4, $08,
                     $D9, $05);

 Pattern_R_CheckVariables_SW: array[1..57] of Byte =
                    ($55,
                     $8B, $EC,
                     $83, $EC, $34,
                     $A1, $FF, $FF, $FF, $FF,
                     $56,
                     $57,
                     $BF, $01, $00, $00, $00,
                     $3B, $C7,
                     $0F, $8E, $FF, $FF, $FF, $FF,
                     $81, $3D, $FF, $FF, $FF, $FF, $00, $00, $80, $BF,
                     $74, $12,
                     $68, $FF, $FF, $FF, $FF,
                     $68, $FF, $FF, $FF, $FF,
                     $E8, $FF, $FF, $FF, $FF,
                     $83, $C4, $08,
                     $D9);

 Pattern_SteamIDPtr: array[1..33] of Byte =
                    ($68, $FF, $FF, $FF, $FF,
                     $8D, $4C, $24, $0C,
	                   $E8, $FF, $FF, $FF, $FF,
	                   $8D, $5C, $24, $04,
                   	 $E8, $FF, $FF, $FF, $FF,
                     $83, $7C, $24, $1C, $10,
                     $A3, $FF, $FF, $FF, $FF);

 Pattern_Sys_ResetKeyState: array[1..24] of Byte =
                    ($56,
                     $33, $F6,
                     $6A, $00,
                     $56,
                     $E8, $FF, $FF, $FF, $FF,
                     $83, $C4, $08,
                     $46,
                     $81, $FE, $00, $01, $00, $00,
                     $7C, $EC,
                     $E8);       

 Pattern_RedirectPacket: array[1..16] of Byte =
                    ($68, $FF, $FF, $FF, $FF,
                     $E8, $FF, $FF, $FF, $FF,
                     $83, $C4, $1C,
                     $5F,
                     $FF,
                     $FF);

 Pattern_CL_SendConnectPacket: array[1..38] of Byte =
                    ($89, $15, $FF, $FF, $FF, $FF,
                     $8B, $15, $FF, $FF, $FF, $FF,
                     $8D, $8C, $24, $FF, $FF, $FF, $FF,
                     $68, $FF, $FF, $FF, $FF,
                     $51,
                     $52,
                     $6A, $FF,
                     $68, $FF, $00, $00, $00,
                     $68, $FF, $00, $00, $00);

 Pattern_GameUI_StopProgressBar: array[1..36] of Byte =
                    ($A1, $00, $00, $00, $00,
                     $8B, $0D, $FF, $FF, $FF, $FF,
                     $83, $F8, $05,
                     $74, $21,
                     $85, $C9,
                     $74, $26,
                     $A1, $FF, $FF, $FF, $FF,
                     $85, $C0,
                     $74, $0D,
                     $8B, $10,
                     $8B, $C8,
                     $FF, $52, $18);

implementation

uses HLSDK, CvarDef, Windows, MsgAPI, CMDBlock, Detours, Extended, ResBlock, SysUtils, Common;

{$IFNDEF ASM}
function Absolute(const BaseAddr, RelativeAddr: LongWord): LongWord;
begin
Result := RelativeAddr + BaseAddr + 4;
end;

function Absolute(const BaseAddr, RelativeAddr: Pointer): LongWord;
begin
Result := Cardinal(RelativeAddr) + Cardinal(BaseAddr) + 4;
end;

function Absolute(const Addr: LongWord): LongWord;
begin
Result := Addr + PCardinal(Addr)^ + 4;
end;

function Absolute(const Addr: Pointer): LongWord;
begin
Result := Cardinal(Addr) + PCardinal(Addr)^ + 4;
end;

function Relative(const Addr, NewFunc: LongWord): LongWord;
begin
Result := NewFunc - Addr - 5;
end;

function Relative(const Addr, NewFunc: Pointer): LongWord;
begin
Result := Cardinal(NewFunc) - Cardinal(Addr) - 5;
end;
{$ELSE}
function Absolute(const BaseAddr, RelativeAddr: LongWord): LongWord;
asm
 lea eax, dword ptr [eax + edx + 4]
end;

function Absolute(const BaseAddr, RelativeAddr: Pointer): LongWord;
asm
 lea eax, dword ptr [eax + edx + 4]
end;

function Absolute(const Addr: LongWord): LongWord;
asm
 add eax, [eax]
 add eax, 4
end;

function Absolute(const Addr: Pointer): LongWord;
asm
 add eax, [eax]
 add eax, 4
end;

function Relative(const Addr, NewFunc: LongWord): LongWord;
asm
 sub edx, eax
 sub edx, 5
 mov eax, edx
end;

function Relative(const Addr, NewFunc: Pointer): LongWord;
asm
 sub edx, eax
 sub edx, 5
 mov eax, edx
end;
{$ENDIF}

{$IFNDEF ASM}
function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
begin
Result := (Address < LowBound) or (Address > HighBound) or (Align and (Address and $F > 0));
end;

function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
begin
Result := (Cardinal(Address) < LowBound) or (Cardinal(Address) > HighBound) or (Align and (Cardinal(Address) and $F > 0));
end;
{$ELSE}
function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
asm
 cmp eax, edx
 jl @Return
 cmp eax, ecx
 jg @Return
 cmp byte ptr [Align], 0
 je @InBounds
 and eax, $F
 jg @Return

@InBounds:
 xor eax, eax
 jmp @StackFrame

@Return:
 mov eax, 1

@StackFrame:
end;

function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
asm
 cmp eax, edx
 jl @Return
 cmp eax, ecx
 jg @Return
 cmp byte ptr [Align], 0
 je @InBounds
 and eax, $F
 jg @Return

@InBounds:
 xor eax, eax
 jmp @StackFrame

@Return:
 mov eax, 1

@StackFrame:
end;
{$ENDIF}

{$IFNDEF ASM}
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean;
var
 I: LongWord;
 B: Byte;
begin
if (Address = nil) or (Pattern = nil) or (Size = 0) then
 Result := False
else
 begin
  for I := 0 to Size - 1 do
   begin
    B := PByte(Cardinal(Pattern) + I)^;
    if (PByte(Cardinal(Address) + I)^ <> B) and (B <> $FF) then
     begin
      Result := False;
      Exit;
     end;
   end;
  Result := True;
 end;
end;
{$ELSE}
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean;
asm
 test eax, eax
 je @NotEqual
 test edx, edx
 je @NotEqual
 test ecx, ecx
 je @NotEqual

 push ebx

@Loop:
 mov bl, byte ptr [edx]
 cmp bl, byte ptr [eax]
 je @PostLoop
 sub bl, $FF
 je @PostLoop

 xor eax, eax
 pop ebx
 ret

@PostLoop:
 inc eax
 inc edx
 dec ecx
 jne @Loop

 mov eax, 1
 pop ebx
 ret

@NotEqual:
 xor eax, eax
end;
{$ENDIF}

function CompareMemory(Address, Pattern, Size: LongWord): Boolean;
begin
Result := CompareMemory(Pointer(Address), Pointer(Pattern), Size);
end;

procedure ReplaceMemory(const Address, Pattern: Pointer; Size: LongWord);
var
 I, Protect: LongWord;
begin
if (Address = nil) or (Pattern = nil) or (Size = 0) then
 Exit
else
 begin
  VirtualProtect(Address, Size, PAGE_READWRITE, Protect);
  for I := 0 to Size - 1 do
   PByte(Cardinal(Address) + I)^ := PByte(Cardinal(Pattern) + I)^;
  VirtualProtect(Address, Size, Protect, Protect);
 end;
end;

procedure ReplaceMemory(Address, Pattern, Size: LongWord);
begin
ReplaceMemory(Pointer(Address), Pointer(Pattern), Size);
end;

function CompareMemory_Internal(const Address, Pattern: Pointer; Size: LongWord): Boolean;
asm
 push ebx

@Loop:
 mov bl, byte ptr [edx]
 cmp bl, byte ptr [eax]
 je @PostLoop
 sub bl, $FF
 je @PostLoop

 xor eax, eax
 pop ebx
 ret

@PostLoop:
 inc eax
 inc edx
 dec ecx
 jne @Loop

 mov eax, 1
 pop ebx
 ret

@NotEqual:
 xor eax, eax
end;

function FindPattern(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; const Offset: Longint): Pointer;
var
 I: LongWord;
begin
if (StartAddr = nil) or (EndAddr = nil) or (Pattern = nil) or (PatternSize = 0) then
 Result := nil
else
 begin
  for I := Cardinal(StartAddr) to Cardinal(EndAddr) - (PatternSize - 1) do
   if CompareMemory_Internal(Pointer(I), Pattern, PatternSize) then
    begin
     Result := Pointer(Longint(I) + Offset);
     Exit;
    end;
  Result := nil;
 end;
end;

function FindPattern(StartAddr, EndAddr: LongWord; const Pattern: Pointer; PatternSize: LongWord; const Offset: Longint): Pointer;
begin
Result := FindPattern(Pointer(StartAddr), Pointer(EndAddr), Pattern, PatternSize, Offset);
end;

function CheckByte(Address: LongWord; Value: Byte; const Offset: Longint = 0): Boolean;
begin
Result := PByte(Longint(Address) + Offset)^ <> Value;
end;

function CheckByte(const Address: Pointer; Value: Byte; const Offset: Longint = 0): Boolean;
begin
Result := PByte(Longint(Address) + Offset)^ <> Value;
end;

function CheckWord(Address: LongWord; Value: Word; const Offset: Longint = 0): Boolean;
begin
Result := PWord(Longint(Address) + Offset)^ <> Value;
end;

function CheckWord(const Address: Pointer; Value: Word; const Offset: Longint = 0): Boolean;
begin
Result := PWord(Longint(Address) + Offset)^ <> Value;
end;

function CheckLongWord(Address, Value: LongWord; const Offset: Longint = 0): Boolean;
begin
Result := PLongWord(Longint(Address) + Offset)^ <> Value;
end;

function CheckLongWord(const Address: Pointer; Value: LongWord; const Offset: Longint = 0): Boolean;
begin
Result := PLongWord(Longint(Address) + Offset)^ <> Value;
end;

function FindEngineAndClient: Boolean;
var
 Addr: Pointer;
begin
Addr := FindPattern(HLBase, HLBase_End, Pointer(EngineString), Length(EngineString), 0);
if Bounds(Addr, HLBase, HLBase_End) then
 begin
  Result := False;
  Exit;
 end;

PPointer(Cardinal(@Pattern_Engine) + Pattern_Engine_WriteOffset)^ := Addr;

Addr := FindPattern(HLBase, HLBase_End, @Pattern_Engine, SizeOf(Pattern_Engine), 8);
if Bounds(Addr, HLBase, HLBase_End) then
 begin
  Result := False;
  Exit;
 end;

if CheckByte(Addr, $6A, 25) then
 Error('Couldn''t find client interface version.');

ClientVersion := PByte(Cardinal(Addr) + 26)^;
if ClientVersion <> CLDLL_INTERFACE_VERSION then
 Error('Invalid client interface version (got ', IntToStr(ClientVersion), ', expected ', IntToStr(CLDLL_INTERFACE_VERSION), ').');

PEngine := PPointer(Cardinal(Addr) + 28)^;
if CheckByte(Addr, $68, 27) or Bounds(PEngine, HLBase, HLBase_End) then
 PrintSearchError('PEngine');

PClient := PPointer(Cardinal(Addr) + 34)^;
if CheckWord(Addr, $15FF, 32) or Bounds(PClient, HLBase, HLBase_End) then
 PrintSearchError('PClient');

HookUserMsg := Pointer(Absolute(Cardinal(Addr) + 6));
if CheckByte(Addr, $E8, 5) or Bounds(@HookUserMsg, HLBase, HLBase_End, True) then
 PrintSearchError('HookUserMsg');

Result := True;
end;

procedure FindStudio;
var
 Addr: Pointer;
begin
Addr := FindPattern(HLBase, HLBase_End, Pointer(StudioString), Length(StudioString), 0);
if Bounds(Addr, HLBase, HLBase_End) then
 Error('Couldn''t find scanning pattern for PStudio.');

PPointer(Cardinal(@Pattern_Studio) + Pattern_Studio_WriteOffset)^ := Addr;

Addr := FindPattern(HLBase, HLBase_End, @Pattern_Studio, SizeOf(Pattern_Studio), -18);
if Bounds(Addr, HLBase, HLBase_End) then
 Error('Couldn''t find scanning pattern for PStudio.');

if CheckByte(Addr, $6A, 9) then
 Error('Couldn''t find studio interface version.');

StudioVersion := PByte(Cardinal(Addr) + 10)^;
if StudioVersion <> STUDIO_INTERFACE_VERSION then
 Error('Invalid studio interface version (got ' + IntToStr(StudioVersion) + ', expected ' + IntToStr(STUDIO_INTERFACE_VERSION) + ').');

PStudio := PPointer(Addr)^;
if CheckByte(Addr, $68, -1) or Bounds(PStudio, HLBase, HLBase_End) then
 PrintSearchError('PStudio');
 
PStudioInterface := PPointer(Cardinal(Addr) + 5)^;
if CheckByte(Addr, $68, 4) or Bounds(PStudioInterface, HLBase, HLBase_End) then
 PrintSearchError('PInterface');
end;

procedure Find_Cmd_TokenizeString;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.ServerCmd) + 54 - Cardinal(SW));
CvarDef.Cmd_TokenizeString_Orig := Pointer(Absolute(Addr));
if CheckWord(Addr, $E850, -2) or Bounds(@CvarDef.Cmd_TokenizeString_Orig, HLBase, HLBase_End, True) then
 begin
  Addr := Pointer(Cardinal(@Engine.ServerCmdUnreliable) + 54 - Cardinal(SW));
  CvarDef.Cmd_TokenizeString_Orig := Pointer(Absolute(Addr));
  if CheckWord(Addr, $E850, -2) or Bounds(@CvarDef.Cmd_TokenizeString_Orig, HLBase, HLBase_End, True) then
   PrintSearchError('Cmd_TokenizeString');
 end;
end;

procedure Find_Cmd_Args;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('writecfg');
CheckCallback(Cmd);
Addr := Pointer(Cardinal(@Cmd.Callback) + 8 + Cardinal(SW) * 3);
CvarDef.Cmd_Args := Pointer(Absolute(Addr));
if CheckWord(Addr, $E856, -2) or Bounds(@CvarDef.Cmd_Args, HLBase, HLBase_End, True) then
 begin
  Cmd := CommandByName('listen');
  CheckCallback(Cmd);
  Addr := Pointer(Cardinal(@Cmd.Callback) + 25 + Cardinal(SW) * 3);
  CvarDef.Cmd_Args := Pointer(Absolute(Addr));
  if CheckLongWord(Addr, $E8C304C4, -4) or Bounds(@CvarDef.Cmd_Args, HLBase, HLBase_End, True) then
   PrintSearchError('Cmd_Args');
 end;
end;

procedure Find_Sys_Error;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Studio.Mod_ExtraData) + 58 - Cardinal(SW) * 8);
CvarDef.Sys_Error := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or CheckWord(Addr, $D75, -8) or Bounds(@CvarDef.Sys_Error, HLBase, HLBase_End, True) then
 begin
  Addr := Pointer(Cardinal(@Engine.SPR_Load) + 162 - Cardinal(SW) * 6);
  CvarDef.Sys_Error := Pointer(Absolute(Addr));
  if CheckByte(Addr, $E8, -1) or CheckByte(Addr, $68, -6) or Bounds(@CvarDef.Sys_Error, HLBase, HLBase_End, True) then
   PrintSearchError('Sys_Error');
 end;
end;

procedure Find_COM_Parse;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.COM_ParseFile) + 23);
CvarDef.COM_Parse := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.COM_Parse, HLBase, HLBase_End, True) then
 begin
  Addr := Pointer(Cardinal(@Engine.SPR_GetList) + 57 - Cardinal(SW) * 5);
  CvarDef.COM_Parse := Pointer(Absolute(Addr));
  if CheckWord(Addr, $E850, -2) or Bounds(@CvarDef.COM_Parse, HLBase, HLBase_End, True) then
   PrintSearchError('COM_Parse');
 end;
end;

procedure Find_COM_Token;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.COM_ParseFile) + 34 - Cardinal(SW));
CvarDef.COM_Token := PPointer(Addr)^;
if CheckByte(Addr, $68, -1) or Bounds(CvarDef.COM_Token, HLBase, HLBase_End) then
 begin
  Addr := Pointer(Cardinal(@Engine.SPR_GetList) + 62 - Cardinal(SW) * 5);
  CvarDef.COM_Token := PPointer(Addr)^;
  if CheckByte(Addr, $68, -1) or Bounds(CvarDef.COM_Token, HLBase, HLBase_End) then
   PrintSearchError('COM_Token');
 end;
end;

procedure Find_CBuf_AddText;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.ClientCmd) + 25 + Cardinal(SW) * 2);
CvarDef.CBuf_AddText := Pointer(Absolute(Addr));
if CheckWord(Addr, $E850, -2) or Bounds(@CvarDef.CBuf_AddText, HLBase, HLBase_End, True) then
 begin
  Cmd := CommandByName('escape');
  CheckCallback(Cmd);
  Addr := Pointer(Cardinal(@Cmd.Callback) + 15);
  CvarDef.CBuf_AddText := Pointer(Absolute(Addr));
  if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.CBuf_AddText, HLBase, HLBase_End, True) then
   PrintSearchError('CBuf_AddText');
 end;
end;

procedure Find_CBuf_Execute;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('escape');
CheckCallback(Cmd);
Addr := Pointer(Cardinal(@Cmd.Callback) + 48);
CvarDef.CBuf_Execute := Pointer(Absolute(Addr));
if (CheckByte(Addr, $E8, -1) and CheckByte(Addr, $E9, -1)) or Bounds(@CvarDef.CBuf_Execute, HLBase, HLBase_End, True) then
 PrintSearchError('CBuf_Execute');
end;

procedure Find_SVCBase;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('cl_messages');
CheckCallback(Cmd);

Addr := Pointer(Cardinal(@Cmd.Callback) + 28 - Cardinal(SW) * 3);
if CheckWord(Addr, $048B, 4) or CheckByte(Addr, $B5, 6) then
 Error('Couldn''t find SVCBase pointer (invalid code pattern).');

Addr := PPCardinal(Addr)^;
if Bounds(Addr, HLBase, HLBase_End) or Bounds(PPChar(Addr)^, HLBase, HLBase_End) or
   (StrComp(PPChar(Addr)^, 'svc_bad') <> 0) then
 Error('Couldn''t find SVCBase pointer (invalid pointer address).');

SVCBase := Pointer(Cardinal(Addr) - SizeOf(LongWord));

Addr := Pointer(Cardinal(@Cmd.Callback) + 45 - Cardinal(SW) * 3);
if CheckWord(Addr, $047F, 4) then
 Error('Couldn''t find SVCBase_End pointer (invalid code pattern).');

SVCBase_End := Pointer(PCardinal(Addr)^ + SizeOf(LongWord));
if Bounds(SVCBase_End, HLBase, HLBase_End) then
 Error('Couldn''t find SVCBase_End pointer (invalid pointer address).');

if Cardinal(SVCBase_End) <= Cardinal(SVCBase) then
 Error('Couldn''t find SVCBase_End pointer (invalid memory alignment).');

SVCCount := (Cardinal(SVCBase_End) - Cardinal(SVCBase)) div SizeOf(server_msg_t);
end;

procedure Find_MSGInterface;
begin
CvarDef.MSG_ReadByte := Pointer(Absolute(GetCallback(SVC_CDTRACK) + 1));
if Bounds(@CvarDef.MSG_ReadByte, HLBase, HLBase_End, True) then
 PrintSearchError('MSG_ReadByte');

CvarDef.MSG_ReadShort := Pointer(Absolute(GetCallback(SVC_STOPSOUND) + 1));
if Bounds(@CvarDef.MSG_ReadShort, HLBase, HLBase_End, True) then
 PrintSearchError('MSG_ReadShort');

CvarDef.MSG_ReadLong := Pointer(Absolute(GetCallback(SVC_VERSION) + 1));
if Bounds(@CvarDef.MSG_ReadLong, HLBase, HLBase_End, True) then
  PrintSearchError('MSG_ReadLong');

CvarDef.MSG_ReadFloat := Pointer(Absolute(GetCallback(SVC_TIME) + 34 - Cardinal(SW) * 5));
if Bounds(@CvarDef.MSG_ReadFloat, HLBase, HLBase_End, True) then
  PrintSearchError('MSG_ReadFloat');

CvarDef.MSG_ReadString := Pointer(Absolute(GetCallback(SVC_PRINT) + 1));
if Bounds(@CvarDef.MSG_ReadString, HLBase, HLBase_End, True) then
  PrintSearchError('MSG_ReadString');

CvarDef.MSG_ReadAngle16 := Pointer(Absolute(GetCallback(SVC_ADDANGLE) + 2 + Cardinal(SW) * 3));
if Bounds(@CvarDef.MSG_ReadAngle16, HLBase, HLBase_End, True) then
  PrintSearchError('MSG_ReadAngle16');

CvarDef.MSG_ReadChar := Pointer(Absolute(Cardinal(@CvarDef.MSG_ReadString) + 7));
if Bounds(@CvarDef.MSG_ReadChar, HLBase, HLBase_End, True) then
 PrintSearchError('MSG_ReadChar');

CvarDef.MSG_ReadBits := Pointer(Absolute(GetCallback(SVC_PINGS) + 18));
if Bounds(@CvarDef.MSG_ReadBits, HLBase, HLBase_End, True) then
  PrintSearchError('MSG_ReadBits');

CvarDef.MSG_ReadCount := PPLongint(Cardinal(@CvarDef.MSG_ReadByte) + 1)^;
if Bounds(CvarDef.MSG_ReadCount, HLBase, HLBase_End) then
 PrintSearchError('MSG_ReadCount');

CvarDef.MSG_CurrentSize := PPLongint(Cardinal(@CvarDef.MSG_ReadByte) + 7)^;
if Bounds(CvarDef.MSG_CurrentSize, HLBase, HLBase_End) then
 PrintSearchError('MSG_CurrentSize');

CvarDef.MSG_BadRead := PPLongint(Cardinal(@CvarDef.MSG_ReadByte) + 20)^;
if Bounds(CvarDef.MSG_BadRead, HLBase, HLBase_End) then
 PrintSearchError('MSG_BadRead');

CvarDef.MSG_Base := PPointer(Cardinal(@CvarDef.MSG_ReadFloat) + 8 + Cardinal(SW) * 3)^;
if Bounds(CvarDef.MSG_Base, HLBase, HLBase_End) then
 PrintSearchError('MSG_Base');

CvarDef.MSG_StartBitReading := Pointer(Absolute(GetCallback(SVC_SOUND) + 13 + Cardinal(SW) * 2));
if Bounds(@CvarDef.MSG_StartBitReading, HLBase, HLBase_End, True) then
 begin
  CvarDef.MSG_StartBitReading := Pointer(Absolute(GetCallback(SVC_PINGS) + 8 - Cardinal(Protocol = 47) * 2));
  if Bounds(@CvarDef.MSG_StartBitReading, HLBase, HLBase_End, True) then
   PrintSearchError('MSG_StartBitReading');
 end;

CvarDef.MSG_EndBitReading := Pointer(Absolute(GetCallback(SVC_SOUND) + 227 - Cardinal(SW) * 12));
if Bounds(@CvarDef.MSG_EndBitReading, HLBase, HLBase_End, True) then
 begin
  CvarDef.MSG_EndBitReading := Pointer(Absolute(GetCallback(SVC_PINGS) + 86 + Cardinal(Protocol = 47) * 5));
  if Bounds(@CvarDef.MSG_EndBitReading, HLBase, HLBase_End, True) then
   PrintSearchError('MSG_EndBitReading');
 end;
end;

procedure Find_Cmd_ExecuteString;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CvarDef.CBuf_Execute) + 148 + Cardinal(SW) * 12);
Cmd_ExecuteString_Orig := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.Cmd_ExecuteString_Orig, HLBase, HLBase_End, True) then
 PrintSearchError('Cmd_ExecuteString');
end;

procedure Find_IsValidCmd;
var
 Addr: Pointer;
begin
Addr := Pointer(GetCallback(HLSDK.SVC_STUFFTEXT) + 10);
CvarDef.IsValidCmd := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or CheckWord(Addr, $C483, 4) or CheckByte(Addr, $08, 5) or
   Bounds(@CvarDef.IsValidCmd, HLBase, HLBase_End, True) then
 CvarDef.IsValidCmd := @IsValidCmd2;
end;

procedure Find_CState;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.GetLevelName) + 7);
CvarDef.CState := PPointer(Addr)^;
if CheckByte(Addr, $A1, -1) or Bounds(CvarDef.CState, HLBase, HLBase_End) then
 begin
  Cmd := CommandByName('exit');
  CheckCallback(Cmd);
  Addr := Pointer(Cardinal(@Cmd.Callback) + 16);
  CvarDef.CState := PPointer(Addr)^;
  if CheckByte(Addr, $A1, -1) or Bounds(CvarDef.CState, HLBase, HLBase_End) then
   PrintSearchError('CState');
 end;
end;

procedure Find_CommandBounds;
begin
CvarDef.CL_CheckCommandBounds := FindPattern(HLBase, HLBase_End, @Pattern_CommandBounds, SizeOf(Pattern_CommandBounds), -Cardinal(SW) * 3);
if Bounds(@CvarDef.CL_CheckCommandBounds, HLBase, HLBase_End, True) then
 PrintSearchError('CL_CheckCommandBounds');
end;

procedure Find_Spectator;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@Engine.IsSpectateOnly) + 8);
CvarDef.Spectator := PPLongint(Addr)^;
if CheckByte(Addr, $8B, -2) or Bounds(CvarDef.Spectator, HLBase, HLBase_End) then
 if SVCCount - 1 < SVC_TIMESCALE then
  PrintSearchError('Spectator')
 else
  begin
   Addr := Pointer(GetCallback(SVC_TIMESCALE) + 6);
   CvarDef.Spectator := PPLongint(Addr)^;
   if CheckByte(Addr, $A1, -1) or Bounds(CvarDef.Spectator, HLBase, HLBase_End) then
    PrintSearchError('Spectator');
  end;
end;

procedure Patch_Host_FilterTime;
var
 Addr, Addr2: Pointer;
 Protect: LongWord;
begin
if FPSLimitPatchType = [] then
 Exit;

Addr := FindPattern(HLBase, HLBase_End, @Pattern_Host_FilterTime, SizeOf(Pattern_Host_FilterTime), SizeOf(Pattern_Host_FilterTime));
if Bounds(Addr, HLBase, HLBase_End) then
 PrintSearchError('Host_FilterTime');

Addr2 := Addr;

if PATCH_100FPS in FPSLimitPatchType then
 begin
  VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
  PByte(Addr)^ := $EB;
  VirtualProtect(Addr, 1, Protect, Protect);
 end;

if PATCH_30FPS in FPSLimitPatchType then
 begin
  Addr := Pointer(Cardinal(Addr) - 40 - SizeOf(Pattern_Host_FilterTime));
  if PWord(Addr)^ = $0D74 then
   begin
    VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
    PByte(Addr)^ := $EB;
    VirtualProtect(Addr, 1, Protect, Protect);
   end
  else
   begin
    Print('WARNING: Couldn''t find patch pattern 2 at Patch_Host_FilterTime.');
    Exit;
   end;
 end;

if PATCH_1000FPS in FPSLimitPatchType then
 begin
  Addr := FindPattern(Cardinal(Addr2), HLBase_End, @Pattern_Host_FilterTime_3, SizeOf(Pattern_Host_FilterTime_3), SizeOf(Pattern_Host_FilterTime_3) - 22);
  if Bounds(Addr, HLBase, HLBase_End) then
   Print('WARNING: Couldn''t find patch pattern 3 at Patch_Host_FilterTime.')
  else
   begin
    VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
    PByte(Addr)^ := $EB;
    VirtualProtect(Addr, 1, Protect, Protect);
   end;
 end;
end;

procedure Patch_Host_FilterTime_SW;
var
 Addr, Addr2: Pointer;
 Protect: LongWord;
begin
if FPSLimitPatchType = [] then
 Exit;

Addr := FindPattern(HLBase, HLBase_End, @Pattern_Host_FilterTime_SW, SizeOf(Pattern_Host_FilterTime_SW), SizeOf(Pattern_Host_FilterTime_SW));
if Bounds(Addr, HLBase, HLBase_End) then
 PrintSearchError('Host_FilterTime');

Addr2 := Addr;

if PATCH_100FPS in FPSLimitPatchType then
 begin
  VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
  PByte(Addr)^ := $EB;
  VirtualProtect(Addr, 1, Protect, Protect);
 end;

if PATCH_30FPS in FPSLimitPatchType then
 begin
  Addr := Pointer(Cardinal(Addr) - 37 - SizeOf(Pattern_Host_FilterTime_SW));
  if PWord(Cardinal(Addr) - 1)^ = $7401 then
   begin
    VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
    PByte(Addr)^ := $EB;
    VirtualProtect(Addr, 1, Protect, Protect);
   end
  else
   begin
    Print('WARNING: Couldn''t find patch pattern 2 at Patch_Host_FilterTime_SW.');
    Exit;
   end;
 end;

if PATCH_1000FPS in FPSLimitPatchType then
 begin
  Addr := FindPattern(Cardinal(Addr2), HLBase_End, @Pattern_Host_FilterTime_3, SizeOf(Pattern_Host_FilterTime_3), SizeOf(Pattern_Host_FilterTime_3) - 22);
  if Bounds(Addr, HLBase, HLBase_End) then
   Print('WARNING: Couldn''t find patch pattern 3 at Patch_Host_FilterTime_SW.')
  else
   begin
    VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
    PByte(Addr)^ := $EB;
    VirtualProtect(Addr, 1, Protect, Protect);
   end;
 end;
end;

procedure Patch_Cmd_Alias;
var
 Cmd: cmd_s;
 Addr: Pointer;
 Protect: LongWord;
begin
Cmd := CommandByName('alias');
CheckCallback(Cmd);

Addr := Pointer(Cardinal(@Cmd.Callback) + 171 - Cardinal(SW) * 3);
if Bounds(Addr, HLBase, HLBase_End) or CheckWord(Addr, $C085) then
 Error('Couldn''t find patch pattern 1 at Patch_Cmd_Alias.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
WriteNOPs(Addr, 4);
VirtualProtect(Addr, 4, Protect, Protect);

if CheckLongWord(Addr, $840FC085, 9) then
 Error('Couldn''t find patch pattern 2 at Patch_Cmd_Alias.');
 
Addr := Pointer(Cardinal(Addr) + 11);

VirtualProtect(Addr, 6, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $E9;
PLongWord(Cardinal(Addr) + 1)^ := PByte(Cardinal(Addr) + 2)^ + 1;
PByte(Cardinal(Addr) + 5)^ := $90;
VirtualProtect(Addr, 6, Protect, Protect);
end;

procedure Patch_Cmd_ForwardToServer;
var
 Addr: Pointer;
 Protect: LongWord;
begin
Addr := FindPattern(Cardinal(@Cmd_ExecuteString_Orig), HLBase_End, @Pattern_Cmd_ForwardToServer, SizeOf(Pattern_Cmd_ForwardToServer), SizeOf(Pattern_Cmd_ForwardToServer));
if Bounds(Addr, HLBase, HLBase_End) then
 Error('Couldn''t find patch pattern 1 at Cmd_ForwardToServer.');

case PByte(Addr)^ of
 $5E: Inc(Cardinal(Addr), 2);
 $E8: Inc(Cardinal(Addr), 1);
 $E9: Error('Cmd_ForwardToServer is already patched!');
 else
  Error('Couldn''t find patch pattern 2 at Cmd_ForwardToServer.');
end;

CvarDef.Cmd_ForwardToServer_Orig := Pointer(Absolute(Addr));
if Bounds(@CvarDef.Cmd_ForwardToServer_Orig, HLBase, HLBase_End, True) then
 Error('Couldn''t find Cmd_ForwardToServer pointer.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@CMDBlock.Cmd_ForwardToServer));
VirtualProtect(Addr, 4, Protect, Protect);
end;

procedure Patch_CL_Move;
var
 Addr: Pointer;
begin
if not SW then
 Addr := FindPattern(HLBase, HLBase_End, @Pattern_CL_Move, SizeOf(Pattern_CL_Move), SizeOf(Pattern_CL_Move) - 6)
else
 Addr := FindPattern(HLBase, HLBase_End, @Pattern_CL_Move_SW, SizeOf(Pattern_CL_Move_SW), SizeOf(Pattern_CL_Move_SW) - 6);

if Bounds(Addr, HLBase, HLBase_End) then
 Error('Couldn''t find patch pattern 1 at CL_Move.')
else
 if not CheckByte(Addr, $E9) then
  Error('CL_Move is already patched!')
 else
  CL_Move_Patch_Gate := Detour(Addr, @CL_Move_Patch, 5);
end;

function Find_IsValidFile: Boolean;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('motd_write');
CheckCallback(Cmd);

Addr := Pointer(Cardinal(@Cmd.Callback) + 14 + Cardinal(SW) * 3);

if CheckByte(Addr, $E8, -1) then
 Result := False
else
 begin
  CvarDef.IsValidFile_Orig := Pointer(Absolute(Addr));
  Result := not Bounds(@CvarDef.IsValidFile_Orig, HLBase, HLBase_End, True);
 end;
end;

procedure Find_GameConsole003;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('clear');
CheckCallback(Cmd);

Addr := Pointer(Absolute(Cardinal(@Cmd.Callback) + 26));
if CheckByte(@Cmd.Callback, $E9, 25) or Bounds(Addr, HLBase, HLBase_End, True) then
 PrintSearchError('GameConsole003');

GameConsole003 := PPointer(Cardinal(Addr) + 2)^;
if CheckWord(Addr, $0D8B) or Bounds(GameConsole003, HLBase, HLBase_End) then
 PrintSearchError('GameConsole003');

GameUI007 := PPointer(Cardinal(GameConsole003) - SizeOf(GameUI007))^;
GameConsole003 := PPointer(GameConsole003)^;

Console_TextColor := PColor24(Cardinal(GameConsole003.Data.Panel) + 292 + Cardinal(Protocol = 48) * SizeOf(LongWord));
if PCardinal(Cardinal(Console_TextColor) + 8)^ <> 0 then
 Inc(Cardinal(Console_TextColor), SizeOf(LongWord));

Console_TextColorDev := PColor24(Cardinal(Console_TextColor) + 4);
end;

procedure Find_CVar_Command;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CvarDef.Cmd_ExecuteString_Orig) + 166 + Cardinal(SW) * 7); 
CvarDef.CVar_Command := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.CVar_Command, HLBase, HLBase_End, True) then
 begin
  Addr := Pointer(Cardinal(@CvarDef.Cmd_ExecuteString_Orig) + 170 + Cardinal(SW) * 7);
  CvarDef.CVar_Command := Pointer(Absolute(Addr));
  if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.CVar_Command, HLBase, HLBase_End, True) then
   PrintSearchError('CVar_Command');
 end;
end;

procedure Patch_CVar_Command;
var
 Addr: Pointer;
 Protect: LongWord;
begin
Addr := Pointer(Cardinal(@CvarDef.CVar_Command) + 128);
if CheckByte(Addr, $74) or CheckByte(Addr, $A1, 2) then
 Error('Couldn''t find patch pattern 1 at Patch_CVar_Command.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);
end;

procedure Find_SetValueForKey;
var
 Addr: Pointer;
 Cmd: cmd_s;
begin
Cmd := CommandByName('setinfo');
CheckCallback(Cmd);
Addr := Pointer(Cardinal(@Cmd.Callback) + 91);
CvarDef.SetValueForKey := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.SetValueForKey, HLBase, HLBase_End, True) then
 begin
  Cmd := CommandByName('localinfo');
  CheckCallback(Cmd);
  Addr := Pointer(Cardinal(@Cmd.Callback) + 128);
  CvarDef.SetValueForKey := Pointer(Absolute(Addr));
  if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.SetValueForKey, HLBase, HLBase_End, True) then
   PrintSearchError('SetValueForKey');
 end;
end;

procedure Patch_SetValueForKey;
var
 Addr: Pointer;
 Protect: LongWord;
 Cmd: cmd_s;
begin
if LocalInfoPatchType = PATCH_TYPE_SETINFO then
 begin
  Cmd := CommandByName('setinfo');
  CheckCallback(Cmd);
  
  Addr := Pointer(Cardinal(@Cmd.Callback) + 91);
  if CheckByte(Addr, $E8, -1) then
   Error('Couldn''t find patch pattern 1 at Patch_SetValueForKey (PATCH_TYPE_SETINFO).');

  VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
  PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@Engine.NetAPI.SetValueForKey));
  VirtualProtect(Addr, 4, Protect, Protect);

  Addr := Pointer(Cardinal(@Cmd.Callback) + 135);
  if CheckByte(Addr, $E8, -1) then
   Error('Couldn''t find patch pattern 2 at Patch_SetValueForKey (PATCH_TYPE_SETINFO).');

  VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
  PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@Engine.NetAPI.SetValueForKey));
  VirtualProtect(Addr, 4, Protect, Protect);
 end
else
 begin
  Addr := Pointer(Cardinal(@CvarDef.SetValueForKey) + 7 + Cardinal(SW) * 2);
  if CheckLongWord(Addr, $752A3880, -3) then
   Error('Couldn''t find patch pattern 1 at Patch_SetValueForKey (PATCH_TYPE_GLOBAL).');

  VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
  PByte(Addr)^ := $EB;
  VirtualProtect(Addr, 1, Protect, Protect);
 end;

Cmd := CommandByName('localinfo');
CheckCallback(Cmd);
  
Addr := Pointer(Cardinal(@Cmd.Callback) + 73);
if CheckWord(Addr, $752A, -1) then
 Error('Couldn''t find patch pattern 1 at Patch_SetValueForKey (PATCH_TYPE_LOCALINFO).');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);
end;

procedure Find_R_CheckVariables;
begin
CL_ParseServerInfo := Pointer(Absolute(GetCallback(SVC_SERVERINFO) + 1));
if Bounds(@CvarDef.CL_ParseServerInfo, HLBase, HLBase_End, True) then
 PrintSearchError('CL_ParseServerInfo');

if Protocol = 47 then
 R_CheckVariables := Pointer(Absolute(Cardinal(@CvarDef.CL_ParseServerInfo) + 348 + Cardinal(SW) * 23))
else
 R_CheckVariables := Pointer(Absolute(Cardinal(@CvarDef.CL_ParseServerInfo) + 348));
 
if Bounds(@CvarDef.R_CheckVariables, HLBase, HLBase_End, True) then // p47
 begin
  if not SW then
   CvarDef.R_CheckVariables := FindPattern(HLBase, HLBase_End, @Pattern_R_CheckVariables, SizeOf(Pattern_R_CheckVariables), -5)
  else
   CvarDef.R_CheckVariables := FindPattern(HLBase, HLBase_End, @Pattern_R_CheckVariables_SW, SizeOf(Pattern_R_CheckVariables_SW), 0);

  if Bounds(@CvarDef.R_CheckVariables, HLBase, HLBase_End, True) then // it's p36
   begin
    R_CheckVariables := Pointer(Absolute(Cardinal(@CvarDef.CL_ParseServerInfo) + 378));
    if Bounds(@CvarDef.R_CheckVariables, HLBase, HLBase_End, True) then
     PrintSearchError('R_CheckVariables');
   end;
 end;
end;

procedure Patch_R_CheckVariables;
var
 Addr: Pointer;
 Protect: LongWord;
begin
if Protocol = 48 then
 begin
  VirtualProtect(@CvarDef.R_CheckVariables, 1, PAGE_EXECUTE_READWRITE, Protect);
  PByte(@CvarDef.R_CheckVariables)^ := $C3;
  VirtualProtect(@CvarDef.R_CheckVariables, 1, Protect, Protect);
 end
else
 begin
  Addr := Pointer(Cardinal(@CvarDef.R_CheckVariables) + 11 + Cardinal(SW) * 9);
  if CheckByte(Addr, $0F) then // p36
   begin
    if PByte(Cardinal(@CvarDef.R_CheckVariables) + Cardinal(SW) * 3)^ <> $8B then
     Error('Couldn''t find patch pattern 1 at Patch_R_CheckVariables.');
    VirtualProtect(@CvarDef.R_CheckVariables, 1, PAGE_EXECUTE_READWRITE, Protect);
    PByte(@CvarDef.R_CheckVariables)^ := $C3;
    VirtualProtect(@CvarDef.R_CheckVariables, 1, Protect, Protect);
   end
  else
   begin
    VirtualProtect(Addr, 6, PAGE_EXECUTE_READWRITE, Protect);
    PByte(Addr)^ := $E9;
    PLongWord(Cardinal(Addr) + 1)^ := PLongWord(Cardinal(Addr) + 2)^ + 1;
    PByte(Cardinal(Addr) + 5)^ := $90;
    VirtualProtect(Addr, 6, Protect, Protect);
   end;
 end;
end;

procedure Patch_Cmd_StartMovie;
var
 Cmd: cmd_s;
 Addr: Pointer;
 Protect: LongWord;
begin
Cmd := CommandByName('startmovie');
CheckCallback(Cmd);

Addr := Pointer(Cardinal(@Cmd.Callback) + 40);
if CheckByte(Addr, $75) or CheckWord(Addr, $C085, -2) then
 Error('Couldn''t find patch pattern 1 at Patch_Cmd_StartMovie.');
 
VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);

Addr := Pointer(Cardinal(Addr) + 19);
if CheckByte(Addr, $E8, -1) then
 Error('Couldn''t find patch pattern 2 at Patch_Cmd_StartMovie.');

Cmd_Argv_Patch_Gate := Pointer(Absolute(Addr));

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@Cmd_Argv_Patch));
VirtualProtect(Addr, 4, Protect, Protect);
end;

procedure Find_LastArgString;
begin
LastArgString := PPChar(PPChar(Cardinal(@CvarDef.Cmd_Args) + 1)^);
if CheckByte(@CvarDef.Cmd_Args, $A1) or Bounds(LastArgString, HLBase, HLBase_End) then
 PrintSearchError('LastArgString');
end;

procedure Patch_CL_CheckCommandBounds;
var
 Addr: Pointer;
 Protect: LongWord;
begin
Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 31 + Cardinal(SW) * 3);
if PWord(Cardinal(Addr) - 3)^ <> $C4F6 then
 Error('Couldn''t find CL_CheckCommandBounds patch pattern 1.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);

if PByte(Cardinal(@CL_CheckCommandBounds) + 68 + Cardinal(SW) * 3)^ = $D9 then
 begin
  Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 85 + Cardinal(SW) * 3);
  if PWord(Cardinal(Addr) - 2)^ <> $41C4 then
   Error('Couldn''t find CL_CheckCommandBounds patch pattern 2.');
 end;

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);

if Protocol = 47 then
 Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 156 + Cardinal(SW) * 3)
else
 Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 208 + Cardinal(SW) * 3);

case PByte(Addr)^ of
 $F7: Addr := Pointer(Cardinal(Addr) - 3);
 $8B: Addr := Pointer(Cardinal(Addr) - 2);
 $0E: Addr := Pointer(Cardinal(Addr) - 1);
 $C7: Addr := Pointer(Cardinal(Addr) + 1);
 $3B: Addr := Pointer(Cardinal(Addr) + 2);
end;

if PWord(Cardinal(Addr) - 2)^ <> $C73B then
 Error('Couldn''t find CL_CheckCommandBounds patch pattern 3.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);

if Protocol = 47 then
 Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 173 + Cardinal(SW) * 3)
else
 Addr := Pointer(Cardinal(@CL_CheckCommandBounds) + 229 + Cardinal(SW) * 2);

case PByte(Addr)^ of
 $F3: Addr := Pointer(Cardinal(Addr) - 3);
 $8B: Addr := Pointer(Cardinal(Addr) - 2);
 $4C: Addr := Pointer(Cardinal(Addr) - 1);
 $CB: Addr := Pointer(Cardinal(Addr) + 1);
 $3B: Addr := Pointer(Cardinal(Addr) + 2);
end;

if PWord(Cardinal(Addr) - 2)^ <> $CB3B then
 Error('Couldn''t find CL_CheckCommandBounds patch pattern 4.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $EB;
VirtualProtect(Addr, 1, Protect, Protect);
end;

function Find_SteamIDPtr: Boolean;
var
 SCBase, SCSize, SCBase_End: LongWord;
begin
SCBase := GetModuleHandle('steamclient.dll');
if SCBase = 0 then
 begin
  Result := False;
  Exit;
 end;

SCSize := GetModuleSize(SCBase);
if SCSize = 0 then
 SCSize := $66000;

SCBase_End := SCBase + SCSize - 1;

SteamIDPtr := FindPattern(SCBase, SCBase_End, @Pattern_SteamIDPtr, SizeOf(Pattern_SteamIDPtr), 29);
if Bounds(SteamIDPtr, SCBase, SCBase_End) then
 Result := False
else
 begin
  SteamIDPtr := PPLongWord(SteamIDPtr)^;
  Result := not Bounds(SteamIDPtr, SCBase, SCBase_End);
 end;
end;

procedure Find_COM_DefaultExtension;
var
 Addr: Pointer;
 Cmd: cmd_s;
begin
Cmd := CommandByName('listdemo');
CheckCallback(Cmd, False, False);
Addr := Pointer(Cardinal(@Cmd.Callback) + 96 - Cardinal(SW) * 2);
CvarDef.COM_DefaultExtension := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.COM_DefaultExtension, HLBase, HLBase_End, True) then
 begin
  Cmd := CommandByName('viewdemo');
  CheckCallback(Cmd, False, False);
  Addr := Pointer(Cardinal(@Cmd.Callback) + 142 + Cardinal(SW) * 3);
  CvarDef.COM_DefaultExtension := Pointer(Absolute(Addr));
  if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.COM_DefaultExtension, HLBase, HLBase_End, True) then
   PrintSearchError('COM_DefaultExtension');
 end;
end;

procedure Find_Sys_ResetKeyState;
begin
CvarDef.Sys_ResetKeyState_Orig := FindPattern(HLBase, HLBase_End, @Pattern_Sys_ResetKeyState, SizeOf(Pattern_Sys_ResetKeyState), 0);
if Bounds(@CvarDef.Sys_ResetKeyState_Orig, HLBase, HLBase_End, True) then
 PrintSearchError('Sys_ResetKeyState');
end;

procedure Find_Key_ClearStates;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CvarDef.Sys_ResetKeyState_Orig) + 24);
CvarDef.Key_ClearStates := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.Key_ClearStates, HLBase, HLBase_End, True) then
 PrintSearchError('Key_ClearStates');
end;

procedure Find_KeyBindings;
var
 Cmd: cmd_s;
begin
Cmd := CommandByName('unbindall');
CheckCallback(Cmd);

CvarDef.KeyBindings := PPointer(Cardinal(@Cmd.Callback) + 5 + Cardinal(Protocol = 47))^;
if Bounds(CvarDef.KeyBindings, HLBase, HLBase_End) then
 begin
  CvarDef.KeyBindings := PPointer(Cardinal(@Cmd.Callback) + 4 + Cardinal(Protocol = 47))^;
  if Bounds(CvarDef.KeyBindings, HLBase, HLBase_End) then
   PrintSearchError('KeyBindings');
 end;
end;

procedure Find_KeyShift;
begin
if KeyBindings = nil then
 Error('Find_KeyShift called before Find_KeyBindings.');

CvarDef.KeyShift := Pointer(Cardinal(KeyBindings) - SizeOf(key_bindings_t));
if Bounds(CvarDef.KeyShift, HLBase, HLBase_End) then
 PrintSearchError('KeyShift');
end;

procedure Patch_Sys_ResetKeyState;
var
 Addr: Pointer;
 Protect: LongWord;
begin
Addr := Pointer(Cardinal(@CvarDef.Sys_ResetKeyState_Orig) + 7);
if CheckLongWord(Addr, $E856006A, -4) then
 Error('Couldn''t find Sys_ResetKeyState patch pattern 1.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@Key_Event_Patch));
VirtualProtect(Addr, 4, Protect, Protect);
end;

procedure Find_GameInfo;
var
 Cmd: cmd_s;
 Addr: Pointer;
begin
Cmd := CommandByName('version');
CheckCallback(Cmd);

Addr := @Cmd.Callback;

GameName := PPChar(Cardinal(Addr) + 1)^;
if Bounds(GameName, HLBase, HLBase_End) then
 PrintSearchError('GameName');

GameVersion := PPChar(Cardinal(Addr) + 6)^;
if Bounds(GameVersion, HLBase, HLBase_End) then
 PrintSearchError('GameVersion');

Protocol := PByte(Cardinal(Addr) + 11)^;

Addr := Pointer(Absolute(Cardinal(Addr) + 23));
if Bounds(Addr, HLBase, HLBase_End, True) then
 PrintSearchError('GameBuild');

Build := GetAppBuild(Addr);
end;

procedure Find_CL_ParseResourceList;
var
 Addr: Pointer;
begin
Addr := Pointer(GetCallback(SVC_RESOURCELIST) + 1);
CvarDef.CL_ParseResourceList := Pointer(Absolute(Addr));
if (CheckByte(Addr, $E8, -1) and CheckByte(Addr, $E9, -1)) or Bounds(@CvarDef.CL_ParseResourceList, HLBase, HLBase_End, True) then
 PrintSearchError('CL_ParseResourceList');
end;

procedure Find_CL_StartResourceDownloading;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CL_ParseResourceList) + 276);
CvarDef.CL_StartResourceDownloading := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.CL_StartResourceDownloading, HLBase, HLBase_End, True) then
 PrintSearchError('CL_StartResourceDownloading');
end;

procedure Find_CL_ResourceBatchDownload;
var
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CL_StartResourceDownloading) + 214);
CvarDef.CL_ResourceBatchDownload := Pointer(Absolute(Addr));
if (CheckByte(Addr, $E8, -1) and CheckByte(Addr, $E9, -1)) or Bounds(@CvarDef.CL_ResourceBatchDownload, HLBase, HLBase_End, True) then
 begin
  Addr := Pointer(Cardinal(@CL_StartResourceDownloading) + 217);
  CvarDef.CL_ResourceBatchDownload := Pointer(Absolute(Addr));
  if (CheckByte(Addr, $E8, -1) and CheckByte(Addr, $E9, -1)) or Bounds(@CvarDef.CL_ResourceBatchDownload, HLBase, HLBase_End, True) then
   PrintSearchError('CL_ResourceBatchDownload');
 end;
end;

procedure Find_CL_ResourceDownload;
const
 Pattern: array[1..8] of Byte = ($E8, $FF, $FF, $FF, $FF, $83, $C4, $10);
var
 I: LongWord;
 Addr: Pointer;
begin
Addr := Pointer(Cardinal(@CL_ResourceBatchDownload) + 200);
for I := Cardinal(Addr) to Cardinal(Addr) + 32 do
 if CompareMemory_Internal(Pointer(I), @Pattern, SizeOf(Pattern)) then
  begin
   CvarDef.CL_ResourceDownload_Orig := Pointer(Absolute(I + 1));
   if Bounds(@CvarDef.CL_ResourceDownload_Orig, HLBase, HLBase_End, True) then
    Continue
   else
    Exit;
   end;

PrintSearchError('CL_ResourceDownload');
end;

procedure Patch_CL_ConnectionlessPacket;
var
 Addr: Pointer;
 I, Protect: LongWord;
begin
for I := HLBase to HLBase_End - (SizeOf(Pattern_RedirectPacket) - 1) do
 if CompareMemory_Internal(Pointer(I), @Pattern_RedirectPacket, SizeOf(Pattern_RedirectPacket)) then
  begin
   Addr := PPointer(I + 1)^;
   if not Bounds(Addr, HLBase, HLBase_End) and (StrLComp(Addr, 'Redirecting', 11) = 0) then
    begin
     Addr := Pointer(I - 5);
     VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
     PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@CBuf_AddText_CPacket));
     VirtualProtect(Addr, 4, Protect, Protect);
     Exit;
    end;
  end;

PrintSearchError('CL_ConnectionlessPacket');
end;

procedure Patch_IsValidFile;
var
 Cmd: cmd_s;
 Addr: Pointer;
 Protect: LongWord;
begin
Cmd := CommandByName('motd_write');
CheckCallback(Cmd);

if FileCheckingEnabled then
 begin
  Addr := Pointer(Cardinal(@Cmd.Callback) + 14 + Cardinal(SW) * 3);
  
  VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
  PCardinal(Addr)^ := Relative(Cardinal(Addr) - 1, Cardinal(@ResBlock.IsValidFile));
  VirtualProtect(Addr, 4, Protect, Protect);
 end
else // p26 or older version
 begin
  ResBlock_Init;
  Cmd_MOTD_Write_Orig := @Cmd.Callback;
  Cmd.Callback := @ResBlock.Cmd_MOTD_Write;
 end;
end;

procedure Find_COM_ExplainDisconnection;
var
 Addr: Pointer;
begin
Addr := Pointer(GetCallback(SVC_DISCONNECT) + 49);
CvarDef.COM_ExplainDisconnection := Pointer(Absolute(Addr));

if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.COM_ExplainDisconnection, HLBase, HLBase_End, True) then
 PrintSearchError('COM_ExplainDisconnection');
end;

procedure Find_CL_ExitGame;
var
 Cmd: cmd_s;
begin
Cmd := CommandByName('disconnect');
CheckCallback(Cmd);
CvarDef.CL_ExitGame := Pointer(Absolute(Cardinal(@Cmd.Callback) + 1));
if CheckByte(@Cmd.Callback, $E8) or Bounds(@CvarDef.CL_ExitGame, HLBase, HLBase_End, True) then
 PrintSearchError('CL_ExitGame');
end;

procedure Find_Host_Error;
var
 Addr: Pointer;
begin
Addr := Pointer(GetCallback(SVC_VERSION) + 19);
CvarDef.Host_Error := Pointer(Absolute(Addr));
if CheckByte(Addr, $E8, -1) or Bounds(@CvarDef.Host_Error, HLBase, HLBase_End, True) then
 PrintSearchError('Host_Error');
end;

procedure Find_Cmd_Source;
var
 Cmd: cmd_s;
begin
Cmd := CommandByName('appenddemo');
CheckCallback(Cmd, False, False);
Cmd_Source := PPLongint(Cardinal(@Cmd.Callback) + 1)^;
if CheckByte(@Cmd.Callback, $A1) or Bounds(Cmd_Source, HLBase, HLBase_End) then
 begin
  Cmd := CommandByName('waveplaylen');
  CheckCallback(Cmd, False, False);
  Cmd_Source := PPLongint(Cardinal(@Cmd.Callback) + 2)^;
  if CheckWord(@Cmd.Callback, $3D83) or Bounds(Cmd_Source, HLBase, HLBase_End) then
   PrintSearchError('Cmd_Source');
 end;
end;

procedure Find_StopHTTPDownload;
var
 Cmd: cmd_s;
begin
Cmd := CommandByName('httpstop', False);
HTTPDownloadEnabled := Cmd <> nil;

if HTTPDownloadEnabled then
 begin
  CheckCallback(Cmd);
  CvarDef.StopHTTPDownload := Pointer(Absolute(Cardinal(@Cmd.Callback) + 6));
  if CheckByte(@Cmd.Callback, $E9, 5) or Bounds(@CvarDef.StopHTTPDownload, HLBase, HLBase_End, True) then
   PrintSearchError('StopHTTPDownload');
 end
else
 CvarDef.StopHTTPDownload := nil; 
end;

procedure Find_GameUI_StopProgressBar;
var
 Addr: Pointer;
begin
if HTTPDownloadEnabled then
 begin
  Addr := Pointer(Cardinal(@CvarDef.StopHTTPDownload) + 137 + Cardinal(SW) * 9);
  CvarDef.GameUI_StopProgressBar := Pointer(Absolute(Addr));
  if not CheckByte(Addr, $E8, -1) and not Bounds(@CvarDef.GameUI_StopProgressBar, HLBase, HLBase_End, True) then
   Exit;

  Addr := Pointer(Cardinal(@CvarDef.StopHTTPDownload) + 136 + Cardinal(SW) * 6);
  CvarDef.GameUI_StopProgressBar := Pointer(Absolute(Addr));
  if not CheckByte(Addr, $E8, -1) and not Bounds(@CvarDef.GameUI_StopProgressBar, HLBase, HLBase_End, True) then
   Exit;
 end;

PPointer(Cardinal(@Pattern_GameUI_StopProgressBar) + 1)^ := CState;

CvarDef.GameUI_StopProgressBar := FindPattern(HLBase, HLBase_End, @Pattern_GameUI_StopProgressBar, SizeOf(Pattern_GameUI_StopProgressBar), 0);
if Bounds(@CvarDef.GameUI_StopProgressBar, HLBase, HLBase_End, True) then
 PrintSearchError('GameUI_StopProgressBar');
end;

end.
