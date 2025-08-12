  [Setup]
   AppName=Solian
   AppVersion=3.2.0
   DefaultDirName={pf}\Solian
   DefaultGroupName=Solian
   OutputDir=C:\Development\Solian\Installer
   OutputBaseFilename=Solian
   Compression=lzma
   SolidCompression=yes

   [Files]
   Source: "C:\Development\Solian\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

   [Icons]
   Name: "{group}\Solian"; Filename: "{app}\Solian.exe"
   Name: "{group}\Uninstall Solian"; Filename: "{uninstallexe}"

   [Run]
   Filename: "{app}\Solian.exe"; Description: "Launch Solian"; Flags: nowait postinstall skipifsilent