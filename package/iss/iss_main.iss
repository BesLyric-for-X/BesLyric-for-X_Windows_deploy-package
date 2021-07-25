; UTF-8 with BOM is required.


#ifndef MY_SOURCE_DIR_PATH
    #error 'The variable "MY_SOURCE_DIR_PATH" is NOT #defined.'
#else
    #define MY_SOURCE_DIR_PATH RemoveBackslash(MY_SOURCE_DIR_PATH)
    #pragma message "MY_SOURCE_DIR_PATH = " + MY_SOURCE_DIR_PATH
#endif

#ifndef MY_FILES_SECTION_FILE_PATH
    #error 'The variable "MY_FILES_SECTION_FILE_PATH" is NOT #defined.'
#else
    #pragma message "MY_FILES_SECTION_FILE_PATH = " + MY_FILES_SECTION_FILE_PATH
#endif

#ifndef MY_APP_NAME
    #error 'The variable "MY_APP_NAME" is NOT #defined.'
#else
    #pragma message "MY_APP_NAME = " + MY_APP_NAME
#endif

#ifndef MY_COMPRESSION
    #error 'The variable "MY_COMPRESSION" is NOT #defined.'
#else
    #pragma message "MY_COMPRESSION = " + MY_COMPRESSION
#endif


#define MyAppExeName MY_APP_NAME + ".exe"
#define MyAppExePath AddBackslash(MY_SOURCE_DIR_PATH) + MyAppExeName
#define MyAppPublisher GetFileCompany(MyAppExePath)

#define MyAppPublisherURL "https://github.com/BesLyric-for-X"
#define MyAppSupportURL "https://github.com/BesLyric-for-X/BesLyric-for-X/issues"
#define MyAppUpdatesURL "https://github.com/BesLyric-for-X/BesLyric-for-X/releases"

#define MyAppFourNumbersVersion GetFileProductVersion(MyAppExePath)
#pragma message "MyAppFourNumbersVersion = " + MyAppFourNumbersVersion

; It's trick.
;   https://stackoverflow.com/questions/6498750/how-do-i-automatically-set-the-version-of-my-inno-setup-installer-according-to-m
#define MyAppThreeNumbersVersion RemoveFileExt(MyAppFourNumbersVersion)
#pragma message "MyAppThreeNumbersVersion = " + MyAppThreeNumbersVersion


