unit VoiceExt;

{$I CSXGuard.inc}

interface

uses HLSDK;

procedure VX_Init;
procedure VX_Debug;
procedure SVC_VoiceInit; cdecl;
procedure SVC_VoiceData; cdecl;

const
 VOICE_BYTE_RATE = 16000;

type
 PVoiceBanEntry = ^TVoiceBanEntry;
 TVoiceBanEntry = record
  UserID: LongWord;
  Banned: Boolean;
 end;
 
var
 Voice_RecordToFile: cvar_s = nil;
 Voice_InputFromFile: cvar_s = nil;
 
 Voice_RecordStart: HLSDK.Voice_RecordStart = nil;
 Voice_IsRecording: HLSDK.Voice_IsRecording = nil;
 Voice_RecordStop: HLSDK.Voice_RecordStop = nil;
 CL_SendVoicePacket: HLSDK.CL_SendVoicePacket = nil;
 Voice_GetCompressedData_Orig: HLSDK.Voice_GetCompressedData = nil;
 Voice_GetCompressedData_Gate: HLSDK.Voice_GetCompressedData = nil;

 Cmd_VoiceRecord_Start: cmd_s = nil;
 Cmd_VoiceRecord_Stop: cmd_s = nil;

 CurrentMicInputByte: PLongWord = nil;
 TotalMicInputBytes: PLongWord = nil;
 MicInputFileData: PPointer = nil;
 VoiceRecording: PBoolean = nil;

 // custom
 Voice_InputFile: cvar_s = nil;
 Voice_MicData: cvar_s = nil;
 Voice_Decompressed: cvar_s = nil;
 Voice_LoopInput: cvar_s = nil;
 Voice_StopInput: cvar_s = nil;

 Voice_ConnectionState: Byte = 5;
 Voice_DefaultPacketSize: Word = 2048;
 Voice_EnableBanManager: Boolean = True;

 Voice_BannedPlayers: array[1..MAX_PLAYERS] of TVoiceBanEntry;

implementation

uses Windows, CvarDef, MsgAPI, MemSearch, SysUtils, Detours, Common;

procedure VX_Record_Start; cdecl;
var
 UncompressedFile, DecompressedFile, MicInputFile: PChar;
begin
if Byte(CState^) >= Voice_ConnectionState then
 begin
  if Voice_RecordToFile.Value >= 1 then
   if (Voice_MicData.Data <> '') and (Voice_Decompressed.Data <> '') then
    begin
     UncompressedFile := Voice_MicData.Data;
     DecompressedFile := Voice_Decompressed.Data;
     if CheckRelativePath(UncompressedFile) or CheckRelativePath(DecompressedFile) then
      begin
       Print('Relative pathnames are not allowed.');
       Exit;
      end;
    end
   else
    begin
     UncompressedFile := 'voice_micdata.wav';
     DecompressedFile := 'voice_decompressed.wav';
    end
  else
   begin
    UncompressedFile := nil;
    DecompressedFile := nil;
   end;

  if Voice_InputFromFile.Value >= 1 then
   if Voice_InputFile.Data <> '' then
    MicInputFile := Voice_InputFile.Data
   else
    MicInputFile := 'voice_input.wav'
  else
   MicInputFile := nil;

  if CheckRelativePath(MicInputFile) then
   begin
    Print('Relative pathnames are not allowed.');
    Exit;
   end;

  Voice_RecordStart(UncompressedFile, DecompressedFile, MicInputFile);
 end
else
 Print('Recording cannot be started now.');
end;

procedure VX_Record_Stop; cdecl;
begin
if Byte(CState^) >= Voice_ConnectionState then
 if Voice_IsRecording then
  begin
   CL_SendVoicePacket(1);
   Voice_RecordStop;
  end
 else
  if not KeyStateActive then
   Print('Currently not recording.')
 else
else
 if not KeyStateActive then
  Print('Recording cannot be stopped now.');
end;

procedure SVC_VoiceInit; cdecl;
var
 I, Count: LongWord;
begin
if CState^ <> ca_uninitialized then
 if LogDeveloper then
  Print('Tried to send SVC_VoiceInit at CState = ', IntToStr(Byte(CState^)), '; update ignored.')
 else
else
 begin
  Count := 0;
  for I := 1 to MAX_PLAYERS do
   begin
    if Voice_BannedPlayers[I].Banned then
     Inc(Count);
    Voice_BannedPlayers[I].Banned := False;
    Voice_BannedPlayers[I].UserID := 0;
   end;
  if LogDeveloper and (Count > 0) then
   Print('Unbanned ', IntToStr(Count), ' players');
 end;

