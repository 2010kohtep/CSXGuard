unit Shutdown;

{$I CSXGuard.inc}

interface

procedure ExitLibrary;

implementation

uses CvarDef, Windows, Parser;

procedure ExitLibrary;
begin
ShutdownParser;

ReleaseMutex(MutexID);
CloseHandle(ThreadID);
end;

initialization

finalization
 ExitLibrary;

end.
