@echo off
REM This file should be automatically inserted after a few lines of configuration
REM generated by the setup script. This comment should not be the first section
REM in the generated manage script.

REM Check if the work variable is defined and is a valid directory
if "%work%" == "" (
  @echo No work directory is defined! Maybe the manage script was not generated correctly?
  exit /b 1
)

REM Check if the work directory exists
if not exist "%work%" (
  @echo The work directory specified in the manage script cannot be found!
  exit /b 1
)

REM The container ID file should be in the same directory as this script
set container="%0\..\.container"

REM Use flag to check if a command was run
set done=0

if "%1" == "start" (
  call :docker_run
  set done=1
)


if "%1" == "test" (
  call :docker_run_test
  set done=1
)

if "%1" == "shell" (
  call :docker_shell
  set done=1
)

if "%1" == "stop" (
  call :docker_kill
  set done=1
)

if %done% == 0 (
  @echo this command manages the virtual linux container!
  @echo   start - start up the container in the background
  @echo   test - start up the container for testing in the background
  @echo   shell - open a shell in your running container
  @echo   stop - kill the container in the background
  exit /b 0
)

exit /b 0

:read_container
if exist "%container%" (
  set /p container_id=<"%container%"
  if "%container_id%" == "" (
    @echo The existing container file is invalid, restart the container.
    del "%container%"
    exit /b 1
  )
) else (
  @echo A container doesn't seem to be running...
  exit /b 1
)
exit /b 0

:docker_run_command
docker run -v "%work%":/work -d -t --security-opt seccomp:unconfined --cap-add SYS_PTRACE csci104 >"%container%"
exit /b 0

:docker_run
if not exist %container% (
  call :docker_run_command
  if not errorlevel 1 (
    @echo A container is running! Use the shell command to open a shell.
  ) else (
    @echo Startup failed, removing the container file.
    del "%container%"
    exit /b 1
  )
) else (
  @echo A container seems to be running, use the stop command to stop it.
  exit /b 1
)
exit /b 0

:docker_admin_run_command
docker run -v "%work%":/work -d -t --security-opt seccomp:unconfined --cap-add SYS_ADMIN csci104 >"%container%"
exit /b 0

:docker_run_test
if not exist %container% (
  call :docker_admin_run_command
  if not errorlevel 1 (
    @echo A container is running! Use the shell command to open a shell. WARNING: stop container when finished testing for system safety
  ) else (
    @echo Startup failed, removing the container file.
    del "%container%"
    exit /b 1
  )
) else (
  @echo A container seems to be running, use the stop command to stop it.
  exit /b 1
)
exit /b 0



:docker_shell
call :read_container
if not errorlevel 1 (
  docker exec -it "%container_id%" bash
)
exit /b

:docker_kill
call :read_container
if not errorlevel 1 (
  docker kill "%container_id%"
  del "%container%"
  @echo Container killed.
)
exit /b