SVC_VoiceInit_Orig;
end;

procedure SVC_VoiceData; cdecl;
var
 Index: Byte;
 Size: Word;
begin
if not Enabled or not Voice_EnableBanManager then
 begin
  SVC_VoiceData_Orig;
  Exit;
 end;

MSG_SaveReadCount;
Index := MSG_ReadByte + 1;
if Voice_BannedPlayers[Index].Banned and (Voice_BannedPlayers[Index].UserID = Cardinal(Studio.PlayerInfo(Index - 1).UserID)) then
 begin
  Size := MSG_ReadShort;
  Inc(MSG_ReadCount^, Size);
  if LogDeveloper then
   Print('VoiceData from banned player; Size = ', IntToStr(Size), '.');
  Exit;
 end;

MSG_RestoreReadCount;
SVC_VoiceData_Orig;
end;

procedure VX_AddBan(Index: Byte; UserID: LongWord);
begin
if Engine.EventAPI.EV_IsLocal(Index - 1) = 1 then
 Print('Couldn''t ban local player.')
else
 begin
  Voice_BannedPlayers[Index].Banned := True;
  Voice_BannedPlayers[Index].UserID := UserID;
  Print('Done.');
 end;
end;

procedure VX_RemoveBan(Index: Byte);
begin
Voice_BannedPlayers[Index].Banned := False;
Voice_BannedPlayers[Index].UserID := 0;
Print('Done.');
end;

procedure VX_BanList;
var
 I, Count: Byte;
begin
if not Voice_EnableBanManager then
 begin
  Print('Voice ban manager is disabled.');
  Exit;
 end;

Count := 0;

for I := 1 to MAX_PLAYERS do
 if Voice_BannedPlayers[I].Banned then
  begin
   Print('#', IntToStr(I), ': ', IntToStr(Voice_BannedPlayers[I].UserID));
   Inc(Count);
  end;

Print(IntToStr(Count), ' total players');
end;

procedure VX_ClearBanList;
var
 I: Byte;
begin
if not Voice_EnableBanManager then
 begin
  Print('Voice ban manager is disabled.');
  Exit;
 end;

for I := 1 to MAX_PLAYERS do
 begin
  Voice_BannedPlayers[I].Banned := False;
  Voice_BannedPlayers[I].UserID := 0;
 end;

Print('Done.');
end;

procedure VX_Ban;
var
 Str: PChar;
 PInfo: player_info_s;
 Index: Longint;
 I: Byte;
begin
if not Voice_EnableBanManager then
 begin
  Print('Voice ban manager is disabled.');
  Exit;
 end;

if Engine.Cmd_Argc < 2 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <name/#index>')
else
 begin
  Str := Engine.Cmd_Argv(1);
  if (Str = nil) or (Str = '') then
   Print('Invalid parameter.')
  else
   if PByte(Str)^ = Ord('#') then // Index
    if not TryStrToInt(PChar(Cardinal(Str) + 1), Index) or not (Byte(Index) in [1..MAX_PLAYERS]) then
     Print('Invalid player index.')
    else
     begin
      PInfo := Studio.PlayerInfo(Index - 1);
      if PInfo = nil then
       Print('Invalid player index.')
      else
       if PInfo.UserID = 0 then
        Print('Invalid player index.')
       else
        VX_AddBan(Byte(Index), PInfo.UserID);
     end
   else // Name
    begin
     for I := 0 to MAX_PLAYERS - 1 do
      begin
       PInfo := Studio.PlayerInfo(I);
       if (PInfo <> nil) and (StrIComp(Str, @PInfo.Name) = 0) then
        begin
         VX_AddBan(I + 1, Studio.PlayerInfo(I).UserID);
         Exit;
        end;
      end;
     Print('Couldn''t find specified player.');
    end;
 end;
end;

procedure VX_Unban;
var
 Str: PChar;
 Index: Longint;
 I: Byte;
 PInfo: player_info_s;
begin
if not Voice_EnableBanManager then
 begin
  Print('Voice ban manager is disabled.');
  Exit;
 end;

