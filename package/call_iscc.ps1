
param (
    [Parameter(Mandatory = $true)][string]${ISCC_PATH}
    , [Parameter(Mandatory = $true)][string]${ISS_COMPRESSION}
    , [Parameter(Mandatory = $true)][string]${TARGET}
    , [Parameter(Mandatory = $true)][string]${DEPLOY_DIR_PATH}

    , [Parameter(Mandatory = $true)][string]${ISS_INSTALLER_FILE_PATH}
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${scriptLocationDirPath} = `
    Split-Path -Path $MyInvocation.MyCommand.Path -Parent


${exeFilePath} = `
    Join-Path -Path ${DEPLOY_DIR_PATH} -ChildPath "${TARGET}.exe"

${issFileEntriesIncludedFilePath} = `
    [System.IO.Path]::GetTempFileName() | `
    Rename-Item -NewName { $_ -replace @('\.tmp$', '.iss') } -PassThru

${outputInstallerDirPath} = `
    Split-Path -Path ${ISS_INSTALLER_FILE_PATH} -Parent
${outputInstallerFileBaseName} = `
    [System.IO.Path]::GetFileNameWithoutExtension(${ISS_INSTALLER_FILE_PATH})


Write-Output -InputObject "exeFilePath = ${exeFilePath}"
Get-Item -Path ${exeFilePath} | Format-List

Write-Output -InputObject "issFileEntriesIncludedFilePath = ${issFileEntriesIncludedFilePath}"

Write-Output -InputObject "outputInstallerDirPath = ${outputInstallerDirPath}"
Write-Output -InputObject "outputInstallerFileBaseName = ${outputInstallerFileBaseName}"


# Generate the entries of Inno Setup's [Files] section.

$issParameters = @{
    'SOURCE_DIR_PATH'         = ${DEPLOY_DIR_PATH}
    'FILES_SECTION_FILE_PATH' = ${issFileEntriesIncludedFilePath}
}

& "${scriptLocationDirPath}\iss\iss_file_entries_generator.ps1" @issParameters


# ISCC.exe it.
#   https://jrsoftware.org/ishelp/topic_compilercmdline.htm
#   https://jrsoftware.org/ispphelp/topic_isppcc.htm

& ${ISCC_PATH} @(
    , $('/O' + ${outputInstallerDirPath})
    , $('/F' + ${outputInstallerFileBaseName})
    , $('/D' + "MY_SOURCE_DIR_PATH=${DEPLOY_DIR_PATH}")
    , $('/D' + "MY_FILES_SECTION_FILE_PATH=${issFileEntriesIncludedFilePath}")
    , $('/D' + "MY_APP_NAME=${TARGET}")
    , $('/D' + "MY_COMPRESSION=${ISS_COMPRESSION}")
    , "${scriptLocationDirPath}\iss\iss_main.iss"
)

if ($LASTEXITCODE -ne 0) {
    throw "${ISCC_PATH} exited with code $LASTEXITCODE."
}
