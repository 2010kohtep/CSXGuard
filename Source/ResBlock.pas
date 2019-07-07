unit ResBlock;

{$I CSXGuard.inc}

interface

uses HLSDK;

function IsValidFile(const FileName: PChar): Longint; cdecl;
function CL_ResourceDownload(const Buffer: sizebuf_s; const ResourceName: PChar): Longint; cdecl;
procedure Cmd_MOTD_Write; cdecl;
procedure ResBlock_Init;

implementation

uses CvarDef, SysUtils, MsgAPI, MemSearch, Common;

function CheckFileName(const FileName: PChar): Boolean; // returns False if the file name is not valid
var
 C, C2: Pointer;
 I, L: LongWord;
 FileName_LC: String;
begin
if (FileName <> nil) and (StrLComp(FileName, '!MD5', 4) <> 0) then
 begin
  L := StrLen(FileName);

  if MaxExtensionLength > 0 then
   begin
    C := StrScan(FileName, '.');
    if C = nil then
     begin // no extension
      Result := True;
      Exit;
     end
    else
     begin
      C2 := StrRScan(FileName, '.');
      if (C2 = nil) or (C <> C2) or (L - (Cardinal(C) - Cardinal(FileName) + 1) > MaxExtensionLength) then
       begin
        Result := True;
        Exit;
       end;
     end;
   end;

   if FileExpr_Count > 0 then
    FileName_LC := LowerCase(FileName);

   for I := 1 to FileExpr_Count do
    if not Expr_Process(FileExpr, I, FileName, L, PChar(FileName_LC)) then
     begin
      Result := True;
      Exit;
     end;
 end;

Result := False;
end;

function IsValidFile(const FileName: PChar): Longint; cdecl;
begin
if not Enabled or not OverrideFileCheck then
 Result := IsValidFile_Orig(FileName)
else
 Result := Longint(not CheckFileName(FileName));
end;

function CL_ResourceDownload(const Buffer: sizebuf_s; const ResourceName: PChar): Longint; cdecl;
begin
if not Enabled or not EnableResourceCheck or not CheckFileName(ResourceName) then
 begin
  if LogDeveloper then
   PrintStatus(ResourceName, 'Not blocked (Resource)');
  Result := CL_ResourceDownload_Gate(Buffer, ResourceName);
 end
else                        
 begin
  if LogBlocks then
   PrintStatus(ResourceName, 'Blocked (Resource)');
  Result := Longint(True);
 end;
end;

procedure Cmd_MOTD_Write; cdecl;
begin
if not Enabled or not OverrideFileCheck or not CheckFileName(MOTDFile.Data) then
 Cmd_MOTD_Write_Orig
else
 Print('Invalid motdfile name (', MOTDFile.Data, ').');
end;

procedure ResBlock_Init;
begin
MOTDFile := Engine.GetCVarPointer('motdfile');
if Bounds(MOTDFile, HLBase, HLBase_End) then
 Error('Couldn''t find "motdfile" CVar pointer.');
end;

end.
