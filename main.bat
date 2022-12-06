@echo off

set WEBUI=%ROOT_DIR%\stable_diffusion_webui
set MODEL=%WEBUI%\models\model.ckpt
set SD1v4MODEL=C:\diffusion\stable-diffusion-webui\models\Stable-diffusion\sd-v1-4.ckpt

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


@if exist "%MODEL%" (
    for %%I in ("%MODEL%") do if "%%~zI" EQU "4265380512" (
        echo "Data files (weights) necessary for Stable Diffusion were already downloaded. Using the HuggingFace 4 GB Model."
        set MODEL_INSTALLED=T
    )
)

@if exist "%SD1v4MODEL%" (
    for %%I in ("%SD1v4MODEL%") do if "%%~zI" EQU "4265380512" (
        echo "Data files (weights) necessary for Stable Diffusion were already downloaded. Using the 4 GB Model."
        set MODEL_INSTALLED=T
    )
)

@if "%MODEL_INSTALLED%" == "F" (
    @echo "Downloading the model"
    @call curl -L -k https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4.ckpt > %MODEL%

    @if exist "%MODEL%" (
        for %%I in ("sd-v1-4.ckpt") do if "%%~zI" NEQ "4265380512" (
            echo. & echo "Error: The downloaded model file was invalid! Bytes downloaded: %%~zI" & echo.
            echo. & echo "Error downloading the data files (weights) for Stable Diffusion. Sorry about that, please run this installer again"
            pause
            exit /b
        )
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

@cd %WEBUI%
@rem @call webui-user.bat
@echo Calling webui-user.bat
@echo Finished.
@pause
