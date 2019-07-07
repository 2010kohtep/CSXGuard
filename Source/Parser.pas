unit Parser;

{$I CSXGuard.inc}

interface

uses CvarDef;

procedure ReadConfig;
procedure ProcessCommand(const Command, Value: String; const Host: Byte = HOST_PARSER);

procedure Cmd_Debug_Parser; cdecl;
procedure Cmd_ShowCVars; cdecl;

procedure ShutdownParser;

implementation

uses HLSDK, VoiceExt, MsgAPI, SysUtils, Common;

const
 COMMAND_TABLE_ENTRIES = 34;
 LIST_TABLE_ENTRIES = 8;
 
 CommandTable: array[1..COMMAND_TABLE_ENTRIES] of record Name: String; VarType: (VAR_BOOLEAN = 0, VAR_INTEGER, VAR_FLOAT, VAR_STRING,
                                                         VAR_BYTE, VAR_WORD); Ptr: Pointer; ChangeInit: Boolean; end =
 {v1}          ((Name: 'Enabled'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.Enabled),
                (Name: 'ShowConsole'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.ShowConsole; ChangeInit: True),
                (Name: 'VerifyGameName'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.VerifyGameName; ChangeInit: True),

                (Name: 'LogBlocks'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.LogBlocks),
                (Name: 'LogForwards'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.LogForwards),
                (Name: 'LogDeveloper'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.LogDeveloper),
                (Name: 'BlockCommands'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.BlockCommands),
                (Name: 'BlockCVarQueries'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.BlockCVarQueries),
                (Name: 'BlockMOTD'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.BlockMOTD),

                (Name: 'RemoveInterpolationLimit'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveInterpolationLimit; ChangeInit: True),
                // v1/v2 compatibility
                // (Name: 'RemoveFPSLimit'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveFPSLimit; ChangeInit: True),

                (Name: 'ExtendedForwarding'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.ExtendedForwarding),
                (Name: 'BlockAllForwards'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.BlockAllForwards),
                (Name: 'EnableAllForwards'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.EnableAllForwards),

                (Name: 'RemoveAliasCheck'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveAliasCheck; ChangeInit: True),
                (Name: 'EmulateSpecialAlias'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.EmulateSpecialAlias; ChangeInit: True),
                (Name: 'FastSpecialAlias'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.FastSpecialAlias),

                // overridefilecheck
                (Name: 'MaxExtensionLength'; VarType: VAR_INTEGER; Ptr: @CvarDef.MaxExtensionLength),

                (Name: 'RemoveCVarProtection'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveCVarProtection; ChangeInit: True),
                (Name: 'RemoveCVarValidation'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveCVarValidation; ChangeInit: True),
                (Name: 'RemoveLocalInfoValidation'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.RemoveLocalInfoValidation; ChangeInit: True),
                (Name: 'LocalInfoPatchType'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.LocalInfoPatchType; ChangeInit: True),

                (Name: 'OverrideFrameMSec'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.OverrideFrameMSec; ChangeInit: True),
                (Name: 'FrameMSec_Min'; VarType: VAR_BYTE; Ptr: @CvarDef.FrameMSec_Min),

 {v2}           (Name: 'OverrideMovieRecording'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.OverrideMovieRecording; ChangeInit: True),

                (Name: 'ExtendedVoiceInterface'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.ExtendedVoiceInterface; ChangeInit: True),
                (Name: 'Voice_ConnectionState'; VarType: VAR_BYTE; Ptr: @VoiceExt.Voice_ConnectionState; ChangeInit: True),
                (Name: 'Voice_DefaultPacketSize'; VarType: VAR_WORD; Ptr: @VoiceExt.Voice_DefaultPacketSize; ChangeInit: True),
                (Name: 'Voice_EnableBanManager'; VarType: VAR_BOOLEAN; Ptr: @VoiceExt.Voice_EnableBanManager),

                (Name: 'ShowCommandParameters'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.ShowCommandParameters),
                (Name: 'EnableSteamIDSpoof'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.EnableSteamIDSpoof; ChangeInit: True),

 {v3}           (Name: 'OverrideKeyState'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.OverrideKeyState; ChangeInit: True),
                (Name: 'EnableResourceCheck'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.EnableResourceCheck; ChangeInit: True),

 {v4}           (Name: 'PatchSpawnCommand'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.PatchSpawnCommand; ChangeInit: True),
                (Name: 'ExtendedScripting'; VarType: VAR_BOOLEAN; Ptr: @CvarDef.ExtendedScripting; ChangeInit: True));

 ListTable: array[1..LIST_TABLE_ENTRIES] of record Name: String; ListType: TListType; Data: PPointer; Count: PLongWord; end =
 {v1}          ((Name: 'Commands'; ListType: LIST_STRING; Data: @CvarDef.Commands; Count: @CvarDef.CommandCount),
                (Name: 'BlockFWD_CL'; ListType: LIST_STRING; Data: @CvarDef.BlockFWD_CL; Count: @CvarDef.BlockFWD_CL_Count),
                (Name: 'EnableFWD_CL'; ListType: LIST_STRING; Data: @CvarDef.EnableFWD_CL; Count: @CvarDef.EnableFWD_CL_Count),
                (Name: 'BlockFWD_SV'; ListType: LIST_STRING; Data: @CvarDef.BlockFWD_SV; Count: @CvarDef.BlockFWD_SV_Count),
                (Name: 'EnableFWD_SV'; ListType: LIST_STRING; Data: @CvarDef.EnableFWD_SV; Count: @CvarDef.EnableFWD_SV_Count),
                (Name: 'FileNameFilters'; ListType: LIST_EXPRESSION; Data: @CvarDef.FileExpr; Count: @CvarDef.FileExpr_Count),
                (Name: 'QCC'; ListType: LIST_STRING; Data: @CvarDef.QCC; Count: @CvarDef.QCC_Count),
 {v3}           (Name: 'KeyBinds'; ListType: LIST_STRING; Data: @CvarDef.KeyBinds; Count: @CvarDef.KeyBinds_Count));

