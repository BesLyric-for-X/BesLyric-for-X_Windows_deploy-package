
// https://wiki.freepascal.org/
// https://www.tutorialspoint.com/pascal/

// ---
// Syntax
// https://stackoverflow.com/questions/28221394/proper-structure-syntax-for-delphi-pascal-if-then-begin-end-and

// Migrate files from old directory
// https://stackoverflow.com/questions/2000296/inno-setup-how-to-automatically-uninstall-previous-installed-version#answer-2099805
// https://stackoverflow.com/questions/6345920/inno-setup-how-to-abort-terminate-setup-during-install
// https://stackoverflow.com/questions/13921535/skipping-custom-pages-based-on-optional-components-in-inno-setup

// Constant declaration
// https://stackoverflow.com/questions/18771167/why-we-cannot-declare-local-const-variables-in-inno-setup-code

// Play with the progressbar.
//   https://stackoverflow.com/questions/34336466/inno-setup-how-to-manipulate-progress-bar-on-run-section
//   https://stackoverflow.com/questions/2514107/how-to-update-the-innosetup-wizard-gui-status-text-from-pascalscript-code

// Shellexec vs Exec
// https://stackoverflow.com/questions/10374107/shellexec-vs-exec-vs-shellexec-my-batch-file
//
// > If however, the setup is running at the lowest priviliges and you try and run a process that requires elevation,
//   ShellExec() will allow it to prompt whereas Exec() will fail.
//
// Yes, it is. Inno Setup is a special case that can be Exec-ed since it will relaunch itself in the temporary directory
//   with required priviliges.

// New line / Line break: #13#10
//   https://stackoverflow.com/questions/24661916/innosetup-how-to-add-line-break-into-component-description
//
// Why don't you need to use the string operator "+" to concatenate it with other strings?
//   https://freepascal.org/docs-html/ref/refse8.html

// ---
// unused

// https://stackoverflow.com/questions/28342666/how-do-i-use-multiple-files-with-the-same-name-with-extracttemporaryfile
// https://jrsoftware.org/ishelp/index.php?topic=isxfunc_extracttemporaryfile

// https://stackoverflow.com/questions/41154540/how-to-create-label-on-bevel-line-in-inno-setup

// https://stackoverflow.com/questions/22139355/string-arrays-in-innosetup
// https://stackoverflow.com/questions/31106514/inno-setup-loop-from-a-to-z

// ---
// Windows

// https://answers.microsoft.com/en-us/windows/forum/all/wow6432node-registry-startups/481d4851-720f-4084-b1f1-8472c0eb842d
// https://stackoverflow.com/questions/45569783/inno-setup-ignoring-registry-redirection
// https://docs.microsoft.com/en-us/windows/win32/winprog64/shared-registry-keys
//   It seems that HKCU64 for the SOFTWARE Key is meaningless? Is HKCU enough?
//   I think using HKCU32 and HKCU64 instead of HKCU is not a big problem.

// For `Exec`, returnCode == 1 (ERROR_INVALID_FUNCTION), when I refused to run the uninstaller in UAC prompt.
//   https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-


const
    INTEGER_MAXIMUM_PATH_LENGTH = 100; // characters
var
    boolean_exit_with_confirmation: Boolean; // Does bypass the prompt of exit installer.


// Unable to use.
function FmtCustomMessage(
    const
        string_messageName: String;
    const
        stringArray_arguments: array of String): String;
begin
    Result := FmtMessage(
        CustomMessage(string_messageName),
        stringArray_arguments);
    // type mismatch ???
    // Why ?
    // Pass array as parameter?
end;


function StrToRegRootKey(
    const
        string_regRootKey: String;
    out
        integer_regRootKey: Integer): Boolean;
