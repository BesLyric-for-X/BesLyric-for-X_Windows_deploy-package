# BesLyric-for-X Deployment and Packaging Scripts (Windows)

## Introduction

The script(s) in this repository are used to deploy and package BesLyric-for-X on Windows.

## Environment

Windows 10 x86

## Dependent tools

These tools are required to complete the work:

- PowerShell 5 / 7
- windeployqt
- Inno Setup 6.0.5 (u)
- Enigma Virtual Box v9.60 Build 20210209

## How to use

### Get

```shell
PS > git clone --recurse-submodules https://github.com/BesLyric-for-X/BesLyric-for-X_Windows_deploy-package.git
PS > #         \--------__--------/
PS > #              Important!
```

### Prepare

First of all, we should not let go of any mistake:

```powershell
$ErrorActionPreference = 'Stop'  # set -e for cmdlet
Set-StrictMode -Version 3.0      # set -u
```

Then, I think creating some variables may be helpful. For example:

```powershell
# From qmake
${target}      = '<"TARGET" in qmake project. "BesLyric-for-X" by default>'
${installRoot} = '<"INSTALL_ROOT" of "make install">'

# Common
${deployDirPath} = '<path to the directory contains deployed files>'

# For windeployqt
${windeployqtPath} = '<path to windeployqt.exe>'
${mingwBinDirPath} = '<path to the directory contains g++.exe>'
${libDirPath}      = '<path to "%B4X_DEP_PATH%\lib", contains all 3rd party dll files>'

# For Inno Setup
${isccPath}             = "<path to Inno Setup's ISCC.exe>"
${issCompression}       = '<https://jrsoftware.org/ishelp/topic_setup_compression.htm>'
${issInstallerFilePath} = '<path to generated Inno Setup installer>'

# For Enigma Virtual Box
${enigmavbconsolePath}  = "<path to Enigma Virtual Box's enigmavbconsole.exe>"
${doesEvbCompressFiles} = "does Enigma Virtual Box compress files: $true or $false"
${evbBoxFilePath}       = '<path to generated Enigma Virtual Box boxed exe>'
```

### Execute with parameters

#### Deployment script

##### windeployqt

```powershell
$windeployqtParams = @{
    WINDEPLOYQT_PATH   = ${windeployqtPath}
    MINGW_BIN_DIR_PATH = ${mingwBinDirPath}
    LIB_DIR_PATH       = ${libDirPath}
    TARGET             = ${target}
    INSTALL_ROOT       = ${installRoot}

    DEPLOY_DIR_PATH    = ${deployDirPath}
}

& '.\deploy\call_windeployqt.ps1' @windeployqtParams
```

#### Packaging scripts

##### Inno Setup

```powershell
$issParams = @{
    ISCC_PATH               = ${isccPath}
    ISS_COMPRESSION         = ${issCompression}
    TARGET                  = ${target}
    DEPLOY_DIR_PATH         = ${deployDirPath}

    ISS_INSTALLER_FILE_PATH = ${issInstallerFilePath}
}

& '.\package\call_iscc.ps1' @issParams
```

##### Enigma Virtual Box

```powershell
$evbParams = @{
    ENIGMAVBCONSOLE_PATH    = ${enigmavbconsolePath}
    DOES_EVB_COMPRESS_FILES = ${doesEvbCompressFiles}
    TARGET                  = ${target}
    DEPLOY_DIR_PATH         = ${deployDirPath}

    EVB_BOX_FILE_PATH       = ${evbBoxFilePath}
}

& '.\package\call_evbconsole.ps1' @evbParams
```

## Common code snippets

### Hash Table & Splatting

I'm using hash tables and splatting to reduce the line length of the code.

Hash table:

- [about_Hash_Tables - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables)
- [Everything you wanted to know about hashtables - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-hashtable)

Splatting:

- [about_Splatting - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting)
- [Use Splatting to Simplify Your PowerShell Scripts | Scripting Blog](https://devblogs.microsoft.com/scripting/use-splatting-to-simplify-your-powershell-scripts/)

```powershell
$hashTable = @{
    foo = 'bar'
}

Invoke-Cmdlet @hashTable
```

### Show all incoming parameters

Source: [about_Automatic_Variables - PowerShell | Microsoft Docs § $PSBoundParameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables#psboundparameters)

```powershell
$PSBoundParameters | Format-List
```

### Execute programs with call operator (&) and check the exit code $LASTEXITCODE

Call operator:

- [about_Operators - PowerShell | Microsoft Docs § Call operator `&`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators#call-operator-)
- [Call operator - Run - PowerShell - SS64.com](https://ss64.com/ps/call.html)
- [Powershell executable isn&#39;t outputting to STDOUT - Stack Overflow](https://stackoverflow.com/questions/51333183/powershell-executable-isnt-outputting-to-stdout)

Execution status `$?` and exit code `$LASTEXITCODE` :

- [about_Automatic_Variables - PowerShell | Microsoft Docs§ $?](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables#section-1)
- [about_Automatic_Variables - PowerShell | Microsoft Docs§ $LastExitCode](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables#lastexitcode)
- [windows - Difference between $? and $LastExitCode in PowerShell - Stack Overflow](https://stackoverflow.com/questions/10666035/difference-between-and-lastexitcode-in-powershell)
- [windows - $LastExitCode=0, but $?=False in PowerShell. Redirecting stderr to stdout gives NativeCommandError - Stack Overflow](https://stackoverflow.com/questions/10666101/lastexitcode-0-but-false-in-powershell-redirecting-stderr-to-stdout-gives)

```powershell
& '.\foo' 'bar'

if ($LASTEXITCODE -ne 0) {
    throw '...'
}
```

### Get temperary file with specific extension

Source: [Temporary file with given extension. | IT Pro PowerShell experience](https://becomelotr.wordpress.com/2011/11/29/temporary-file-with-given-extension/)

```powershell
${tempFile} = `
    [System.IO.Path]::GetTempFileName() | `
    Rename-Item -NewName { $_ -replace @('\.tmp$', '.ext') } -PassThru
```

### Get the absolute path to a file that may not exist

Source: [answer 16964490 § How to normalize a path in PowerShell? - Stack Overflow](https://stackoverflow.com/questions/495618/how-to-normalize-a-path-in-powershell/16964490#16964490)

```powershell
${absolutePath} = `
    [System.IO.Path]::Combine('baseDirPath', 'relativeOrAbsolutePath')
```

Doc: [Combine(String, String) § Path.Combine Method (System.IO) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.io.path.combine#System_IO_Path_Combine_System_String_System_String_)

## Credits

Projects:

- [Inno Setup - jrsoftware](https://jrsoftware.org/isinfo.php)
- [idleberg.innosetup - Inno Setup - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=idleberg.innosetup)
- [alefragnani.pascal - Pascal - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal)
- [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation)
- [Enigma Virtual Box](https://www.enigmaprotector.com/en/aboutvb.html)

Documentation:

- [PowerShell commands - PowerShell - SS64.com](https://ss64.com/ps/)
- [Free Pascal - Advanced open source Pascal compiler for Pascal and Object Pascal - Home Page.html](https://www.freepascal.org/)
- [Pascal Tutorial - Tutorialspoint](https://www.tutorialspoint.com/pascal/)
