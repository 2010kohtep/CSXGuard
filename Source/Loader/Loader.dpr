library Loader;

{$I Loader.inc}

uses Windows;

const
 EXTENSION_SIZE = 3;
 Extension: array[1..EXTENSION_SIZE] of Char = 'dll';
 
var
 Name: packed array[1..MAX_PATH] of Char;

function GetDLLName: Boolean;
var
 I: LongWord;
begin
GetModuleFileName(HInstance, @Name, SizeOf(Name));

for I := SizeOf(Name) - 1 downto 0 do
 if PByte(Cardinal(@Name) + I)^ = Ord('.') then
  begin
   if SizeOf(Name) - I <= EXTENSION_SIZE then
    Result := False
   else
    begin
     Move(Extension, Pointer(Cardinal(@Name) + I + 1)^, EXTENSION_SIZE);
     Result := True;
    end;
   Exit;
  end;

Result := False;
end;

begin
if GetDLLName then
 LoadLibrary(@Name);
end.