var
 PFile, PFile_Entry: Pointer;

function GetToken(const LowerCase: Boolean = True): String; overload;
begin
Result := PChar(CvarDef.COM_Token);
if LowerCase then
 Result := SysUtils.LowerCase(Result);
end;

procedure GetToken(var Str: String; const LowerCase: Boolean = True); overload;
begin
Str := PChar(CvarDef.COM_Token);
if LowerCase then
 Str := SysUtils.LowerCase(Str);
end;

function GetEntryCount(const ListType: TListType): LongWord;
var
 Name, Value: String;
 PFile_Default: Pointer;
begin
PFile_Default := PFile;
if ListType = LIST_EXPRESSION then
 begin
  Result := 0;
  PFile := CvarDef.COM_Parse(PFile);
  Name := GetToken(False);
  while not ((Name = '}') or (PFile = nil)) do
   begin
    PFile := CvarDef.COM_Parse(PFile);
    Value := GetToken(False);
    if (Value = '}') or (PFile = nil) then
     Break;
    Inc(Result);
    PFile := CvarDef.COM_Parse(PFile);
    Name := GetToken(False);
   end;
 end
else
 begin
  Result := 0;
  repeat
   PFile := CvarDef.COM_Parse(PFile);
   Value := GetToken(False);
   Inc(Result);
  until (Value = '}') or (PFile = nil);
  if Result > 0 then
   Dec(Result);
 end;
PFile := PFile_Default;
end;

function ParseList_Expression(var Data: PExprArray; const Count: PLongWord): Boolean;
var
 ExprName, ExprValue: String;
 Index, I, L, Size: LongWord;