[Setup]
; Why changed AppId?
;
; I didn't think that we need the "side-by-side installation" function
;   at all since any "incompatibile installations" will be uninstalled
;   first.
; For this project, an incompatibile installation is:
;   1. Installed in administrative install mode (older than 3.1.3).
;
; If we use the "side-by-side installation" function, we will not see
;   both user and all-users installations in "Apps and Features" on
;   Windows 10:
; > In the 'new' ARP (not sure what the offical name is) it only lists
;   the current user entry even though the all users one also exists as
;   seen above. This seems like a bug in this new ARP to me. Changing
;   the key name of one of the entries makes them appear both.
; From: https://groups.google.com/g/innosetup/c/7fJBi-hLW8w/m/dK38M4N5BgAJ
; Note: "ARP" stands for "Add or Remove Programs".
;
; The following is my guess:
;   Windows considers the priority in HKCU to be higher than HKLM. It
;   does make sense, so it's the bad luck of Inno Setup.
;
; AppId={{792F57C8-A564-47B1-B01C-A4DD3B43C22F} B4X older than 3.1.3
AppId={{901EF49A-FDCB-43E6-8BC3-8EC00CF5281C}

; https://stackoverflow.com/questions/28628699/inno-setup-prevent-executing-the-installer-multiple-times-simultaneously
SetupMutex=SetupMutex_{#SetupSetting("AppId")},Global\SetupMutex_{#SetupSetting("AppId")}

; Remember to create mutexes that match the name in programs to make it effective.
AppMutex=AppMutex_{{7ACD3BB0-DE1F-416E-A8DC-5C6EE4AECB50},Global\AppMutex_{{7ACD3BB0-DE1F-416E-A8DC-5C6EE4AECB50}

AppName={#MY_APP_NAME}

AppVersion={#MyAppThreeNumbersVersion}
VersionInfoVersion={#MyAppFourNumbersVersion}

AppPublisher={#MyAppPublisher}

AppPublisherURL={#MyAppPublisherURL}
AppSupportURL={#MyAppSupportURL}
AppUpdatesURL={#MyAppUpdatesURL}

DisableProgramGroupPage=yes

PrivilegesRequired=lowest

OutputBaseFilename={#MY_APP_NAME}_{#MyAppThreeNumbersVersion}_Setup

; Modify the icon in "Apps & features" (to add the "DisplayIcon" key)
;   https://stackoverflow.com/questions/20792468/inno-setup-control-panel-icon-does-not-show
UninstallDisplayIcon={app}\Beslyric.ico

Compression={#MY_COMPRESSION}

WizardStyle=modern

; Show information before installation.
InfoBeforeFile={#MY_SOURCE_DIR_PATH}\version.txt

; {userpf} == %LOCALAPPDATA%\Programs
DefaultDirName={userpf}\{#MY_APP_NAME}

; Log is important.
SetupLogging=yes

; Windows 7 and later.
MinVersion=6.1.7600

; TODO: deny x86 installation, and don't go back!
;   ArchitecturesAllowed=
;   ArchitecturesInstallIn64BitMode=

; Before any other language is fully supported, disable language selection
ShowLanguageDialog=no

[Languages]
Name: "zh_CN"; MessagesFile: ".\zh_CN\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";


[Icons]
Name: "{autoprograms}\{#MY_APP_NAME}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MY_APP_NAME}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon


[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MY_APP_NAME, '&', '&&')}}"; Flags: nowait postinstall skipifsilent


[Files]
#include Str(MY_FILES_SECTION_FILE_PATH)

; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[InstallDelete]
; Remove the desktop shortcut
Type: files; Name: "{autodesktop}\{#MY_APP_NAME}.lnk"


[CustomMessages]
  zh_CN.cm_ProgressWizardPage_StatusLabel_TryGetValidRegistryInfos=正在获取注册表信息...
english.cm_ProgressWizardPage_StatusLabel_TryGetValidRegistryInfos=Getting registry information...

  zh_CN.cm_TryGetValidRegistryInfos_DisplayVersion_unknown=未知
english.cm_TryGetValidRegistryInfos_DisplayVersion_unknown=Unknown

  zh_CN.cm_ProgressWizardPage_StatusLabel_KillRunningInstance=正在关闭旧版本的程序...
english.cm_ProgressWizardPage_StatusLabel_KillRunningInstance=Stopping running processes of the old version...

  zh_CN.cm_ProgressWizardPage_StatusLabel_LaunchUninstaller=正在卸载旧版本...
english.cm_ProgressWizardPage_StatusLabel_LaunchUninstaller=Uninstalling old version...

  zh_CN.cm_LaunchUninstaller_UninstallFailedToInitializeAndRecommendRetry=未能成功启动卸载程序，再试一次？
english.cm_LaunchUninstaller_UninstallFailedToInitializeAndRecommendRetry=The uninstaller failed to start, try again?

  zh_CN.cm_LaunchUninstaller_UninstallPreviousInstallation_Failed=无法启动卸载程序 %1%n错误代码：%2 （%3）
english.cm_LaunchUninstaller_UninstallPreviousInstallation_Failed=Failed to start the uninstaller %1%nCode: %2 (%3)

  zh_CN.cm_ProgressWizardPage_StatusLabel_MigrateData=正在迁移数据文件...
english.cm_ProgressWizardPage_StatusLabel_MigrateData=Migrating data...

  zh_CN.cm_ProgressWizardPage_StatusLabel_CleanUpOldStuff=正在清理...
english.cm_ProgressWizardPage_StatusLabel_CleanUpOldStuff=Cleaning up...

  zh_CN.cm_TryUninstallAndMigrateData_FoundOldInstallation=我们发现您已经安装了旧版本（版本： %1），要将其卸载后才能继续。%n%n立即卸载？
english.cm_TryUninstallAndMigrateData_FoundOldInstallation=We detected you have an old version installed (version: %1) and it must be uninstalled before we continue.%n%nUninstall now?

  zh_CN.cm_TryUninstallAndMigrateData_UserRefusedToUninstallOldInstallation=用户没有卸载旧版本。
english.cm_TryUninstallAndMigrateData_UserRefusedToUninstallOldInstallation=User did not uninstall the old version.

  zh_CN.cm_TryUninstallAndMigrateData_UninstallFailedToInitializeAndGaveUp=无法启动卸载程序。
english.cm_TryUninstallAndMigrateData_UninstallFailedToInitializeAndGaveUp=Failed to start the uninstaller.

  zh_CN.cm_CurStepChanged_InstallerCannotContinue=安装程序不能继续。
english.cm_CurStepChanged_InstallerCannotContinue=Setup cannot continue.

  zh_CN.cm_RunAsAdministrator=您不应该使用管理员权限运行本安装程序。%n%n一定要继续吗？
english.cm_RunAsAdministrator=You should not run this installer with administrator rights.%n%nContinue anyway?

cm_Gitter=Gitter
cm_Gitee=Gitee
cm_GitHub=GitHub

  zh_CN.cm_QQGroup=QQ 群：1021317114
english.cm_QQGroup=QQ Group: 1021317114

  zh_CN.cm_GetHelp=获取帮助：
english.cm_GetHelp=Get help:

  zh_CN.cm_RepositoryPages=项目源代码：
english.cm_RepositoryPages=Source code of this project:

cm_Gitee_URL=https://gitee.com/BesLyric-for-X/BesLyric-for-X
cm_GitHub_URL=https://github.com/BesLyric-for-X/BesLyric-for-X
cm_Gitter_URL=https://gitter.im/BesLyric-for-X_org
cm_QQGroup_URL=https://shang.qq.com/wpa/qunwpa?idkey=90548f8500d6f5b5fd9b6ee89684206053b709b6309a0dc807cdb4cd8704a78e


[Code]
#include "iss_code.pas"
