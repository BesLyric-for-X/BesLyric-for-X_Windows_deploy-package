
param (
    [Parameter(Mandatory = $true)][string]${WINDEPLOYQT_PATH}
    , [Parameter(Mandatory = $true)][string]${MINGW_BIN_DIR_PATH}
    , [Parameter(Mandatory = $true)][string]${LIB_DIR_PATH}
    , [Parameter(Mandatory = $true)][string]${TARGET}
    , [Parameter(Mandatory = $true)][string]${INSTALL_ROOT}

    , [Parameter(Mandatory = $true)][string]${DEPLOY_DIR_PATH}
)


#Requires -Version 7
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${exeFilePath} = `
    Join-Path -Path ${INSTALL_ROOT} -ChildPath "${TARGET}.exe"

${innoSetupRequiredFilePaths} = @(
    , 'Beslyric.ico'
    , 'version.txt'
) | ForEach-Object { Join-Path -Path ${INSTALL_ROOT} -ChildPath $_ }

${thirdPartyLibraryFilePaths} = @(
    # FFmpeg
    , 'avcodec-58.dll'
    , 'avformat-58.dll'
    , 'avutil-56.dll'
    , 'swresample-3.dll'

    # SDL
    , 'SDL2.dll'

    # OpenSSL x86
    , 'libssl-1_1.dll'
    , 'libcrypto-1_1.dll'
) | ForEach-Object { Join-Path -Path ${LIB_DIR_PATH} -ChildPath $_ }


Write-Output -InputObject "exeFilePath = ${exeFilePath}"
Get-Item -Path ${exeFilePath} | Format-List

Write-Output -InputObject "innoSetupRequiredFilePaths = ${innoSetupRequiredFilePaths}"
Get-Item -Path ${innoSetupRequiredFilePaths} | Format-List

Write-Output -InputObject "thirdPartyLibraryFilePaths = ${thirdPartyLibraryFilePaths}"
Get-Item -Path ${thirdPartyLibraryFilePaths} | Format-List


New-Item -Path ${DEPLOY_DIR_PATH} -ItemType Directory -Force


Copy-Item -Path ${exeFilePath} -Destination ${DEPLOY_DIR_PATH} -PassThru

Copy-Item -Path ${innoSetupRequiredFilePaths} -Destination ${DEPLOY_DIR_PATH} -PassThru

Copy-Item -Path ${thirdPartyLibraryFilePaths} -Destination ${DEPLOY_DIR_PATH} -PassThru


${oldEnvPath} = ${Env:\Path}
${Env:\Path} += ";${MINGW_BIN_DIR_PATH}"

& ${WINDEPLOYQT_PATH} @(
    , '--plugindir', "${DEPLOY_DIR_PATH}\plugins"
    , '--no-translations'
    , '--no-system-d3d-compiler'
    , '--compiler-runtime'
    , '--no-angle'
    , '--no-opengl-sw'
    , '--verbose', '2'
    , ${DEPLOY_DIR_PATH}
)

${Env:\Path} = ${oldEnvPath}

if ($LASTEXITCODE -ne 0) {
    throw "${WINDEPLOYQT_PATH} exited with code $LASTEXITCODE."
}
