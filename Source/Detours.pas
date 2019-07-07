unit Detours;

{$I CSXGuard.inc}

interface

procedure WriteNOPs(const BaseAddr: Pointer; Count: LongWord);
function Detour(const BaseAddr, NewAddr: Pointer; const CodeLength: LongWord = 5): Pointer;

implementation

uses Windows, MemSearch, Common;

procedure WriteNOPs(const BaseAddr: Pointer; Count: LongWord);
begin
COM_FillChar(BaseAddr, Count, $90);
end;

function Detour(const BaseAddr, NewAddr: Pointer; const CodeLength: LongWord = 5): Pointer;
var
 Ptr: Pointer;
 Protect: LongWord;
begin
if BaseAddr = nil then
 Error('Detour: Invalid base address.')
else
 if NewAddr = nil then
  Error('Detour: Invalid function address.')
 else
  if CodeLength < 5 then
   Error('Detour: Invalid code length.');

GetMem(Ptr, CodeLength + 5);
VirtualProtect(Ptr, CodeLength + 5, PAGE_EXECUTE_READWRITE, Protect);

VirtualProtect(BaseAddr, CodeLength, PAGE_EXECUTE_READWRITE, Protect);

CopyMemory(Ptr, BaseAddr, CodeLength);

PByte(Cardinal(Ptr) + CodeLength)^ := $E9;
PCardinal(Cardinal(Ptr) + CodeLength + 1)^ := Relative(Ptr, BaseAddr);

if CodeLength > 5 then
 WriteNOPs(Pointer(Cardinal(BaseAddr) + 5), CodeLength - 5);

PByte(BaseAddr)^ := $E9;
PCardinal(Cardinal(BaseAddr) + 1)^ := Relative(BaseAddr, NewAddr);

VirtualProtect(BaseAddr, CodeLength, Protect, Protect);

Result := Ptr;
end;

end.