if Engine.Cmd_Argc < 2 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <name/#index>')
else
 begin
  Str := Engine.Cmd_Argv(1);
  if (Str = nil) or (Str = '') then
   Print('Invalid parameter.')
  else
   if PByte(Str)^ = Ord('#') then // Index
    if not TryStrToInt(PChar(Cardinal(Str) + 1), Index) or not (Byte(Index) in [1..MAX_PLAYERS]) then
     Print('Invalid player index.')
    else
     VX_RemoveBan(Byte(Index))
   else // Name
    begin
     for I := 0 to MAX_PLAYERS - 1 do
      begin
       PInfo := Studio.PlayerInfo(I);
       if (PInfo <> nil) and (StrIComp(Str, @PInfo.Name) = 0) then
        begin
         VX_RemoveBan(I + 1);
         Exit;
        end;
      end;
     Print('Couldn''t find specified player.');
    end;
 end;
end;

procedure VX_Debug;
begin
PrintAddress('Voice_RecordStart', @Voice_RecordStart);
PrintAddress('Voice_RecordStop', @Voice_RecordStop);
PrintAddress('Voice_IsRecording', @Voice_IsRecording);
PrintAddress('CL_SendVoicePacket', @CL_SendVoicePacket);
PrintAddress('Voice_GetCompressedData', @Voice_GetCompressedData_Orig);

PrintAddress('CurrentMicInputByte', CurrentMicInputByte);
PrintAddress('TotalMicInputBytes', TotalMicInputBytes);

PrintAddress('SVC_VoiceInit', @CvarDef.SVC_VoiceInit_Orig);
PrintAddress('SVC_VoiceData', @CvarDef.SVC_VoiceData_Orig);
end;

procedure VX_Find_Voice_RecordStart;
begin
Cmd_VoiceRecord_Start := CommandByName('+voicerecord');
CheckCallback(Cmd_VoiceRecord_Start);

VoiceExt.Voice_RecordStart := Pointer(Absolute(Cardinal(@Cmd_VoiceRecord_Start.Callback) + 67));
if Bounds(@VoiceExt.Voice_RecordStart, HLBase, HLBase_End, True) then
 Error('Couldn''t find Voice_RecordStart pointer.');

VoiceExt.TotalMicInputBytes := PPointer(Cardinal(@VoiceExt.Voice_RecordStart) + 62 - Cardinal(SW))^;
if Bounds(VoiceExt.TotalMicInputBytes, HLBase, HLBase_End) then
 Error('Couldn''t find TotalMicInputBytes pointer.');
 
VoiceExt.CurrentMicInputByte := PPointer(Cardinal(@VoiceExt.Voice_RecordStart) + 82 - Cardinal(SW))^;
if Bounds(VoiceExt.CurrentMicInputByte, HLBase, HLBase_End) then
 Error('Couldn''t find CurrentMicInputByte pointer.');
end;

procedure VX_Find_Voice_RecordStop;
begin
Cmd_VoiceRecord_Stop := CommandByName('-voicerecord');
CheckCallback(Cmd_VoiceRecord_Stop);

VoiceExt.Voice_IsRecording := Pointer(Absolute(Cardinal(@Cmd_VoiceRecord_Stop.Callback) + 10));
if Bounds(@VoiceExt.Voice_IsRecording, HLBase, HLBase_End, True) then
 Error('Couldn''t find Voice_IsRecording pointer.');

VoiceExt.CL_SendVoicePacket := Pointer(Absolute(Cardinal(@Cmd_VoiceRecord_Stop.Callback) + 21));
if Bounds(@VoiceExt.CL_SendVoicePacket, HLBase, HLBase_End, True) then
 Error('Couldn''t find CL_SendVoicePacket pointer.');

VoiceExt.Voice_RecordStop := Pointer(Absolute(Cardinal(@Cmd_VoiceRecord_Stop.Callback) + 29));
if Bounds(@VoiceExt.Voice_RecordStop, HLBase, HLBase_End, True) then
 Error('Couldn''t find Voice_RecordStop pointer.');
end;

procedure VX_Find_Voice_GetCompressedData;
begin
VoiceExt.Voice_GetCompressedData_Orig := Pointer(Absolute(Cardinal(@VoiceExt.CL_SendVoicePacket) + 45 + Cardinal(SW)));
if Bounds(@VoiceExt.Voice_GetCompressedData_Orig, HLBase, HLBase_End, True) then
 Error('Couldn''t find Voice_GetCompressedData pointer.');
end;

procedure VX_Find_MicInputFileData;
begin
VoiceExt.MicInputFileData := PPointer(Cardinal(@VoiceExt.Voice_RecordStop) + 1)^;
if Bounds(VoiceExt.MicInputFileData, HLBase, HLBase_End) then
 Error('Couldn''t find MicInputFileData pointer.');
