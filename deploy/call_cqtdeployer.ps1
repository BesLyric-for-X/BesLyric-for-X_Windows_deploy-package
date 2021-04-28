
param (
    [Parameter(Mandatory = $true)][string]${CQTDEPLOYER_PATH}
    , [Parameter(Mandatory = $true)][string]${QMAKE_PATH}
    , [Parameter(Mandatory = $true)][string]${LIB_DIR_PATH}
    , [Parameter(Mandatory = $true)][string]${TARGET}
    , [Parameter(Mandatory = $true)][string]${INSTALL_ROOT}

    , [Parameter(Mandatory = $true)][string]${DEPLOY_DIR_PATH}
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${exeFilePath} = `
    Join-Path -Path ${INSTALL_ROOT} -ChildPath "${TARGET}.exe"

${innoSetupRequiredFilePaths} = @(
    , 'Beslyric.ico'
    , 'version.txt'
) | ForEach-Object { Join-Path -Path ${INSTALL_ROOT} -ChildPath $_ }

${opensslFilePaths} = @(
    , 'libssl-1_1-x64.dll'
    , 'libcrypto-1_1-x64.dll'
) | ForEach-Object { Join-Path -Path ${LIB_DIR_PATH} -ChildPath $_ }


Write-Output -InputObject "exeFilePath = ${exeFilePath}"
Get-Item -Path ${exeFilePath} | Format-List

Write-Output -InputObject "innoSetupRequiredFilePaths = ${innoSetupRequiredFilePaths}"
Get-Item -Path ${innoSetupRequiredFilePaths} | Format-List

Write-Output -InputObject "opensslFilePaths = ${opensslFilePaths}"
Get-Item -Path ${opensslFilePaths} | Format-List


${deployableFilePaths} = @(
    , ${exeFilePath}
    , $(${innoSetupRequiredFilePaths} -join ',')
    , $(${opensslFilePaths} -join ',')
) -join ','


# CQtDeployer -bin "all,deployable,files"
#   https://github.com/QuasarApp/CQtDeployer/issues/394

& ${CQTDEPLOYER_PATH} @(
    , '-bin', ${deployableFilePaths}
    , '-libDir', ${LIB_DIR_PATH}
    , '-targetDir', ${DEPLOY_DIR_PATH}
    , '-qmake', ${QMAKE_PATH}
    , '-verbose', '3'
    , 'noTranslations', 'clear'
)

if ($LASTEXITCODE -ne 0) {
    throw "${CQTDEPLOYER_PATH} exited with code $LASTEXITCODE."
}
