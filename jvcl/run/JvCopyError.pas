{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvCopyError.PAS, released on 2001-02-28.

The Initial Developer of the Original Code is Sébastien Buysse [sbuysse@buypin.com]
Portions created by Sébastien Buysse are Copyright (C) 2001 Sébastien Buysse.
All Rights Reserved.

Contributor(s): Michael Beck [mbeck@bigfoot.com].

Last Modified: 2000-02-28

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I jvcl.inc}
{$I windowsonly.inc}

unit JvCopyError;

interface

uses
  Windows, SysUtils, Classes,
  JvCommonDialogD, JvTypes;

type
  TJvCopyError = class(TJvCommonDialogD)
  private
    FPathToSource: string;
    FNewPath: string;
    FDiskName: string;
    FStyle: TJvDiskStyles;
    FWin32ErrorCode: Integer;
    FTargetFile: string;
    FSourceFile: string;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: TJvDiskRes; override;
  published
    property DiskName: string read FDiskName write FDiskName;
    property PathToSource: string read FPathToSource write FPathToSource;
    property NewPath: string read FNewPath write FNewPath;
    property SourceFile: string read FSourceFile write FSourceFile;
    property TargetFile: string read FTargetFile write FTargetFile;
    property Win32ErrorCode: Integer read FWin32ErrorCode write FWin32ErrorCode default 0;
    property Style: TJvDiskStyles read FStyle write FStyle default [];
  end;

implementation

uses
  JclSysUtils;

const
  DPROMPT_SUCCESS        = 0;
  DPROMPT_CANCEL         = 1;
  DPROMPT_SKIPFILE       = 2;
  DPROMPT_BUFFERTOOSMALL = 3;
  DPROMPT_OUTOFMEMORY    = 4;
  
type
  TSetupCopyError = function(hwndParent: HWND; const DialogTitle, DiskName,
    PathToSource, SourceFile, TargetPathFile: PAnsiChar; Win32ErrorCode: UINT; Style: DWORD;
    PathBuffer: PAnsiChar; PathBufferSize: DWORD; PathRequiredSize: PDWORD): UINT; stdcall;

constructor TJvCopyError.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDiskName := '';
  FPathToSource := '';
  FNewPath := '';
  FStyle := [];
  FSourceFile := '';
  FTargetFile := '';
  FWin32ErrorCode := 0;
end;

function TJvCopyError.Execute: TJvDiskRes;
var
  Required: DWORD;
  Res: array [0..255] of Char;
  SetupCopyError: TSetupCopyError;
begin
  SetupCopyError := GetProcAddress(SetupApiDllHandle, 'SetupCopyErrorA');
  case SetupCopyError(OwnerWindow, PCharOrNil(Title), PCharOrNil(DiskName),
      PChar(PathToSource), PChar(SourceFile), PCharOrNil(TargetFile),
      FWin32ErrorCode, JvDiskStylesToDWORD(Style), Res, SizeOf(Res), @Required) of
    DPROMPT_SUCCESS:
      begin
        FNewPath := Res;
        Result := dsSuccess;
      end;
    DPROMPT_CANCEL:
      Result := dsCancel;
    DPROMPT_SKIPFILE:
      Result := dsSkipfile;
  else
    Result := dsError;
  end;
end;

end.

