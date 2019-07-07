// CSXGuard v4 Loader by ratwayer
// http://madotsuki.ru | ratwayer@madotsuki.ru

{$A4,B-,C-,I-,J-,H+,O+,Q-,R-,T-,U-,V+,W-,X+,Z4}

{$IFDEF MSWINDOWS}
 {$M $4000, $100000}
{$ENDIF}

{$ExtendedSyntax ON}
{$ImportedData OFF}
{$MethodInfo OFF}
{$ObjExportAll OFF}
{$RealCompatibility OFF}

{$Hints ON}
{$Warnings ON}

{-$DEFINE Debug}
{-$UNDEF Release}

{$UNDEF Debug}
{$DEFINE Release}

{$Extension asi}

{$IF CompilerVersion >= 17}
 {$IF CompilerVersion >= 19}
  {$DEFINE Unicode}                                
 {$ELSE}
  {$UNDEF Unicode}
 {$IFEND}
 {$DEFINE Inline}
{$ELSE}
 {$UNDEF Inline}
 {$UNDEF Unicode}
{$IFEND}

{$IF SizeOf(Char) <> SizeOf(Byte))}
 {$MESSAGE FATAL 'Sorry, this project does not support D2009 or higher.'}
{$IFEND}

{$IFDEF Unicode}
 {$MESSAGE FATAL 'Sorry, this project does not support D2009 or higher.'}
{$ENDIF}

{$IF SizeOf(Boolean) <> 1}
 {$MESSAGE FATAL 'Invalid "Boolean" type size.'}
{$ELSE}
 {$IF SizeOf(Byte) <> 1}
  {$MESSAGE FATAL 'Invalid "Byte" type size.'}
 {$ELSE}
  {$IF SizeOf(Char) <> 1}
   {$MESSAGE FATAL 'Invalid "Char" type size.'}
  {$ELSE}
   {$IF SizeOf(Word) <> 2}
    {$MESSAGE FATAL 'Invalid "Word" type size.'}
   {$ELSE}
    {$IF SizeOf(LongWord) <> 4}
     {$MESSAGE FATAL 'Invalid "LongWord" type size.'}
    {$ELSE}
     {$IF SizeOf(Pointer) <> 4}
      {$MESSAGE FATAL 'Invalid "Pointer" type size.'}
     {$IFEND}
    {$IFEND}
   {$IFEND}
  {$IFEND}
 {$IFEND}
{$IFEND}

{$IFDEF Debug}
 {$IMAGEBASE $01000000}
 {$D+,L+,Y+}
{$ELSE}
 {$IMAGEBASE $00800000}
 {$D-,L-,Y-}
{$ENDIF}

{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

{$DESCRIPTION '(c) ratwayer, 2012'}