end;

procedure VX_Find_VoiceRecording;
begin
VoiceExt.VoiceRecording := PPointer(Cardinal(@VoiceExt.Voice_IsRecording) + 1)^;
if Bounds(VoiceExt.VoiceRecording, HLBase, HLBase_End) then
 Error('Couldn''t find VoiceRecording pointer.');
end;

procedure Patch_CL_SendVoicePacket;
var
 Protect: LongWord;
 Addr: Pointer;
begin
// 1: tweak the buffer size on the stack (Voice_DefaultPacketSize)

Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 7 - Cardinal(SW) * 2);
if PWord(Cardinal(Addr) - 2)^ <> $EC81 then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 1.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
PCardinal(Addr)^ := Cardinal(Voice_DefaultPacketSize);
VirtualProtect(Addr, 4, Protect, Protect);

// 2: replace the default connection state (Voice_ConnectionState)

Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 13 + Cardinal(SW) * 4);
if PWord(Cardinal(Addr) - 2)^ <> $F883 then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 2.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := Voice_ConnectionState;
VirtualProtect(Addr, 1, Protect, Protect);

// 3: tweak the offset that is required to reach the saved buffer (Voice_DefaultPacketSize)

Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 29 + Cardinal(SW) * 5);
if ((not SW) and ((PWord(Cardinal(Addr) - 2)^ <> $2484) or (PByte(Cardinal(Addr) - 3)^ <> $8B))) or
   (SW and (PWord(Cardinal(Addr) - 2)^ <> $8D8D)) then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 3.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
if not SW then
 PCardinal(Addr)^ := Cardinal(Voice_DefaultPacketSize) + 8
else
 PCardinal(Addr)^ := -Cardinal(Voice_DefaultPacketSize);
VirtualProtect(Addr, 4, Protect, Protect);

// 4: tweak the actial buffer size (passed to Voice_GetCompressedData) (Voice_DefaultPacketSize)

Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 39 + Cardinal(SW));
if PWord(Cardinal(Addr) - 2)^ <> $6850 then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 4.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
PCardinal(Addr)^ := Cardinal(Voice_DefaultPacketSize);
VirtualProtect(Addr, 4, Protect, Protect);

// 5: tweak the buffer size on the stack (Voice_DefaultPacketSize)

Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 126 - Cardinal(SW) * 19);
if ((not SW) and (PWord(Cardinal(Addr) - 2)^ <> $C481)) or
   (SW and (PWord(Cardinal(Addr) - 2)^ <> $958D)) then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 5.');

VirtualProtect(Addr, 4, PAGE_EXECUTE_READWRITE, Protect);
if not SW then
 PCardinal(Addr)^ := Cardinal(Voice_DefaultPacketSize)
else
 PCardinal(Addr)^ := -Cardinal(Voice_DefaultPacketSize);
VirtualProtect(Addr, 4, Protect, Protect);

// 6: change the jump type (Voice_ConnectionState)
Addr := Pointer(Cardinal(@CL_SendVoicePacket) + 15 + Cardinal(SW) * 3);
if ((not SW) and (PWord(Cardinal(Addr) - 1)^ <> $7556)) or
   (SW and (PByte(Addr)^ <> $75)) then
 Error('Couldn''t find CL_SendVoicePacket patch pattern 6.');

VirtualProtect(Addr, 1, PAGE_EXECUTE_READWRITE, Protect);
PByte(Addr)^ := $7C;
VirtualProtect(Addr, 1, Protect, Protect);

// we're done here
end;

function Voice_GetCompressedData(const Buffer: Pointer; Size: LongWord; Final: LongWord): LongWord; cdecl;
var
 CurrentMicInputByte, TotalMicInputBytes: LongWord;
begin
CurrentMicInputByte := VoiceExt.CurrentMicInputByte^;
TotalMicInputBytes := VoiceExt.TotalMicInputBytes^;

if (MicInputFileData <> nil) and (TotalMicInputBytes > 0) and (CurrentMicInputByte >= TotalMicInputBytes) then
 if Voice_LoopInput.Value >= 1 then
  VoiceExt.CurrentMicInputByte^ := 0
 else
  if Voice_StopInput.Value >= 1 then
   Voice_RecordStop;

Result := Voice_GetCompressedData_Gate(Buffer, Size, Final);
end;

function GetInputTime(Pos: LongWord): String;
var
 I, J: LongWord;
begin
Pos := Pos div VOICE_BYTE_RATE;