begin
Count^ := GetEntryCount(LIST_EXPRESSION);
if Count^ = 0 then
 begin
  Result := True;
  Exit;
 end;

Size := Count^ * SizeOf(TExpression);
GetMem(Data, Size);
COM_FillChar(Data, Size, $0);

Index := 0;

PFile := CvarDef.COM_Parse(PFile);
ExprName := GetToken;

while not ((ExprName = '') or (ExprName = '}') or (PFile = nil)) do
 begin
  PFile := CvarDef.COM_Parse(PFile);
  ExprValue := GetToken(False);
  if (ExprValue = '') or (ExprValue = '}') or (PFile = nil) then
   Break;

  Inc(Index);

  if (StrLComp(PChar(ExprName), 'stricomp', 8) = 0) or (StrLComp(PChar(ExprName), 'strcomp', 7) = 0) then
   begin
    L := Length(ExprValue);
    if L <= MAX_EXPRESSION_LENGTH then
     begin
      if ExprName[4] = 'i' then
       begin
        StrLCopy(@Data[Index].Data, PChar(LowerCase(ExprValue)), L);
        Data[Index].ExprType := EXPR_STRICOMP;
       end
      else
       begin
        StrLCopy(@Data[Index].Data, PChar(ExprValue), L);
        Data[Index].ExprType := EXPR_STRCOMP;
       end;
      Data[Index].Data[L + 1] := Chr($0);
     end
    else
     begin
      Print('ParseList_Expression: Exception name is too long (Index = ', IntToStr(Index), ').');
      Result := False;
      Exit;
     end;      

    I := Pos(',', ExprName);
    if I = 0 then
     begin
      Print('ParseList_Expression: Bad argument delimiter (1) at index ', IntToStr(Index));
      Result := False;
      Exit;
     end;

    ExprName := Copy(ExprName, I + 1, MaxInt);
    I := Pos(',', ExprName);
    if I = 0 then
     begin
      Print('ParseList_Expression: Bad argument delimiter (2) at index ', IntToStr(Index));
      Result := False;
      Exit;
     end;

    if not TryStrToInt(Copy(ExprName, 1, I - 1), Data[Index].CmpOffset) then
     begin
      Print('ParseList_Expression: Bad CmpOffset at index ', IntToStr(Index));
      Result := False;
      Exit;
     end;

    ExprName := Copy(ExprName, I + 1, MaxInt);

    if not TryStrToInt(ExprName, Data[Index].CmpLength) then
     begin
      Print('ParseList_Expression: Bad CmpLength at index ', IntToStr(Index));
      Result := False;
      Exit;
     end;
   end
  else
   if StrLComp(PChar(ExprName), 'strpos', 6) = 0 then // Case-sensitive position search
    begin
     Data[Index].ExprType := EXPR_STRPOS;
     L := Length(ExprValue);
     if L <= MAX_EXPRESSION_LENGTH then
      begin
       StrLCopy(@Data[Index].Data, PChar(ExprValue), L);
       Data[Index].Data[L + 1] := Chr($0);
      end
     else
      begin
       Print('ParseList_Expression: Exception name is too long (Index = ', IntToStr(Index), ').');
       Result := False;
       Exit;
      end;
    end
   else
    if StrLComp(PChar(ExprName), 'stripos', 6) = 0 then // Default position search
     begin
      Data[Index].ExprType := EXPR_STRIPOS;
      L := Length(ExprValue);
      if L <= MAX_EXPRESSION_LENGTH then
       begin
        StrLCopy(@Data[Index].Data, PChar(LowerCase(ExprValue)), L);
        Data[Index].Data[L + 1] := Chr($0);
       end
      else
       begin
        Print('ParseList_Expression: Exception name is too long (Index = ', IntToStr(Index), ').');
        Result := False;
        Exit;
       end;
     end
    else
     if StrLComp(PChar(ExprName), 'strequal', 8) = 0 then
      begin
       Data[Index].ExprType := EXPR_STREQUAL;
       L := Length(ExprValue);
       if L <= MAX_EXPRESSION_LENGTH then
        begin
         StrLCopy(@Data[Index].Data, PChar(ExprValue), L);
         Data[Index].Data[L + 1] := Chr($0);
        end
       else
        begin
         Print('ParseList_Expression: Exception name is too long (Index = ', IntToStr(Index), ').');
         Result := False;
         Exit;
        end;
      end
     else
      if StrLComp(PChar(ExprName), 'exit', 4) = 0 then
       begin
        Data[Index].ExprType := EXPR_EXIT;
        ExprValue := LowerCase(ExprValue);
        if ExprValue = 'false' then
         Data[Index].Data[1] := Chr(0)
        else
         if ExprValue = 'true' then
          Data[Index].Data[1] := Chr(1)
         else
          begin
           Print('ParseList_Expression: Bad argument at (Index = ', IntToStr(Index), ')');
           Result := False;
           Exit;
          end;
       end

     // Add new expressions here 

     else
      begin
       if not (StrLComp(PChar(ExprName), 'striequal', 9) = 0) then
        Print('Unknown expression: "', ExprName, '", expression will be treated as StrIEqual');
       Data[Index].ExprType := EXPR_STRIEQUAL;
       L := Length(ExprValue);
       if L <= MAX_EXPRESSION_LENGTH then
        begin
         StrLCopy(@Data[Index].Data, PChar(LowerCase(ExprValue)), L);
         Data[Index].Data[L + 1] := Chr($0);
        end
       else
        begin
         Print('ParseList_Expression: Exception name is too long (Index = ', IntToStr(Index), ').');
         Result := False;
         Exit;
        end;
      end;

  PFile := CvarDef.COM_Parse(PFile);
  ExprName := GetToken;
 end;

