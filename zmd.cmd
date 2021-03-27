:: ZMD, a Windows command line.
:: Main File

:: Loading Sequence
:load
@echo off
@title ZMD is loading...
@setlocal ENABLEEXTENSIONS
chcp 65001 >NUL

:: Variables

:: We use %~dp0 here to account for whatever directory ZMD is running in - this will always specify the script directory.
@set mainDir=%~dp0

:: Convenience™
@set addons=%mainDir%addons
@set core=%mainDir%core
@set api=%core%\api
@set functions=%core%\functions
@set locales=%mainDir%locales

:: Check if the user folder exists - if not, create one.
if NOT exist %mainDir%\user (
    md %mainDir%\user\
)

@set userFolder=%mainDir%\user

:: Check if the config exists - if not, create it!
:configHandler
if NOT exist %userFolder%\config.cmd (
    call %functions%\saveConfig.cmd
    call %userFolder%\config.cmd
) ELSE (
    set userFolder=%mainDir%\user
    call %userFolder%\config.cmd
)

:: Check if the current language file actually exists. If yes, then call it. Else, error.
:i18nHandler
if exist %locales%\%language%.cmd (
    if not exist %locales%\en-gb.cmd (
        echo [Internal error] Backup language file invalid.
        echo Press any key to close the program.
        echo We'd recommend re-cloning ZMD.
        pause >NUL
        exit
    )
    :: Here, we call the backup language file first, as to stop any "ECHO is on." strings being printed when a language entry is invalid.
    call %locales%\en-gb.cmd
    call %locales%\%language%.cmd
    goto welcomePrompt
) else (
    if not exist %locales%\en-gb.cmd (
        echo [Internal error] Backup language file invalid.
        echo Press any key to close the program.
        echo We'd recommend re-cloning ZMD.
        pause >NUL
        exit
    )
    echo [Internal error] Language file invalid, defaulting to en-gb.
    call %locales%\en-gb.cmd
    echo.
    goto welcomePrompt
)

:: Welcome Prompt Function
:welcomePrompt
echo %i18nWelcome%
goto command

:: Command Handler Function
:command
:: Re-call the language file each time the command handler is used.
:: Shouldn't cause slowdown, unless you're using an absolute potato.
call %locales%\%language%.cmd

:: Remove DelayedExpansion because AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA I despise it
setlocal DisableDelayedExpansion

:: Set the program title, in case it has been overwritten
title ZMD

echo.
echo ┌──(%USERNAME%@%ComputerName%)-[~%CD%]
set /p input="└─$ "

title ZMD - %input%

if exist %core%\builtins\%input%\*.manifest (
    echo.
    call %core%\builtins\%input%\index.cmd
    goto command
) else (
    if exist %addons%\plugins\%input%\*.manifest (
        echo.
        :: Here, we "sandbox" any plugins that run, making them run locally in their own file. However, we do give them some variable access.
        setlocal
        if exist %userFolder%\addonData\permissions\%input%.cmd (
            call %userFolder%\addonData\permissions\%input%.cmd
        )
        @set api=%~dp0core\api
        if exist %~dp0user\ (
            @set userFolder=%~dp0user
        )
        call %addons%\plugins\%input%\index.cmd
        endlocal
        goto command
    ) else (
        echo %i18nInvalidCommand%
        goto command
    )
)