begin
    Result := True;

    case (string_regRootKey) of
        'HKCU':   integer_regRootKey := HKCU;
        'HKCU32': integer_regRootKey := HKCU32;
        'HKCU64': integer_regRootKey := HKCU64;
        'HKLM':   integer_regRootKey := HKLM;
        'HKLM32': integer_regRootKey := HKLM32;
        'HKLM64': integer_regRootKey := HKLM64;
    else
        Result := False;
    end;
end;


function GetCleanPath(const string_dirPath: String): String;
begin
    Result := RemoveBackslash(RemoveQuotes(string_dirPath));
end;


// Not robust at all. Don't play with whitespaces and ASCII control characters.
function GetConcatenatedCleanPath(
    const
        string_dirPath_base,
        string_path_relative: String): String;
begin
    Result := AddBackslash(GetCleanPath(string_dirPath_base)) + GetCleanPath(string_path_relative);
end;


function TryGetValidRegistryInfos(
    const
        string_regRootKey,
        string_AppId: String;
    out
        string_DisplayVersion,
        string_InstallLocation,
        string_UninstallString: String): Boolean;
var
    integer_regRootKey: Integer;
    string_regSubKeyName: String;
begin
    Log(Format('::Entering %s(%s, %s)', ['TryGetValidRegistryInfos', string_regRootKey, string_AppId]));
    WizardForm.StatusLabel.Caption := CustomMessage('cm_ProgressWizardPage_StatusLabel_TryGetValidRegistryInfos');

    Result := False;

    if not (StrToRegRootKey(string_regRootKey, integer_regRootKey)) then begin
        Log(Format('No such RootKey: %s, exit.', [string_regRootKey]));
        Exit;
    end;

    // Full registry key name.
    string_regSubKeyName := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + string_AppId + '_is1';
    Log(Format('Registry subkey name: %s', [string_regSubKeyName]));

    // The key.
    if not (RegKeyExists(integer_regRootKey, string_regSubKeyName)) then begin
        Log(Format('Cannot find the registry key: %s\%s, exit.', [string_regRootKey, string_regSubKeyName]));
        Exit;
    end;

    // Optional value "DisplayVersion".
    if not (RegQueryStringValue(integer_regRootKey, string_regSubKeyName, 'DisplayVersion', string_DisplayVersion)) then begin
        Log(Format('Cannot find the registry key: %s\%s: %s, use the default value.', [string_regRootKey, string_regSubKeyName, 'DisplayVersion']));
        string_DisplayVersion := CustomMessage('cm_TryGetValidRegistryInfos_DisplayVersion_unknown');
    end;
    Log(Format('DisplayVersion: %s', [string_DisplayVersion]));

    // Required value "InstallLocation".
    if not (RegQueryStringValue(integer_regRootKey, string_regSubKeyName, 'InstallLocation', string_InstallLocation)) then begin
        Log(Format('Cannot find the registry value: %s\%s: %s, exit.', [string_regRootKey, string_regSubKeyName, 'InstallLocation']));
        Exit;
    end;
    Log(Format('InstallLocation: %s', [string_InstallLocation]));

    string_InstallLocation := GetCleanPath(string_InstallLocation);
    Log(Format('InstallLocation: %s', [string_InstallLocation]));

    if not (DirExists(string_InstallLocation)) then begin
        Log(Format('Cannot find the directory: %s, exit.', [string_InstallLocation]));
        Exit;
    end;

    // Required value "UninstallString".
    if not (RegQueryStringValue(integer_regRootKey, string_regSubKeyName, 'UninstallString', string_UninstallString)) then begin
        Log(Format('Cannot find the registry value: %s\%s: %s, exit.', [string_regRootKey, string_regSubKeyName, 'UninstallString']));
        Exit;
    end;
    Log(Format('UninstallString: %s', [string_UninstallString]));

    string_UninstallString := GetCleanPath(string_UninstallString);
    Log(Format('UninstallString: %s', [string_UninstallString]));

    if not (FileExists(string_UninstallString)) then begin
        Log(Format('Cannot find the file: %s, exit.', [string_UninstallString]));
        Exit;
    end;

    Result := True;
