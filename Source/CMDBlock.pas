unit CMDBlock;

{$I CSXGuard.inc}

interface

uses HLSDK;

procedure SVC_StuffText; cdecl;
function IsValidCmd2(const Command: PChar): Boolean; cdecl;
procedure CBuf_AddText_CPacket(const Text: PChar); cdecl;
procedure Cmd_ExecuteString(Text: PChar; Source: cmd_source_t); cdecl;
procedure Cmd_ForwardToServer; cdecl;

implementation

uses CvarDef, MsgAPI, SysUtils, Windows, Common;

procedure PrintCommand(const Command, Status: String; const CommandStr: String = ''); overload;
var
 Str: String;
begin
Print('"', [PRINT_PREFIX]);
if ShowCommandParameters then
 begin
  Str := SysUtils.StringReplace(CommandStr, #$A, #$0, [rfReplaceAll]);
  Print(Str, CMD_COLOR_R, CMD_COLOR_G, CMD_COLOR_B, []);
 end
else
 Print(Command, CMD_COLOR_R, CMD_COLOR_G, CMD_COLOR_B, []);
Print('": ', Status, [PRINT_LINE_BREAK]);
end;

procedure PrintCommand(const Status: String); overload;
begin
PrintCommand(Engine.Cmd_Argv(0), Status, Engine.Cmd_Argv(0) + ' ' + CvarDef.Cmd_Args);
end;

function CheckCommand(const Str: PChar; const CPacket: Boolean = False; const CommandStr: String = ''): Boolean;
var
 I, J: LongWord;
 Command: String;
begin
if CommandCount > 0 then
 Command := LowerCase(Str);

for I := 1 to CommandCount do
 if StrComp(PChar(Command), @Commands[I]) = 0 then
  begin
   if LogBlocks or LogDeveloper then
    PrintCommand(Str, 'Blocked', CommandStr);

   if ExtendedForwarding and (CState^ >= ca_connected) and not CPacket then
    if EnableAllForwards then
     begin
      if LogForwards then
       PrintCommand(Str, '(Forward): Executed', CommandStr);
      Cmd_ForwardToServer_Orig;
     end
    else // only SV commands
     for J := 1 to EnableFWD_SV_Count do
      if StrComp(PChar(Command), @EnableFWD_SV[J]) = 0 then
       begin
        if LogForwards then
         PrintCommand(Str, '(Forward (SV)): Executed', CommandStr);
        Cmd_ForwardToServer_Orig;
        Break;
       end;

   Result := True;
   Exit;
  end;

if LogDeveloper then
 PrintCommand(Str, 'Not blocked', CommandStr);
Result := False;
end;

function IsValidCmd2(const Command: PChar): Boolean; cdecl;
begin
Result := (StrLIComp(Command, 'alias ', 6) <> 0) and (StrPos(Command, 'connect ') = nil);
end;

procedure ExecuteCommand(const Command: PChar);
begin
if CvarDef.IsValidCmd(Command) then
 CvarDef.CBuf_AddText(PChar(Char(CMD_SV_PREFIX) + Command))
else
 Print('Server tried to send invalid command: "', Command, '"', [PRINT_LINE_BREAK]);
end;

function GetCommandType(const Command: PChar): Byte;
begin
if Command = nil then
 Result := CMD_INVALID
else
 if PByte(Command)^ = CMD_SV_PREFIX then
  Result := CMD_SV
 else
  Result := CMD_CL;
end;

procedure SVC_StuffText; cdecl;
var
 Command, Str: String;
 SubCommand: Boolean;
 I, LR: LongWord;
begin
Command := MSG_ReadString;

if Enabled and BlockCommands then
 begin
  SubCommand := False;
  LR := 1;

  if StrScan(PChar(Command), ';') <> nil then
   begin
    for I := 1 to Length(Command) do
     if Command[I] = '"' then
      SubCommand := not SubCommand
     else
      if (Command[I] = ';') and not SubCommand then
       begin
        Str := Copy(Command, LR, I - LR);
        CvarDef.Cmd_TokenizeString_Orig(PChar(Str));
        if not CheckCommand(Engine.Cmd_Argv(0), False, Str) then
         ExecuteCommand(PChar(Str + Chr($A)));
        LR := I + 1;
       end;
    Str := Copy(Command, LR, MaxInt);
    CvarDef.Cmd_TokenizeString_Orig(PChar(Str));
    if not CheckCommand(Engine.Cmd_Argv(0), False, Str) then
     ExecuteCommand(PChar(Str));
    Exit;
   end
  else
   begin
    CvarDef.Cmd_TokenizeString_Orig(PChar(Command));
    if CheckCommand(Engine.Cmd_Argv(0), False, Command) then
     Exit;
   end;
 end;

ExecuteCommand(PChar(Command));
end;

procedure CBuf_AddText_CPacket(const Text: PChar); cdecl;
var
 Command, Str: String;
 SubCommand: Boolean;
 I, LR: LongWord;
begin
if Enabled and BlockCommands then
 begin
  SubCommand := False;
  LR := 1;
  Command := Text;

  if StrScan(PChar(Command), ';') <> nil then
   begin
    for I := 1 to Length(Command) do
     if Command[I] = '"' then
      SubCommand := not SubCommand
     else
      if (Command[I] = ';') and not SubCommand then
       begin
        Str := Copy(Command, LR, I - LR);
        CvarDef.Cmd_TokenizeString_Orig(PChar(Str));
        if not CheckCommand(Engine.Cmd_Argv(0), True, Str) then
         CvarDef.CBuf_AddText(PChar(Str + Chr($A)));
        LR := I + 1;
       end;
    Str := Copy(Command, LR, MaxInt);
    CvarDef.Cmd_TokenizeString_Orig(PChar(Str));
    if not CheckCommand(Engine.Cmd_Argv(0), True, Str) then
     CvarDef.CBuf_AddText(PChar(Str));
    Exit;
   end
  else
   begin
    CvarDef.Cmd_TokenizeString_Orig(PChar(Command));
    if CheckCommand(Engine.Cmd_Argv(0), True, Command) then
     Exit;
   end;
 end;

CvarDef.CBuf_AddText(Text);
end;

procedure Cmd_ExecuteString(Text: PChar; Source: cmd_source_t); cdecl;
var
 Command: String;
 I: LongWord;
 CommandType: Byte;
begin
CommandType := GetCommandType(Text);
if CommandType = CMD_SV then
 Inc(Cardinal(Text), SizeOf(Char));

Cmd_LastCmdType := CommandType;

Cmd_Processing := True;
Cmd_ExecuteString_Gate(Text, Source);
Cmd_Processing := False;

if Engine.Cmd_Argc < 1 then
 Exit;

if Enabled and ExtendedForwarding and not Cmd_AlreadyForwarded and (CState^ >= ca_connected) then
 begin
  if EnableAllForwards then
   begin
    if LogForwards then
     PrintCommand(Engine.Cmd_Argv(0), '(Forward): Executed', Text);
    Cmd_ForwardToServer_Orig;
    Exit;
   end;

  if CommandType = CMD_INVALID then
   begin
    PrintCommand(Engine.Cmd_Argv(0), '(Forward): Invalid command', Text);
    Exit;
   end;

  if CommandType = CMD_CL then
   begin
    if EnableFWD_CL_Count > 0 then
     Command := LowerCase(Engine.Cmd_Argv(0));

    for I := 1 to EnableFWD_CL_Count do
     if StrComp(PChar(Command), @EnableFWD_CL[I]) = 0 then
      begin
       if LogForwards then
        PrintCommand(Engine.Cmd_Argv(0), '(Forward (CL)): Executed', Text);
       Cmd_ForwardToServer_Orig;
       Exit;
      end;

    if LogForwards and LogDeveloper then
     PrintCommand(Engine.Cmd_Argv(0), '(Forward (CL)): Not executed', Text);
   end
  else
   if CommandType = CMD_SV then
    begin
     if EnableFWD_SV_Count > 0 then
      Command := LowerCase(Engine.Cmd_Argv(0));

     for I := 1 to EnableFWD_SV_Count do
      if StrComp(PChar(Command), @EnableFWD_SV[I]) = 0 then
       begin
        if LogForwards then
         PrintCommand(Engine.Cmd_Argv(0), '(Forward (SV)): Executed', Text);
        Cmd_ForwardToServer_Orig;
        Exit;
       end;

     if LogForwards and LogDeveloper then
      PrintCommand(Engine.Cmd_Argv(0), '(Forward (SV)): Not executed', Text)
    end;
 end
else
 if Cmd_AlreadyForwarded then
  begin
   Cmd_AlreadyForwarded := False;
   if LogForwards and LogDeveloper then
    if CommandType = CMD_SV then
     PrintCommand(Engine.Cmd_Argv(0), '(Forward (SV)): Already forwarded', Text)
    else
     PrintCommand(Engine.Cmd_Argv(0), '(Forward (CL)): Already forwarded', Text);
  end;
end;

procedure Cmd_ForwardToServer; cdecl;
var
 Command: String;
 I: LongWord;
begin
if Enabled and ExtendedForwarding and Cmd_Processing and (Engine.Cmd_Argc >= 1) then
 begin
  Cmd_AlreadyForwarded := True;

  if BlockAllForwards then
   begin
    if LogForwards then
     PrintCommand('(Forward): Blocked');
    Exit;
   end;

  if Cmd_LastCmdType = CMD_CL then
   begin
    if BlockFWD_CL_Count > 0 then
     Command := LowerCase(Engine.Cmd_Argv(0));

    for I := 1 to BlockFWD_CL_Count do
     if StrComp(PChar(Command), @BlockFWD_CL[I]) = 0 then
      begin
       if LogForwards then
        PrintCommand('(Forward (CL)): Blocked');
       Exit;
      end;

    if LogForwards and LogDeveloper then
     PrintCommand('(Forward (CL)): Not blocked');
   end
  else
   if Cmd_LastCmdType = CMD_SV then
    begin
     if BlockFWD_SV_Count > 0 then
      Command := LowerCase(Engine.Cmd_Argv(0));

     for I := 1 to BlockFWD_SV_Count do
      if StrComp(PChar(Command), @BlockFWD_SV[I]) = 0 then
       begin
        if LogForwards then
         PrintCommand('(Forward (SV)): Blocked');
        Exit;
       end;

     if LogForwards and LogDeveloper then
      PrintCommand('(Forward (SV)): Not blocked');       
    end
   else
    begin
     if LogForwards then
      PrintCommand('(Forward): Invalid command');
     Exit;
    end;
 end;

Cmd_AlreadyForwarded := True;
Cmd_ForwardToServer_Orig;
end;

end.