Result := True;
end;

procedure PrintChangeError;
begin
Print('This variable cannot be changed in-game.');
end;

procedure ProcessCommand(const Command, Value: String; const Host: Byte = HOST_PARSER);
var
 I: LongWord;
begin
if (Command = '') or (Value = '') then
 Exit;

for I := 1 to COMMAND_TABLE_ENTRIES do
 with CommandTable[I] do
  if StrIComp(PChar(Name), PChar(Command)) = 0 then
   begin
    if ChangeInit and (Host <> HOST_PARSER) then
     PrintChangeError
    else
     case VarType of
      VAR_BOOLEAN: PBoolean(Ptr)^ := StrToBoolDef(Value, PBoolean(Ptr)^);
      VAR_INTEGER: PLongint(Ptr)^ := StrToIntDef(Value, PLongint(Ptr)^);
      VAR_FLOAT: PSingle(Ptr)^ := StrToFloatDef(Value, PSingle(Ptr)^);
      VAR_STRING: PString(Ptr)^ := Value;
      VAR_BYTE: PByte(Ptr)^ := StrToIntDef(Value, PByte(Ptr)^);
      VAR_WORD: PWord(Ptr)^ := StrToIntDef(Value, PWord(Ptr)^);
      else
       Error('Invalid variable type.');
     end;
    Exit;
   end;

// custom variable handlers

if StrIComp(PChar(Command), 'OverrideFileCheck') = 0 then
 if (Host = HOST_PARSER) or (MOTDFile <> nil) or (@CvarDef.IsValidFile_Orig <> nil) then
  CvarDef.OverrideFileCheck := StrToBoolDef(Value, CvarDef.OverrideFileCheck)
 else
  PrintChangeError