end;


// Inno Setup cannot automatically close the program that will not be overwritten,
//   so we need to do it by ourselves.
//
// Compatible with PowerShell 2.0 (2.0.50727.4927) on Windows 7 (6.1.7600).
//
// https://superuser.com/questions/52159/kill-a-process-with-a-specific-command-line-from-command-line
// https://stackoverflow.com/questions/13524303/taskkill-to-differentiate-2-images-by-path
//
// We used "-ieq". This is the alias of "-eq", which is the case-insensitive comparison.
//   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-5.1#common-features
//
// Double single quotes to escape a single quote.
//
// Don't make the parameter too long.
//   https://stackoverflow.com/questions/3205027/maximum-length-of-command-line-string
//
// Permission matters:
//   https://stackoverflow.com/questions/63358876/wmic-process-empty-executablepath
//
function StopAndKillProcessOfSpecificPathViaPowerShell(const string_filePath_executable: String): Integer;
var
    string_powershell_parameter: String;
begin
    Log(Format('::Entering %s(%s)', ['StopAndKillProcessOfSpecificPathViaPowerShell', string_filePath_executable]));

    // WMI or CIM way

    // Kill the process.
    string_powershell_parameter :=
          '-NoProfile -Command "&{'
        +     'Get-WmiObject Win32_Process|'
        +     'Where-Object{$_.Path-ieq''' + string_filePath_executable + '''}|'
        +     'ForEach-Object{$_.Terminate()}'
        + '}"';
    Log(string_powershell_parameter);

    // Kill the process. Only works on Powershell 3 and later.
    string_powershell_parameter :=
          '-NoProfile -Command "&{'
        +     'Get-CimInstance CIM_Process|'
        +     'Where-Object{$_.Path-ieq''' + string_filePath_executable + '''}|'
        +     'Invoke-CimMethod -MethodName ''Terminate'''
        + '}"';
    Log(string_powershell_parameter);


    // Get-Process way
    //   > 32-bit processes cannot access the modules of a 64-bit process.
    //   from: https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.process#remarks
    //   More:
    //     https://stackoverflow.com/questions/5497064/how-to-get-the-full-path-of-running-process
    //     https://stackoverflow.com/questions/7446887/get-command-line-string-of-64-bit-process-from-32-bit-process

    // Kill the process.
    string_powershell_parameter :=
          '-NoProfile -Command "&{'
        +     'Get-Process|'
        +     'Where-Object{$_.Path-ieq''' + string_filePath_executable + '''}|'
        +     'ForEach-Object{Stop-Process -Force -Id $_.Id}'
        + '}"';
    Log(string_powershell_parameter);

    // Send signal to the process.
    string_powershell_parameter :=
          '-NoProfile -Command "&{'
        +     'Get-Process|'
        +     'Where-Object{$_.Path-ieq''' + string_filePath_executable + '''}|'
        +     'ForEach-Object{$_.CloseMainWindow()}'
        + '}"';
    Log(string_powershell_parameter);

    // Signal, wait and kill. Too slow because of no parallelization.
    string_powershell_parameter :=
          '-NoProfile -Command "&{'
        +     '$l=Get-Process|Where-Object{$_.Path-ieq''' + string_filePath_executable + '''};'
        +     'if(!$l){return}'                   // foreach($foo in $null) gives $null in PowerShell 2 and lower.
                                                  //   https://serverfault.com/questions/457718/protect-foreach-loop-when-empty-list
        +     'foreach($p in $l){$p.CloseMainWindow()}' // Stop the process gently first.
        +     '$l|ForEach-Object{'
        +         '$t=50;'                        // Wait for the process to end.
        +         'while($t-gt0){'
        +             'if($_.HasExited){return}'  // Why "return":
                                                  //   https://stackoverflow.com/questions/7760013/why-does-continue-behave-like-break-in-a-foreach-object
        +             'Start-Sleep -m 100;'
        +             '$t--'
        +         '}'
        +         'Stop-Process -Force -Id $_.Id' // Error may occurred, just ignore it.
        +     '}'
        + '}"';
    Log(string_powershell_parameter);

    // https://www.powershelladmin.com/wiki/PowerShell_Executables_File_System_Locations
    Exec(
        ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
        string_powershell_parameter,
        '', SW_HIDE, ewWaitUntilTerminated, Result);

    Log(Format('Code: %d (0x%x), %s', [Result, Result, SysErrorMessage(Result)]));
end;


// Dangerous.
//   Kill myself "{srcexe}"?
function KillProcessViaTaskkill(const string_imageName_process: String): Integer;
var
    string_cmd_parameter: String;
begin
    Log(Format('::Entering %s(%s)', ['KillProcessViaTaskkill', string_imageName_process]));

    string_cmd_parameter := '/F /IM "' + string_imageName_process + '"';
    Log(string_cmd_parameter);

    Exec(
        ExpandConstant('{sys}\taskkill.exe'),
        string_cmd_parameter,
        '', SW_HIDE, ewWaitUntilTerminated, Result);

    Log(Format('Code: %d (0x%x), %s', [Result, Result, SysErrorMessage(Result)]));
end;


procedure KillRunningInstance(const string_dirPath_InstallLocation: String);
begin
    Log(Format('::Entering %s(%s)', ['KillRunningInstance', string_dirPath_InstallLocation]));
    WizardForm.StatusLabel.Caption := CustomMessage('cm_ProgressWizardPage_StatusLabel_KillRunningInstance');

    if (0 <> StopAndKillProcessOfSpecificPathViaPowerShell(GetConcatenatedCleanPath(string_dirPath_InstallLocation, 'BesLyric-for-X.exe'))) then
        KillProcessViaTaskkill('BesLyric-for-X.exe'); // The fallback way.
end;


function LaunchUninstaller(
    const
        string_filePath_uninstaller: String;
    out
        string_errorMessage: String): Integer;
var
    string_uninstaller_parameter: String;
begin
    Log(Format('::Entering %s(%s)', ['LaunchUninstaller', string_filePath_uninstaller]));
    WizardForm.StatusLabel.Caption := CustomMessage('cm_ProgressWizardPage_StatusLabel_LaunchUninstaller');

    string_uninstaller_parameter := '/SILENT /NORESTART /SUPPRESSMSGBOXES /LOG';
    Log(string_uninstaller_parameter);

    Exec(
        string_filePath_uninstaller,
        string_uninstaller_parameter,
        '', SW_SHOWNORMAL, ewWaitUntilTerminated, Result);

    Log(Format('Code: %d (0x%x), %s', [Result, Result, SysErrorMessage(Result)]));

    if (Result <> 0) then begin
        if (Result = 1) then begin
            // Uninstaller failed to initilize.
            string_errorMessage := CustomMessage('cm_LaunchUninstaller_UninstallFailedToInitializeAndRecommendRetry');
        end else begin
            // Other cases.
            string_errorMessage := FmtMessage(CustomMessage('cm_LaunchUninstaller_UninstallPreviousInstallation_Failed'), [string_filePath_uninstaller, IntToStr(Result), SysErrorMessage(Result)]);
        end;

        Exit;
    end;

    // https://jrsoftware.org/ishelp/topic_uninstexitcodes.htm
    // > Note that at the moment you get an exit code back from the uninstaller, some code related to uninstallation might still be running.
    //
    // https://stackoverflow.com/questions/18902060/disk-caching-issue-with-inno-setup
    // Well, this has nothing to do with the disk cache, but the principle of Inno Setup uninstaller.
    //   See this: https://stackoverflow.com/questions/18902060/disk-caching-issue-with-inno-setup/18972903#18972903
    //
    // If the uninstaller has been deleted, the uninstallation is over.
    while (FileExists(string_filePath_uninstaller)) do begin
        Log(Format('The uninstaller %s still exists, wait...', [string_filePath_uninstaller]));
        Sleep(100);
        // I don't think it's a good idea to set a timeout, because the performance of each computer is different.
    end;
end;


procedure MigrateData(const string_dirPath_InstallLocation: String);
var
    string_dirPath_data_old,
    string_dirPath_data_new,

    string_filePath_lyricList_old,
    string_filePath_setting_old,

    string_filePath_lyricList_new,
    string_filePath_setting_new: String;
begin
    Log(Format('::Entering %s(%s)', ['MigrateData', string_dirPath_InstallLocation]));
    WizardForm.StatusLabel.Caption := CustomMessage('cm_ProgressWizardPage_StatusLabel_MigrateData');

    string_dirPath_data_old := GetConcatenatedCleanPath(string_dirPath_InstallLocation,   'data');
    string_dirPath_data_new := GetConcatenatedCleanPath(ExpandConstant('{localappdata}'), 'BesLyric-for-X');
    Log(Format('The old data directory path: %s', [string_dirPath_data_old]));
    Log(Format('The new data directory path: %s', [string_dirPath_data_new]));

    string_filePath_lyricList_old := GetConcatenatedCleanPath(string_dirPath_data_old, 'lyricList.xml');
    string_filePath_setting_old   := GetConcatenatedCleanPath(string_dirPath_data_old, 'setting.xml');
    Log(Format('The old lyricList.xml path: %s', [string_filePath_lyricList_old]));
    Log(Format('The old setting.xml path: %s', [string_filePath_setting_old]));

    string_filePath_lyricList_new := GetConcatenatedCleanPath(string_dirPath_data_new, 'lyricList.xml');
    string_filePath_setting_new   := GetConcatenatedCleanPath(string_dirPath_data_new, 'setting.xml');
    Log(Format('The new lyricList.xml path: %s', [string_filePath_lyricList_new]));
    Log(Format('The new setting.xml path: %s', [string_filePath_setting_new]));

    if not (DirExists(string_dirPath_data_old)) then begin
        Log('Cannot find the old data directory, exit.');
        Exit;
    end;

    // Create new data dir.
    Log('Creating the new data directory.');
    if not (ForceDirectories(string_dirPath_data_new)) then begin
        Log('Failed to create the new data directory, exit.');
        Exit;
    end;

    // Move lyricList.xml.
    if (FileExists(string_filePath_lyricList_old)) then begin
        Log('Copying the old lyricList.xml');
        if (FileCopy(string_filePath_lyricList_old, string_filePath_lyricList_new, False { Do overwrite } )) then begin
            Log('Deleting the old lyricList.xml.');
            if not (DeleteFile(string_filePath_lyricList_old)) then
                Log('Failed to delete the old lyricList.xml');
        end else begin
            Log('Failed to copy the old lyricList.xml');
        end;
    end;

    // Move setting.xml.
    if (FileExists(string_filePath_setting_old)) then begin
        Log('Copying the old setting.xml');
        if (FileCopy(string_filePath_setting_old, string_filePath_setting_new, False { Do overwrite } )) then begin
            Log('Deleting the old setting.xml');
            if not (DeleteFile(string_filePath_setting_old)) then
                Log('Failed to delete the old setting.xml');
        end else begin
            Log('Failed to copy the old setting.xml');
        end;
    end;

    // Remove old data dir.
    Log('Removing the old data directory.');
    if not (RemoveDir(string_dirPath_data_old)) then
        Log('Failed to remove the old data directory.');
end;


procedure CleanUpOldStuff(const string_dirPath_InstallLocation: String);
var
    string_dirPath_parent_of_InstallLocation: String;
    string_dirName_parent_of_InstallLocation: String;
begin
    Log(Format('::Entering %s(%s)', ['CleanUpOldStuff', string_dirPath_InstallLocation]));
    WizardForm.StatusLabel.Caption := CustomMessage('cm_ProgressWizardPage_StatusLabel_CleanUpOldStuff');

    Log('Removing the old installation directory.');
    if not (RemoveDir(string_dirPath_InstallLocation)) then begin
        Log('Failed to remove the old installation directory, exit.');
        Exit;
    end;

    string_dirPath_parent_of_InstallLocation := ExtractFileDir(string_dirPath_InstallLocation);
    string_dirName_parent_of_InstallLocation := ExtractFileName(string_dirPath_parent_of_InstallLocation);
    Log(Format('The parent directory path of the old installation: %s', [string_dirPath_parent_of_InstallLocation]));
    Log(Format('The parent directory name of the old installation: %s', [string_dirName_parent_of_InstallLocation]));

    if (Lowercase('BesStudio') = Lowercase(string_dirName_parent_of_InstallLocation)) then begin
        Log('Removing the parent directory of the old installation.');
        if not (RemoveDir(string_dirPath_parent_of_InstallLocation)) then begin
            Log('Failed to remove the parent directory of the old installation, exit.');
            Exit;
        end;
    end;
end;


// MsgBox.
function TryUninstallAndMigrateData(
    const
        string_regRootKey,
        string_AppId: String;
    const
        boolean_doMigration: Boolean;
    out
        string_errorMessage: String): Boolean;
var
    string_DisplayVersion,
    string_InstallLocation,
    string_UninstallString: String;
begin
    if (boolean_doMigration) then
        Log(Format('::Entering %s(%s, %s, True)',  ['TryUninstallAndMigrateData', string_regRootKey, string_AppId]))
    else
        Log(Format('::Entering %s(%s, %s, False)', ['TryUninstallAndMigrateData', string_regRootKey, string_AppId]));

    Result := True;

    // Look for old installation.
    if not (TryGetValidRegistryInfos(
        string_regRootKey, string_AppId,
        string_DisplayVersion, string_InstallLocation, string_UninstallString)) then
        Exit;

    Result := False;

    WizardForm.ProgressGauge.Position := 20;
    WizardForm.ProgressGauge.State := npbsPaused;

    // Let users know that the old installation must be uninstalled first.
    //   We will launch the uninstaller in SUPPRESSMSGBOXES mode.
    if not (IDYES = SuppressibleMsgBox(
        FmtMessage(CustomMessage('cm_TryUninstallAndMigrateData_FoundOldInstallation'),[string_DisplayVersion]),
        mbConfirmation,
        MB_YESNO or MB_SETFOREGROUND,
        IDYES)) then begin
        string_errorMessage := CustomMessage('cm_TryUninstallAndMigrateData_UserRefusedToUninstallOldInstallation');
        Exit;
    end;

    WizardForm.ProgressGauge.State := npbsNormal;

    // Shutdown all running old instances and uninstall old installation.
    while (True) do begin
        WizardForm.ProgressGauge.Position := 40;

        KillRunningInstance(string_InstallLocation);

        WizardForm.ProgressGauge.Position := 60;

        case (LaunchUninstaller(string_UninstallString, string_errorMessage)) of
            0:
                // Everything is OK.
                break;
            1: begin
                // Uninstaller failed to initialize.

                WizardForm.ProgressGauge.State := npbsPaused;

                // We will not retry the uninstallation in SUPPRESSMSGBOXES mode.
                if (IDYES = SuppressibleMsgBox(string_errorMessage, mbError, MB_YESNO or MB_SETFOREGROUND, IDNO)) then begin
                    // Try again. Continue the loop.

                    WizardForm.ProgressGauge.State := npbsNormal;

                    continue;
                end else begin
                    // Give up.
                    string_errorMessage := CustomMessage('cm_TryUninstallAndMigrateData_UninstallFailedToInitializeAndGaveUp');
                    Exit;
                end;
            end;
        else
            // Other cases (neither 0 nor 1).
            Exit;
        end;
    end;

    WizardForm.ProgressGauge.Position := 80;

    // Migrate datas from "data/" directory and clean up old files and directories.
    if (boolean_doMigration) then begin
        MigrateData(string_InstallLocation); // maybe need to add return value and error message?
        CleanUpOldStuff(string_InstallLocation);
    end;

    WizardForm.ProgressGauge.Position := 100;

    Result := True;
end;


// No MsgBox.
function ProcessOldInstallations(out string_errorMessage: String): Boolean;
begin
    Result := False;

    if not (TryUninstallAndMigrateData('HKLM32', '{792F57C8-A564-47B1-B01C-A4DD3B43C22F}', True, string_errorMessage)) then
        Exit;

    Result := True;
end;


// https://stackoverflow.com/questions/21737462/how-to-properly-close-out-of-inno-setup-wizard-without-prompt
// https://stackoverflow.com/questions/5833200/inno-setup-exiting-when-clicking-on-cancel-without-confirmation
//
procedure CancelButtonClick(
    const
        CurPageID: Integer;
    var
        Cancel,
        Confirm: Boolean);
begin
    Cancel  := True;
    Confirm := boolean_exit_with_confirmation;
end;


procedure TerminateWizard();
begin
    boolean_exit_with_confirmation := False;
    WizardForm.Close();
    Abort(); // The emergency exit in "/VERYSILENT" mode.
end;


// MsgBox.
procedure CurStepChanged(const CurStep: TSetupStep);
var
    string_errorMessage: String;
begin
    case (CurStep) of
        ssInstall: begin
            // CurStepChanged(ssInstall) will be called before the actual installation starts.

            Log('-- Entering ProcessOldInstallations() --');

            if not (ProcessOldInstallations(string_errorMessage)) then begin
                WizardForm.ProgressGauge.State := npbsError;

                SuppressibleMsgBox(
                    Format('%s'#13#10#13#10'%s', [string_errorMessage, CustomMessage('cm_CurStepChanged_InstallerCannotContinue')]),
                    mbError,
                    MB_OK or MB_SETFOREGROUND,
                    IDOK);

                TerminateWizard();
            end;

            Log('-- Leaving ProcessOldInstallations() --');
        end;
    end;
end;


function NextButtonClick(const CurPageID: Integer): Boolean;
begin
    Result := True;

    case (CurPageID) of
        wpSelectDir: begin
            // Inno Setup's built-in check is not perfect, so added another one.
            if (INTEGER_MAXIMUM_PATH_LENGTH < Length(Trim(ExpandConstant('{app}')))) then begin
                Result := False;

                // In SUPPRESSMSGBOXES mode, Inno Setup will not try this over and over again, but will end immediately.
                SuppressibleMsgBox(SetupMessage(msgDirNameTooLong), mbError, MB_OK or MB_SETFOREGROUND, IDOK);
            end;
        end;
    end;
end;


procedure CurPageChanged(const CurPageID: Integer);
begin
    case (CurPageID) of
        wpPreparing: begin
            // Disable the "Do not close the applications" radio button
            //   on the "Preparing to Install" page.
            // https://stackoverflow.com/questions/42385443/inno-setup-give-only-cancel-option-on-preparing-to-install-page-if-applic
            WizardForm.PreparingNoRadio.Enabled := False;
        end;
    end;
end;


// https://stackoverflow.com/questions/38934332/how-can-i-make-a-button-or-a-text-in-inno-setup-that-opens-web-page-when-clicked
//

procedure OpenBrowser(string_url: String);
var
    integer_errorCode: Integer;
begin
    ShellExec('open', string_url, '', '', SW_SHOWNORMAL, ewNoWait, integer_errorCode);
end;


procedure GiteeLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_Gitee_URL'));
end;

procedure GitHubLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_GitHub_URL'));
end;

procedure GitterLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_Gitter_URL'));
end;

procedure QQGroupLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_QQGroup_URL'));
end;


// Inno Setup 6.0.5\Examples\CodeClasses.iss
// https://stackoverflow.com/questions/64698853/when-do-i-really-need-to-use-scalex-and-scaley-functions-in-inno-setup
//

{
Layout:

|                                                                                                |
|  ___                                                                                           |
|   |   label_GetHelp       label_Gitter       label_QQGroup                                     |
|   |                |- 4 -|            |- 4 -|                                                  |
|   2                                                                                            |
|   |                                                                                            |
|  _|_                                                                                           |
|       label_RepositoryPages       label_GitHub       label_Gitee              [ Cancel ]       |
||- w -|                     |- 4 -|            |- 4 -|                                   |- w -||
+------------------------------------------------------------------------------------------------+
}

procedure CreateLabelsAndLinksOnDialog();
var
    label_RepositoryPages,
    label_GetHelp,

    label_Gitter,
    label_QQGroup,

    label_GitHub,
    label_Gitee: TLabel;
begin
    label_RepositoryPages := TLabel.Create(WizardForm);
    with label_RepositoryPages do begin
        Caption := CustomMessage('cm_RepositoryPages');
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clGrayText;
        Top := WizardForm.CancelButton.Top + WizardForm.CancelButton.Height - Height;
        Left := WizardForm.ClientWidth - (WizardForm.CancelButton.Left + WizardForm.CancelButton.Width);
        Anchors := [akLeft, akBottom];
    end;

    label_GetHelp := TLabel.Create(WizardForm);
    with label_GetHelp do begin
        Caption := CustomMessage('cm_GetHelp');
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clGrayText;
        Top := label_RepositoryPages.Top - Height - ScaleY(2);
        Left := label_RepositoryPages.Left;
        Anchors := [akLeft, akBottom];
    end;


    label_Gitter := TLabel.Create(WizardForm);
    with label_Gitter do begin
        Caption := CustomMessage('cm_Gitter');
        Cursor := crHand;
        OnClick := @GitterLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clHotLight;
        Top := label_GetHelp.Top;
        Left := (label_GetHelp.Left + label_GetHelp.Width) + ScaleX(4);
        Anchors := [akLeft, akBottom];
    end;

    label_QQGroup := TLabel.Create(WizardForm);
    with label_QQGroup do begin
        Caption := CustomMessage('cm_QQGroup');
        Cursor := crHand;
        OnClick := @QQGroupLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clHotLight;
        Top := label_Gitter.Top;
        Left := (label_Gitter.Left + label_Gitter.Width) + ScaleX(4);
        Anchors := [akLeft, akBottom];
    end;


    label_GitHub := TLabel.Create(WizardForm);
    with label_GitHub do begin
        Caption := CustomMessage('cm_GitHub');
        Cursor := crHand;
        OnClick := @GitHubLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clHotLight;
        Top := label_RepositoryPages.Top;
        Left := (label_RepositoryPages.Left + label_RepositoryPages.Width) + ScaleX(4);
        Anchors := [akLeft, akBottom];
    end;

    label_Gitee := TLabel.Create(WizardForm);
    with label_Gitee do begin
        Caption := CustomMessage('cm_Gitee');
        Cursor := crHand;
        OnClick := @GiteeLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Color := clHotLight;
        Top := label_GitHub.Top;
        Left := (label_GitHub.Left + label_GitHub.Width) + ScaleX(4);
        Anchors := [akLeft, akBottom];
    end;
end;


procedure InitializeVariables();
begin
    boolean_exit_with_confirmation := True;
end;


function InitializeSetup(): Boolean;
begin
    Result := False;

    InitializeVariables();
    Result := True;
end;


procedure InitializeWizard();
begin
    CreateLabelsAndLinksOnDialog();
end;