I := Pos div 60;
J := Pos mod 60;

if I >= 10 then
 Result := IntToStr(I)
else
 Result := '0' + IntToStr(I);

if J >= 10 then
 Result := Result + ':' + IntToStr(J)
else
 Result := Result + ':0' + IntToStr(J);
end;

function GetInputPos(Time: String): LongWord;
var
 I, J, L: LongWord;
begin
for I := 1 to Length(Time) do
 if Time[I] = ' ' then
  Delete(Time, I, 1);

I := Pos(':', Time);
if (I = 0) or (Time = '') then
 begin
  Result := StrToIntDef(Time, 0) * VOICE_BYTE_RATE;
  Exit;
 end
else
 if I = 1 then
  begin
   Result := StrToIntDef(Copy(Time, 2, MaxInt), 0) * VOICE_BYTE_RATE;
   Exit;
  end
 else
  begin
   L := Length(Time);
   J := StrToIntDef(Copy(Time, I + 1, L - I), 0);
   I := StrToIntDef(Copy(Time, 1, I - 1), 0);
   Result := (I * 60 + J) * VOICE_BYTE_RATE;
  end;
end;

procedure VX_InputInfo;
begin
if not VoiceRecording^ then
 Print('Currently not recording.')
else
 if MicInputFileData^ = nil then
  Print('The input file data is empty.')
 else
  Print('CurrentMicInputByte = ' + IntToStr(CurrentMicInputByte^) +
        '; TotalMicInputBytes = ' + IntToStr(TotalMicInputBytes^) +
        '; CurrentInputTime = ' + GetInputTime(CurrentMicInputByte^) +
        '; TotalInputTime = ' + GetInputTime(TotalMicInputBytes^));
end;

procedure VX_SeekInput;
var
 I: LongWord;
begin
if Engine.Cmd_Argc < 2 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <time>')
else
 if not VoiceRecording^ then
  Print('Currently not recording.')
 else
  if (MicInputFileData^ = nil) or (TotalMicInputBytes^ = 0) then
   Print('The input file data is empty.')
  else
   begin
    I := GetInputPos(Engine.Cmd_Argv(1));
    if I <= TotalMicInputBytes^ then
     CurrentMicInputByte^ := I
    else
     Print('Requested position exceeds avaliable byte count.')
   end;
end;

procedure VX_Init;
begin
VX_Find_Voice_RecordStart;
VX_Find_Voice_RecordStop;
VX_Find_Voice_GetCompressedData;
VX_Find_MicInputFileData;
VX_Find_VoiceRecording;

Voice_GetCompressedData_Gate := Detour(@Voice_GetCompressedData_Orig, @Voice_GetCompressedData, 5 + Cardinal(SW) * 3);

Patch_CL_SendVoicePacket;

Engine.AddCommand('voice_debug', @VX_Debug);

Voice_InputFile := Engine.RegisterVariable('voice_inputfile', 'voice_input.wav', 0);
Voice_MicData := Engine.RegisterVariable('voice_micdata', 'voice_micdata.wav', 0);
Voice_Decompressed := Engine.RegisterVariable('voice_decompressed', 'voice_decompressed.wav', 0);
Voice_LoopInput := Engine.RegisterVariable('voice_loopinput', '0', 0);
Voice_StopInput := Engine.RegisterVariable('voice_stopinput', '0', 0);

Voice_RecordToFile := Engine.GetCVarPointer('voice_recordtofile');
if Bounds(Voice_RecordToFile, HLBase, HLBase_End) then
 Error('Couldn''t find "voice_recordtofile" CVar pointer.');
 
Voice_InputFromFile := Engine.GetCVarPointer('voice_inputfromfile');
if Bounds(Voice_InputFromFile, HLBase, HLBase_End) then
 Error('Couldn''t find "voice_inputfromfile" CVar pointer.');

Cmd_VoiceRecord_Start.Callback := @VX_Record_Start;
Cmd_VoiceRecord_Stop.Callback := @VX_Record_Stop;

Engine.AddCommand('voice_banlist', @VX_BanList);
Engine.AddCommand('voice_clearbanlist', @VX_ClearBanList);
Engine.AddCommand('voice_ban', @VX_Ban);
Engine.AddCommand('voice_unban', @VX_Unban);

Engine.AddCommand('voice_inputinfo', @VX_InputInfo);
Engine.AddCommand('voice_seekinput', @VX_SeekInput);

if LogDeveloper then
 Print('Voice initialized.');
end;

end.