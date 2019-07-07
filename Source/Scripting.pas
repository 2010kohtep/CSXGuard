unit Scripting;

{$I CSXGuard.inc}

interface

procedure Cmd_Condition;
procedure Cmd_Loop;

implementation

uses CvarDef, HLSDK, MsgAPI, SysUtils, Common;

procedure ParseSubCommand(var S: String);
var
 I: LongWord;
 SubCommand: Boolean;
begin
SubCommand := False;
for I := 1 to Length(S) do
 case S[I] of
  '''':
   if not SubCommand then
    S[I] := '"';
  '"':
   SubCommand := not SubCommand;
 end;
end;

procedure Cmd_Condition; // if cl_updaterate 10 "echo test";
var
 Name, S: String;
 Ptr: cvar_s;
begin
if Engine.Cmd_Argc < 4 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <variable> <value> <command>', [PRINT_LINE_BREAK])
else
 begin
  Name := Engine.Cmd_Argv(1);
  Ptr := Engine.GetCVarPointer(PChar(Name));
  if Ptr = nil then
   Print('Couldn''t find "', Name, '" CVar pointer.')
  else
   if StrIComp(Ptr.Data, Engine.Cmd_Argv(2)) = 0 then
    begin
     if LogDeveloper then
      Print('Condition = True');
     S := Engine.Cmd_Argv(3);
     ParseSubCommand(S);
     Engine.ClientCmd(PChar(S));
    end
   else
    if LogDeveloper then
     Print('Condition = False');
 end;
end;

procedure Cmd_Loop; // loop 5 "echo test"
var
 I, L: LongWord;
 S: String;
begin
if Engine.Cmd_Argc < 3 then
 Print('Syntax: ', LowerCase(Engine.Cmd_Argv(0)), ' <amount> <command>', [PRINT_LINE_BREAK])
else
 begin
  L := StrToIntDef(Engine.Cmd_Argv(1), 0);
  if (L <= 0) or (L > 512) then
   Print('Loop amount is out of bounds.')
  else
   begin
    S := Engine.Cmd_Argv(2);
    ParseSubCommand(S);

    for I := 1 to L do
     Engine.ClientCmd(Pointer(S));
   end;
 end;
end;

end.
