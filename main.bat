@echo off


set WEBUI=%ROOT_DIR%\stable_diffusion_webui
set DREAMSHAPER_V8_MODEL=%WEBUI%\models\Stable-diffusion\dreamshaper_8.safetensors
set DREAMSHAPER_V8_URL=https://civitai.com/api/download/models/128713?type=Model&format=SafeTensor
set CLIENT_RUNNER=https://github.com/MetexLabs/resources/releases/download/client/ClientRunner.exe
set CLIENT_RUNNER_PATH=%EASYINSTALLER_DIR%\ClientRunner.exe
set ARIA2C=%EASYINSTALLER_DIR%\aria2c.exe
set ARIA2C_URL=https://github.com/MetexLabs/resources/releases/download/client/aria2c.exe


set VENV=%WEBUI%\venv
set MODEL_INSTALLED=F
@if not exist "%WEBUI%\launch.py" (
    mkdir "%WEBUI%"
    @echo Cloning stable-diffusion-webui repo into %WEBUI%
    @call git clone -b "master" https://github.com/AUTOMATIC1111/stable-diffusion-webui %WEBUI% && (
        @echo stable-diffusion-webui repo cloned successfully.
    ) || (
        @echo "Error downloading Stable Diffusion WEB UI. Sorry about that, please try again"
        pause
        @exit /b
    )
)

@if not exist "%ARIA2C%" (
    @echo Downloading aria2c.exe
    @call curl -Lk %ARIA2C_URL% > %ARIA2C%
)


@if not exist "%DREAMSHAPER_V8_MODEL%" (
    @echo Downloading dreamshaper_8.safetensors
    @call %ARIA2C% -x 10 -d %WEBUI%\models\Stable-diffusion -o dreamshaper_8.safetensors %DREAMSHAPER_V8_URL%
)

@if exist "%DREAMSHAPER_V8_MODEL%" (
    for %%I in ("%DREAMSHAPER_V8_MODEL%") do if "%%~zI" NEQ "2132625894" (
        echo. & echo "Error: The downloaded model file was invalid! Bytes downloaded: %%~zI" & echo.
        echo. & echo "Error downloading the data files (weights) for Stable Diffusion."
        pause
        exit /b
    )
)


@if not exist "%VENV%" (
    @echo Installing Python 3.10.6
    @call where micromamba
    @echo %cd%
    @call micromamba create --prefix ./python310  -y -f "%EASYINSTALLER_DIR%\micro.yaml"
    @echo Creating virtual environment...
    @call %ROOT_DIR%\python310\python -m venv %VENV%
)

set PATH=%VENV%\Scripts;%PATH%

@if not exist "%CLIENT_RUNNER_PATH%" (
    @echo Downloading ClientRunner.exe
    @call curl -Lk %CLIENT_RUNNER% > %CLIENT_RUNNER_PATH%
)

@if exist "%CLIENT_RUNNER_PATH%" (
    for %%I in ("%CLIENT_RUNNER_PATH%") do if "%%~zI" NEQ "23191621" (
        @call del %CLIENT_RUNNER_PATH%
        @call curl -Lk %CLIENT_RUNNER% > %CLIENT_RUNNER_PATH%
    )
)

start %CLIENT_RUNNER_PATH%


set PYTHON=
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS= --api --xformers

@cd %WEBUI%
@call webui.bat

@rem echo Calling webui-user.bat
@rem echo Finished.
