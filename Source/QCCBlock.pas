unit QCCBlock;

{$I CSXGuard.inc}

interface

procedure SVC_SendCvarValue; cdecl;
procedure SVC_SendCvarValue2; cdecl;

implementation

uses CvarDef, MsgAPI, SysUtils, Common;

procedure QCC_Print(const CVar, Status: String; const IsQCC2: Boolean = False);
begin
if IsQCC2 then
 Print('QCC2 "', [PRINT_PREFIX])
else
 Print('QCC "', [PRINT_PREFIX]);
Print(CVar, CMD_COLOR_R, CMD_COLOR_G, CMD_COLOR_B, []);
Print('": ', Status, [PRINT_LINE_BREAK]);
end;

procedure SVC_SendCvarValue; cdecl;
var
 Name, NameLC: String;
 I: LongWord;
begin
MSG_SaveReadCount;
Name := MSG_ReadString;

if Enabled and BlockCVarQueries then
 begin
  if QCC_Count = 0 then
   begin
    if LogBlocks or LogDeveloper then
     QCC_Print(Name, 'Blocked');
    Exit;
   end;

  NameLC := LowerCase(Name);
  for I := 1 to QCC_Count do
   if StrComp(PChar(NameLC), @QCC[I]) = 0 then
    begin
     if LogBlocks or LogDeveloper then
      QCC_Print(Name, 'Blocked');
     Exit;
    end;

  if LogDeveloper then
   QCC_Print(Name, 'Not blocked');
 end;

MSG_RestoreReadCount;
SVC_SendCvarValue_Orig;
end;

procedure SVC_SendCvarValue2; cdecl;
var
 Name, NameLC: String;
 I: LongWord;
begin
MSG_SaveReadCount;
MSG_ReadLong;
Name := MSG_ReadString;

if Enabled and BlockCVarQueries then
 begin
  if QCC_Count = 0 then
   begin
    if LogBlocks or LogDeveloper then
     QCC_Print(Name, 'Blocked', True);
    Exit;
   end;

  NameLC := LowerCase(Name);
  for I := 1 to QCC_Count do
   if StrComp(PChar(NameLC), @QCC[I]) = 0 then
    begin
     if LogBlocks or LogDeveloper then
      QCC_Print(Name, 'Blocked', True);
     Exit;
    end;

  if LogDeveloper then
   QCC_Print(Name, 'Not blocked', True);
 end;

MSG_RestoreReadCount;
SVC_SendCvarValue2_Orig;
end;

end.
