; ==================================================
#define AppVersion "3.2.0"
#define BuildNumber "124"
; ==================================================

#define FullVersion AppVersion + "." + BuildNumber

[Setup]
AppName=Solian
AppVersion={#AppVersion}
AppPublisher=Solsynth
AppPublisherURL=https://solsynth.dev
AppSupportURL=https://kb.solsynth.dev/zh/solar-network
AppUpdatesURL=https://github.com/Solsynth/Solian/releases
AppCopyright=Copyright © 2025 Solsynth
VersionInfoVersion={#FullVersion}
UninstallDisplayName=Solian
UninstallDisplayIcon={app}\Solian.exe

DefaultDirName={commonpf}\Solian
UsePreviousAppDir=no

OutputDir=C:\Development\Solian\Installer
OutputBaseFilename=Solian_Setup_{#AppVersion}
SetupIconFile=C:\Development\Solian\assets\icons\icon.ico  

Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=4

ArchitecturesAllowed=x64compatible
PrivilegesRequired=admin

[Files]
Source: "C:\Development\Solian\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Solian"; Filename: "{app}\Solian.exe";IconFilename: "{app}\Solian.exe"
Name: "{group}\{cm:UninstallProgram,Solian}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Solian"; Filename: "{app}\Solian.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\Solian.exe"; Description: "Launch Solian"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\dev.solsynth\Solian"
Type: files; Name: "{group}\Solian.lnk" ;
Type: files; Name: "{autodesktop}\Solian.lnk" ;