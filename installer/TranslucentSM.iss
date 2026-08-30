; TranslucentSM — Inno Setup installer
; Reworked by Arsxxi (fork of rounk-ctrl)
; - User-choosable install dir (DisableDirPage=no)
; - Admin install (Program Files default, but user may pick anything)
; - Hidden Task Scheduler logon task with 5s delay (no CMD popup)
; - Branding Option C: custom Welcome page with yamadaaa art + rework note
; Art is local-only (yamadaaa.png not pushed). Build still succeeds without BMPs.

#define MyAppName "TranslucentSM"
#define MyAppVersion "0.6.10"
#define MyAppPublisher "Arsxxi (fork of rounk-ctrl)"
#define MyAppURL "https://github.com/Arsxxi/TranslucentSM"

[Setup]
AppId={{1E6EF77B-C47A-4EA8-9E6D-7AE212E08FBA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesInstallIn64BitMode=x64
Compression=lzma
SolidCompression=yes
WizardStyle=modern
OutputDir=..
OutputBaseFilename=Setup_TranslucentSM_v{#MyAppVersion}
UninstallDisplayIcon={app}\start.exe
VersionInfoVersion=0.6.10.0
VersionInfoDescription={#MyAppName} — Reworked by Arsxxi
; Branding (Option C, local-only): yamadaaa art gitignored
; WizardStyle=modern ignores WizardImageFile — left art is drawn via [Code] + temp file below
#ifexist "yamadaaa.bmp"
WizardImageFile=yamadaaa.bmp
#endif
#ifexist "yamadaaa-small.bmp"
WizardSmallImageFile=yamadaaa-small.bmp
#endif

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\x64\Release\start.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\x64\Release\StartTAP.dll"; DestDir: "{app}"; Flags: ignoreversion
#ifexist "yamadaaa.bmp"
Source: "yamadaaa.bmp"; DestDir: "{tmp}"; Flags: dontcopy
#endif

[Icons]
Name: "{autoprograms}\{#MyAppName}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
; Create hidden logon task with 5s delay — schtasks is built-in, no extra file
Filename: "schtasks"; Parameters: "/create /tn TranslucentSM /tr ""'{app}\start.exe' --daemon"" /sc onlogon /delay 0000:05 /rl limited /f"; Flags: runhidden
; Apply immediately without reboot
Filename: "{app}\start.exe"; Parameters: "--daemon"; Flags: nowait runhidden; Description: "Apply translucency now"

[UninstallRun]
Filename: "schtasks"; Parameters: "/delete /tn TranslucentSM /f"; Flags: runhidden
Filename: "taskkill"; Parameters: "/f /im start.exe"; Flags: runhidden
; Clean legacy HKCU\Run entry from old install.cmd installs
Filename: "reg"; Parameters: "delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Run"" /v TranslucentSM /f"; Flags: runhidden

[Code]
var
  BrandingPage: TWizardPage;
  BrandImage: TBitmapImage;
  BrandLabel1, BrandLabel2, BrandLabel3, BrandLink: TNewStaticText;

procedure OpenURL(Sender: TObject);
var
  ErrCode: Integer;
begin
  ShellExec('open', 'https://github.com/Arsxxi/TranslucentSM', '', '', SW_SHOW, ewNoWait, ErrCode);
end;

procedure InitializeWizard;
var
  TmpBmp: String;
begin
  BrandingPage := CreateCustomPage(wpWelcome, 'TranslucentSM — Reworked by Arsxxi', 'Original by rounk-ctrl • XAML Diagnostics injection');

  // Left art — Option A: extract local BMP to {tmp} at runtime (gitignored, CI fallback = text only)
  TmpBmp := ExpandConstant('{tmp}\yamadaaa.bmp');
  try
    ExtractTemporaryFile('yamadaaa.bmp');
  except
  end;
  if FileExists(TmpBmp) then
  begin
    BrandImage := TBitmapImage.Create(BrandingPage);
    BrandImage.Parent := BrandingPage.Surface;
    BrandImage.Left := ScaleX(0);
    BrandImage.Top := ScaleY(0);
    BrandImage.Width := ScaleX(164);
    BrandImage.Height := ScaleY(180);
    BrandImage.Stretch := True;
    BrandImage.Center := True;
    try
      BrandImage.Bitmap.LoadFromFile(TmpBmp);
    except
    end;
  end;

  BrandLabel1 := TNewStaticText.Create(BrandingPage);
  BrandLabel1.Parent := BrandingPage.Surface;
  BrandLabel1.Left := ScaleX(180);
  BrandLabel1.Top := ScaleY(10);
  BrandLabel1.Width := BrandingPage.SurfaceWidth - ScaleX(180);
  BrandLabel1.AutoSize := False;
  BrandLabel1.WordWrap := True;
  BrandLabel1.Caption := 'Reworked by Arsxxi — fork of rounk-ctrl/TranslucentSM. Makes the Start Menu translucent via XAML Diagnostics.';

  BrandLabel2 := TNewStaticText.Create(BrandingPage);
  BrandLabel2.Parent := BrandingPage.Surface;
  BrandLabel2.Left := ScaleX(180);
  BrandLabel2.Top := ScaleY(60);
  BrandLabel2.Width := BrandingPage.SurfaceWidth - ScaleX(180);
  BrandLabel2.AutoSize := False;
  BrandLabel2.WordWrap := True;
  BrandLabel2.Caption := 'This build: Windows subsystem (no CMD popup), hidden Task Scheduler startup (5s delay), <2 MB daemon. Choose any install folder on the next page.';

  BrandLabel3 := TNewStaticText.Create(BrandingPage);
  BrandLabel3.Parent := BrandingPage.Surface;
  BrandLabel3.Left := ScaleX(180);
  BrandLabel3.Top := ScaleY(120);
  BrandLabel3.Width := BrandingPage.SurfaceWidth - ScaleX(180);
  BrandLabel3.AutoSize := False;
  BrandLabel3.WordWrap := True;
  BrandLabel3.Caption := 'Original: github.com/rounk-ctrl/TranslucentSM  •  Fork:';

  BrandLink := TNewStaticText.Create(BrandingPage);
  BrandLink.Parent := BrandingPage.Surface;
  BrandLink.Left := ScaleX(180);
  BrandLink.Top := ScaleY(138);
  BrandLink.Cursor := crHand;
  BrandLink.Font.Color := clBlue;
  BrandLink.Font.Style := [fsUnderline];
  BrandLink.Caption := 'github.com/Arsxxi/TranslucentSM';
  BrandLink.OnClick := @OpenURL;
end;

function InitializeUninstall: Boolean;
begin
  Result := True;
end;
