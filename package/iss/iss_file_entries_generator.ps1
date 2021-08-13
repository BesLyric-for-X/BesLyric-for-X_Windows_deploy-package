
param (
    [Parameter(Mandatory = $true)][string]${SOURCE_DIR_PATH}
    , [Parameter(Mandatory = $true)][string]${FILES_SECTION_FILE_PATH}
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${fileEntries} = New-Object -TypeName 'System.Collections.ArrayList'

${filePathArray} = `
    Get-ChildItem -Path ${SOURCE_DIR_PATH} -File -Recurse | `
    Select-Object -ExpandProperty 'FullName'

${numberOfDigits} = [System.Math]::Log10(${filePathArray}.Length) + 1

Push-Location -Path ${SOURCE_DIR_PATH}

foreach (${filePath} in ${filePathArray}) {
    ${relativeFilePath} = Resolve-Path -Path ${filePath} -Relative
    ${relativeDirPath} = Split-Path -Path ${relativeFilePath} -Parent

    ${entrySource} = "{#MY_SOURCE_DIR_PATH}\${relativeFilePath}"
    ${entryDestDir} = "{app}\${relativeDirPath}"

    ${fileEntry} = `
        'Source: "{0}"; DestDir: "{1}"; Flags: ignoreversion' `
        -f @(${entrySource}, ${entryDestDir})

    Write-Output -InputObject "File[$($([string]$(${fileEntries}.Add(${fileEntry}))).PadLeft(${numberOfDigits}, '0'))] ${filePath}"
}

Pop-Location

${fileEntries} | Out-File `
    -FilePath ${FILES_SECTION_FILE_PATH} `
    -Encoding 'utf8'  # Yes, we do need UTF-8-BOM.


Write-Output -InputObject $('-' * 42)
Write-Output -InputObject "Contents of '${FILES_SECTION_FILE_PATH}':"
Get-Content -Path ${FILES_SECTION_FILE_PATH}
Write-Output -InputObject $('-' * 42)
