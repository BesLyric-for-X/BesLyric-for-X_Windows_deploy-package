
param (
    [Parameter(Mandatory = $true)][string]${WINDEPLOYQT_PATH}
    , [Parameter(Mandatory = $true)][string]${LIB_DIR_PATH}
    , [Parameter(Mandatory = $true)][string]${TARGET}
    , [Parameter(Mandatory = $true)][string]${INSTALL_ROOT}
    , [Parameter(Mandatory = $true)][switch]${INCLUDE_PDB}

    , [Parameter(Mandatory = $true)][string]${DEPLOY_DIR_PATH}
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0


$PSBoundParameters | Format-List


${exeFilePath} = `
    Join-Path -Path ${INSTALL_ROOT} -ChildPath "${TARGET}.exe"

if (${INCLUDE_PDB}) {
    ${pdbFilePath} = `
        Join-Path -Path ${INSTALL_ROOT} -ChildPath "${TARGET}.pdb"
}

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

    # OpenSSL x64
    , 'libssl-1_1-x64.dll'
    , 'libcrypto-1_1-x64.dll'
) | ForEach-Object { Join-Path -Path ${LIB_DIR_PATH} -ChildPath $_ }


Write-Output -InputObject "exeFilePath = ${exeFilePath}"
Get-Item -Path ${exeFilePath} | Format-List

Write-Output -InputObject "innoSetupRequiredFilePaths = ${innoSetupRequiredFilePaths}"
Get-Item -Path ${innoSetupRequiredFilePaths} | Format-List

Write-Output -InputObject "thirdPartyLibraryFilePaths = ${thirdPartyLibraryFilePaths}"
Get-Item -Path ${thirdPartyLibraryFilePaths} | Format-List


New-Item -Path ${DEPLOY_DIR_PATH} -ItemType Directory -Force


Copy-Item -Path ${exeFilePath} -Destination ${DEPLOY_DIR_PATH} -PassThru

if (${INCLUDE_PDB}) {
    Copy-Item -Path ${pdbFilePath} -Destination ${DEPLOY_DIR_PATH} -PassThru
}

Copy-Item -Path ${innoSetupRequiredFilePaths} -Destination ${DEPLOY_DIR_PATH} -PassThru

Copy-Item -Path ${thirdPartyLibraryFilePaths} -Destination ${DEPLOY_DIR_PATH} -PassThru


& ${WINDEPLOYQT_PATH} @(
    , '--plugindir', "${DEPLOY_DIR_PATH}\plugins"
    , '--no-translations'
    , '--no-system-d3d-compiler'
    , '--compiler-runtime'
    , '--no-opengl-sw'
    , '--verbose', '2'
    , ${DEPLOY_DIR_PATH}
)

if ($LASTEXITCODE -ne 0) {
    throw "${WINDEPLOYQT_PATH} exited with code $LASTEXITCODE."
}
