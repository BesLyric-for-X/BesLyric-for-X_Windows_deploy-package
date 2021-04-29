
param (
    [Parameter(Mandatory = $true)][string]${ENIGMAVBCONSOLE_PATH}
    , [Parameter(Mandatory = $true)][bool]${DOES_EVB_COMPRESS_FILES}
    , [Parameter(Mandatory = $true)][string]${TARGET}
    , [Parameter(Mandatory = $true)][string]${DEPLOY_DIR_PATH}

    , [Parameter(Mandatory = $true)][string]${EVB_BOX_FILE_PATH}
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${scriptLocationDirPath} = `
    Split-Path -Path $MyInvocation.MyCommand.Path -Parent


${exeFilePath} = `
    Join-Path -Path ${DEPLOY_DIR_PATH} -ChildPath "${TARGET}.exe"

${evbProjectFilePath} = `
    [System.IO.Path]::GetTempFileName() | `
    Rename-Item -NewName { $_ -replace @('\.tmp$', '.evb') } -PassThru


Write-Output -InputObject "exeFilePath = ${exeFilePath}"
Get-Item -Path ${exeFilePath} | Format-List

Write-Output -InputObject "evbProjectFilePath = ${evbProjectFilePath}"


# Generate Enigma Virtual Box project file.

$evbProjectGeneratorParameters = @{
    'SOURCE_DIR_PATH'     = ${DEPLOY_DIR_PATH}
    'EXE_FILE_PATH'       = ${exeFilePath}
    'PROJECT_FILE_PATH'   = ${evbProjectFilePath}
    'DOES_COMPRESS_FILES' = ${DOES_EVB_COMPRESS_FILES}
    'BOXED_EXE_FILE_PATH' = ${EVB_BOX_FILE_PATH}
}

& "${scriptLocationDirPath}\evb\evb_project_generator.ps1" @evbProjectGeneratorParameters


# enigmavbconsole.exe it.

& ${ENIGMAVBCONSOLE_PATH} ${evbProjectFilePath}

if ($LASTEXITCODE -ne 0) {
    throw "${ENIGMAVBCONSOLE_PATH} exited with code $LASTEXITCODE."
}