else
 if StrIComp(PChar(Command), 'RemoveFPSLimit') = 0 then // for v1-v2 compatibility (obsolete in v3-v4)
  if Host = HOST_PARSER then
   if StrToBoolDef(Value, False) then
    CvarDef.FPSLimitPatchType := [PATCH_30FPS..PATCH_1000FPS]
   else
    CvarDef.FPSLimitPatchType := []
  else
   PrintChangeError
 else
  if StrIComp(PChar(Command), 'RemoveFPSLimit_30') = 0 then
   if Host = HOST_PARSER then
    if StrToBoolDef(Value, False) then
     Include(CvarDef.FPSLimitPatchType, PATCH_30FPS)
    else
     Exclude(CvarDef.FPSLimitPatchType, PATCH_30FPS)
   else
    PrintChangeError
  else
   if StrIComp(PChar(Command), 'RemoveFPSLimit_100') = 0 then
    if Host = HOST_PARSER then
     if StrToBoolDef(Value, False) then
      Include(CvarDef.FPSLimitPatchType, PATCH_100FPS)
     else
      Exclude(CvarDef.FPSLimitPatchType, PATCH_100FPS)
    else
     PrintChangeError
   else
    if StrIComp(PChar(Command), 'RemoveFPSLimit_1000') = 0 then
     if Host = HOST_PARSER then
      if StrToBoolDef(Value, False) then
       Include(CvarDef.FPSLimitPatchType, PATCH_1000FPS)
      else
       Exclude(CvarDef.FPSLimitPatchType, PATCH_1000FPS)
     else
      PrintChangeError

else
 Print('Unknown command: "', Command, '"');
end;

procedure ParseParameter(const Token: String);
var
 Value: String;
begin
PFile := CvarDef.COM_Parse(PFile);
Value := GetToken(False);
ProcessCommand(Token, Value);
end;

function ParseList_String(var Data: PStringArray; const Count: PLongWord): Boolean;
var
 Value: String;
 L, Index: LongWord;
begin
if Count = nil then
 begin
  Result := False;
  Exit;
 end;

Count^ := GetEntryCount(LIST_DEFAULT);
if Count^ = 0 then
 begin
  Result := True;
  Exit;
 end;

GetMem(Data, Count^ * DEFAULT_COMMAND_LENGTH);
Index := 0;

PFile := CvarDef.COM_Parse(PFile);
GetToken(Value, True);
while not ((Value = '') or (Value = '}') or (PFile = nil)) do
 begin
  Inc(Index);
  L := Length(Value);
  if L <= MAX_STRINGCMD then
   begin
    StrLCopy(@Data[Index], PChar(Value), L);
    Data[Index][L + 1] := Chr($0);
   end
  else
   Print('ParseList_String: String is too long (Index = ', IntToStr(Index), ').');

  PFile := CvarDef.COM_Parse(PFile);
  GetToken(Value, True);
 end;
Result := True;
end;

function ParseList_CRC(var Data: PCRCArray; const Count: PLongWord): Boolean;
var
 Value: String;
 Index: LongWord;
begin
if Count = nil then
 begin
  Result := False;
  Exit;
 end;

Count^ := GetEntryCount(LIST_DEFAULT);
if Count^ = 0 then
 begin
  Result := True;
  Exit;
 end;

GetMem(Data, Count^ shl 2);
Index := 0;

PFile := CvarDef.COM_Parse(PFile);
GetToken(Value, True);
while not ((Value = '') or (Value = '}') or (PFile = nil)) do
 begin
  Inc(Index);
  Data[Index] := CRC32_ProcessString(Value);

  PFile := CvarDef.COM_Parse(PFile);
  GetToken(Value, True);
 end;
Result := True;
end;

function ParseList_Default: Boolean;
begin
repeat
 PFile := CvarDef.COM_Parse(PFile);
until (PByte(CvarDef.COM_Token)^ = Ord('}')) or (PFile = nil);
Result := True;
end;

function ParseList(const Token: String): Boolean;
var
 I: LongWord;
