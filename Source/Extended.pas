unit Extended;

{$I CSXGuard.inc}

interface

procedure CL_Move_Patch; cdecl;
function Cmd_Argv_Patch(Index: Longint): PChar; cdecl;
procedure Key_Event_Patch(Key, Down: Longint); cdecl;
procedure Cmd_Spawn; cdecl;

implementation

uses CvarDef, HLSDK, SysUtils, MsgAPI, Common;

procedure CL_Move_Patch; cdecl;
asm
 push ebx
 mov bl, byte ptr [FrameMSec_Min]

 test bl, bl
 je @SetDefault

 cmp al, bl
 jl @SetClamp

 jmp @Return

@SetClamp:
 mov al, bl
 jmp @Return

@SetDefault:
 xor al, al

@Return:
 pop ebx
 jmp CL_Move_Patch_Gate
end;

function Cmd_Argv_Patch(Index: Longint): PChar; cdecl;
begin
if Engine.DemoAPI.IsPlayingBack = 0 then
 Print('Timescale will not be changed.', [PRINT_LINE_BREAK]);

Result := Cmd_Argv_Patch_Gate(Index);
end;

procedure Key_Event_Patch(Key, Down: Longint); cdecl;
var
 B: Boolean;
 I, J: LongWord;
 S: PChar;
 S2: String;
begin
if Key = Low(Byte) then
 KeyStateActive := True;

B := False;
J := Key + 1;
S := KeyBindings[J];

if (S <> nil) and (PByte(S)^ = Ord('+')) then
 begin
  S2 := LowerCase(S);
  for I := 1 to KeyBinds_Count do
   if StrComp(@KeyBinds[I], Pointer(S2)) = 0 then
    begin
     if LogDeveloper then
      PrintStatus(PChar(S2), 'Blocked (KeyState)');
     B := True;
     Break;
    end;

  if KeyShift[J] <> LongWord(Key) then // there is a separate binding for [Shift] + [Key]
   begin
    S := KeyBindings[KeyShift[J] + 1];
    if (S <> nil) and (PByte(S)^ = Ord('+')) then
     begin
      S2 := LowerCase(S);
      for I := 1 to KeyBinds_Count do
       if StrComp(@KeyBinds[I], Pointer(S2)) = 0 then
        begin
         if LogDeveloper then
          PrintStatus(PChar(S2), 'Blocked (KeyState/Shift)');
         Exit;
        end;
     end;
   end;
   
  if B then
   Exit;
 end;

Engine.Key_Event(Key, Down);

if Key = High(Byte) then
 KeyStateActive := False;
end;

procedure Cmd_Spawn; cdecl;
begin
if Cmd_Source^ <> 1 then
 Cmd_Spawn_Orig
else
 if Engine.Cmd_Argc = 3 then
  Print('Spawn is not valid from the console.', [PRINT_LINE_BREAK])
 else
  Print('Spawn is not valid.', [PRINT_LINE_BREAK]);
end;

end.
