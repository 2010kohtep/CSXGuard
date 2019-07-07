unit MSGBlock;

{$I CSXGuard.inc}

interface

function SVC_MOTD(const Name: PChar; Size: Longint; const Buffer: Pointer): Longint; cdecl;

implementation

uses CvarDef, MsgAPI;

procedure MSG_Print(const Name, Status: String);
begin
Print('', [PRINT_PREFIX]);
Print(Name, CMD_COLOR_R, CMD_COLOR_G, CMD_COLOR_B, []);
Print(': ', Status, [PRINT_LINE_BREAK]);
end;

function SVC_MOTD(const Name: PChar; Size: Longint; const Buffer: Pointer): Longint; cdecl;
begin
if Enabled and BlockMOTD then
 begin
  if (LogBlocks or LogDeveloper) and (Buffer <> nil) and (PByte(Buffer)^ = $1) then
   MSG_Print('MOTD', 'Blocked');
  Result := 0;
 end
else
 begin
  if LogDeveloper and (Buffer <> nil) and (PByte(Buffer)^ = $1) then
   MSG_Print('MOTD', 'Not blocked');
  Result := SVC_MOTD_Orig(Name, Size, Buffer);
 end;
end;

end.