begin
for I := 1 to LIST_TABLE_ENTRIES do
 with ListTable[I] do
  if StrIComp(PChar(Name), PChar(Token)) = 0 then
   begin
    case ListType of
     LIST_STRING: Result := ParseList_String(PStringArray(Data^), Count);
     LIST_CRC: Result := ParseList_CRC(PCRCArray(Data^), Count);
     LIST_EXPRESSION: Result := ParseList_Expression(PExprArray(Data^), Count);
     else Result := ParseList_Default;
    end;
    Exit;
   end;

Print('Unknown list: "', Token, '"');
Result := ParseList_Default;
end;

procedure ReadConfig;
var
 PFile_Backup: Pointer;
 Token: String;
begin
PFile := Engine.COM_LoadFile('..\csxguard.ini', 5, nil);
if PFile = nil then
 begin
  PFile := Engine.COM_LoadFile('csxguard.ini', 5, nil);
  if PFile = nil then
   begin
    EmptyConfig := True;
    Print('', [PRINT_PREFIX]);
    Print('WARNING: Missing "CSXGuard.ini".', 255, 40, 0, [PRINT_LINE_BREAK]);
    Exit;
   end;
 end;

PFile_Entry := PFile;

while not (PFile = nil) do
 begin
  PFile := CvarDef.COM_Parse(PFile);
  PFile_Backup := PFile;
  Token := GetToken(False);
  PFile := CvarDef.COM_Parse(PFile);
  if GetToken(False) = '=' then
   ParseParameter(Token)
  else
   if GetToken(False) = '{' then
    if not ParseList(Token) then
     ParseList_Default // if list parsing has failed, parse it as a default list 
    else
   else
    PFile := PFile_Backup;
 end;

Engine.COM_FreeFile(PFile_Entry);
end;

procedure Cmd_Debug_Parser; cdecl;
var
 I: LongWord;
begin
for I := 1 to CommandCount do
 begin
  Print(Commands[I], [PRINT_LINE_BREAK]);
  Print('', [PRINT_LINE_BREAK]);
 end;

for I := 1 to FileExpr_Count do
 with FileExpr[I] do
  begin
   Print('#' + IntToStr(I) + ': Type = ' + IntToStr(ExprType) + '; CmpOffset = ' + IntToStr(CmpOffset) +
         '; CmpLength = ' + IntToStr(CmpLength) + '; Data = ' + Data, [PRINT_LINE_BREAK]);
   Print('', [PRINT_LINE_BREAK]);
  end;
end;

procedure Cmd_ShowCVars; cdecl;
var
 I: LongWord;
begin
for I := 1 to COMMAND_TABLE_ENTRIES do
 with CommandTable[I] do
  case VarType of
   VAR_BOOLEAN: PrintVariable(Name, PBoolean(Ptr)^);
   VAR_INTEGER: PrintVariable(Name, PLongint(Ptr)^);
   VAR_FLOAT: PrintVariable(Name, PSingle(Ptr)^);
   VAR_STRING: PrintVariable(Name, PString(Ptr)^);
   VAR_BYTE: PrintVariable(Name, PByte(Ptr)^);
   VAR_WORD: PrintVariable(Name, PWord(Ptr)^);   
  end;

PrintVariable('OverrideFileCheck', OverrideFileCheck);
PrintVariable('RemoveFPSLimit_30', PATCH_30FPS in FPSLimitPatchType);
PrintVariable('RemoveFPSLimit_100', PATCH_100FPS in FPSLimitPatchType);
PrintVariable('RemoveFPSLimit_1000', PATCH_1000FPS in FPSLimitPatchType);

Print('', [PRINT_LINE_BREAK]);

for I := 1 to LIST_TABLE_ENTRIES do
 with ListTable[I] do
  Print(Name, ': ', IntToStr(Count^), ' entries', [PRINT_LINE_BREAK]);
end;

procedure ShutdownParser;
var
 I: LongWord;
begin
for I := 1 to LIST_TABLE_ENTRIES do
 FreeMemory(ListTable[I].Data);
end;

end.
