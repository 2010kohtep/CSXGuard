unit MsgAPI;

{$I CSXGuard.inc}

interface

uses CvarDef;

procedure Print(const Msg: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;
procedure Print(const Msg: String; R, G, B: Byte; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;

procedure Print(const Str1, Str2: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;
procedure Print(const Str1, Str2, Str3: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;
procedure Print(const Str1, Str2, Str3, Str4: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;

procedure Print(const Str1, Str2: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;
procedure Print(const Str1, Str2, Str3: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;
procedure Print(const Str1, Str2, Str3, Str4: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]); overload;

procedure ReleaseMessages;
procedure ClearMessages;

implementation

uses Common, HLSDK;

const
 MAX_MESSAGES = 192;

type
 TMessageType = (TYPE_DEFAULT = 0, TYPE_DEVELOPER, TYPE_COLORED, TYPE_COLORED_DEV);

 PMessage = ^TMessage;
 TMessage = packed record
  Data: String;
  MessageType: TMessageType;
  R, G, B: Byte;
 end;

var
 Messages: packed array[1..MAX_MESSAGES] of TMessage;
 MessageCount: LongWord = 0;

 Released: Boolean = False;

procedure AddMessage;
begin
if MessageCount >= MAX_MESSAGES then
 ClearMessages;
Inc(MessageCount);
end;

procedure PushToConsole(const Msg: String; const Developer: Boolean = False);
begin
if Developer then
 Engine.Con_DPrintF(PChar(Msg))
else
 Engine.Con_PrintF(PChar(Msg));
end;

procedure PushToList(const Msg: String; const Developer: Boolean = False);
begin
AddMessage;
with Messages[MessageCount] do
 begin
  Data := Msg;
  Byte(MessageType) := Byte(TYPE_DEFAULT) + Byte(Developer);
 end;
end;

procedure PushColoredToConsole(const Msg: String; R, G, B: Byte; const Developer: Boolean = False);
var
 DefaultColor: TColor24;
 Ptr: PColor24;
begin
if Developer then
 Ptr := Console_TextColorDev
else
 Ptr := Console_TextColor;

DefaultColor := Ptr^;
Ptr.R := R;
Ptr.G := G;
Ptr.B := B;

if Developer then
 Engine.Con_DPrintF(PChar(Msg))
else
 Engine.Con_PrintF(PChar(Msg));
Ptr^ := DefaultColor;
end;

procedure PushColoredToList(const Msg: String; R, G, B: Byte; const Developer: Boolean = False);
var
 MessagePtr: PMessage;
begin
AddMessage;
MessagePtr := @Messages[MessageCount];

MessagePtr.Data := Msg;
Byte(MessagePtr.MessageType) := Byte(TYPE_COLORED) + Byte(Developer);
MessagePtr.R := R;
MessagePtr.G := G;
MessagePtr.B := B;
end;

procedure Print(const Msg: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
var
 Developer: Boolean;
begin
Developer := PRINT_DEVELOPER in Flags;

if not FirstFrame then
 if PRINT_PREFIX in Flags then
  begin
   PushToConsole('[', Developer);
   PushColoredToConsole(Prefix, PREFIX_COLOR_R, PREFIX_COLOR_G, PREFIX_COLOR_B, Developer);
   if PRINT_LINE_BREAK in Flags then
    PushToConsole('] ' + Msg + #$A, Developer)
   else
    PushToConsole('] ' + Msg, Developer);
  end
 else
  if PRINT_LINE_BREAK in Flags then
   PushToConsole(Msg + #$A, Developer)
  else
   PushToConsole(Msg, Developer)
else
 begin
  if MessageCount >= MAX_MESSAGES then
   ClearMessages;
  Inc(MessageCount);

  if PRINT_PREFIX in Flags then
   begin
    PushToList('[', Developer);
    PushColoredToList(Prefix, PREFIX_COLOR_R, PREFIX_COLOR_G, PREFIX_COLOR_B, Developer);
    if PRINT_LINE_BREAK in Flags then
     PushToList('] ' + Msg + #$A, Developer)
    else
     PushToList('] ' + Msg, Developer);
   end
  else
   if PRINT_LINE_BREAK in Flags then
    PushToList(Msg + #$A, Developer)
   else
    PushToList(Msg, Developer);
 end;
end;

procedure ReleaseMessages;
var
 I: LongWord;
 MessagePtr: PMessage;
begin
if Released then
 Error('ReleaseMessages: Invalid secondary call to ReleaseMessages.')
else
 Released := True;                                                                    
 
for I := 1 to MessageCount do
 begin
  MessagePtr := @Messages[I]; 

  case MessagePtr.MessageType of
   TYPE_DEFAULT: Engine.Con_PrintF(PChar(MessagePtr.Data));
   TYPE_DEVELOPER: Engine.Con_DPrintF(PChar(MessagePtr.Data));
   TYPE_COLORED: PushColoredToConsole(PChar(MessagePtr.Data), MessagePtr.R, MessagePtr.G, MessagePtr.B, False);
   TYPE_COLORED_DEV: PushColoredToConsole(PChar(MessagePtr.Data), MessagePtr.R, MessagePtr.G, MessagePtr.B, True);
   else
    Error('ReleaseMessages: Invalid message type.');
  end;
 end;

ClearMessages;
end;

procedure ClearMessages;
begin
Finalize(Messages);
MessageCount := 0;
end;

procedure Print(const Msg: String; R, G, B: Byte; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
var
 Developer: Boolean;
begin
Developer := PRINT_DEVELOPER in Flags;

if not FirstFrame then
 if PRINT_PREFIX in Flags then
  begin
   PushColoredToConsole('[', R, G, B, Developer);
   PushColoredToConsole(Prefix, PREFIX_COLOR_R, PREFIX_COLOR_G, PREFIX_COLOR_B, Developer);
   if PRINT_LINE_BREAK in Flags then
    PushColoredToConsole('] ' + Msg + #$A, R, G, B, Developer)
   else
    PushColoredToConsole('] ' + Msg, R, G, B, Developer);
  end
 else
  if PRINT_LINE_BREAK in Flags then
   PushColoredToConsole(Msg + #$A, R, G, B, Developer)
  else
   PushColoredToConsole(Msg, R, G, B, Developer)
else
 begin
  if MessageCount >= MAX_MESSAGES then
   ClearMessages;
  Inc(MessageCount);

  if PRINT_PREFIX in Flags then
   begin
    PushColoredToList('[', R, G, B, Developer);
    PushColoredToList(Prefix, PREFIX_COLOR_R, PREFIX_COLOR_G, PREFIX_COLOR_B, Developer);
    if PRINT_LINE_BREAK in Flags then
     PushColoredToList('] ' + Msg + #$A, R, G, B, Developer)
    else
     PushColoredToList('] ' + Msg, R, G, B, Developer);
   end
  else
   if PRINT_LINE_BREAK in Flags then
    PushColoredToList(Msg + #$A, R, G, B, Developer)
   else
    PushColoredToList(Msg, R, G, B, Developer);
 end;
end;

procedure Print(const Str1, Str2: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(Str1 + Str2, Flags);
end;

procedure Print(const Str1, Str2, Str3: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(Str1 + Str2 + Str3, Flags);
end;

procedure Print(const Str1, Str2, Str3, Str4: String; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(Str1 + Str2 + Str3 + Str4, Flags);
end;

procedure Print(const Str1, Str2: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(String(Str1) + Str2, Flags);
end;

procedure Print(const Str1, Str2, Str3: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(String(Str1) + Str2 + Str3, Flags);
end;

procedure Print(const Str1, Str2, Str3, Str4: PChar; const Flags: TPrintFlags = [PRINT_PREFIX, PRINT_LINE_BREAK]);
begin
Print(String(Str1) + Str2 + Str3 + Str4, Flags);
end;

end.
