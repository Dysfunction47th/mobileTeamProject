@echo off
setlocal

echo =========================
echo WebSocket Server Start
echo =========================

REM 현재 IP 출력
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /C:"IPv4"') do (
    set IP=%%A
    goto :done
)

:done
echo My IP : %IP%
echo.

REM 시작 시간 저장
set START_TIME=%TIME%

REM 배치파일 위치로 이동
cd /d %~dp0

REM 서버 실행
dart run lib/backend/server/server.dart

REM 종료 시간 저장
set END_TIME=%TIME%

REM 실행 시간 계산
powershell -Command ^
"$start=[datetime]::Parse('%START_TIME%'); ^
 $end=[datetime]::Parse('%END_TIME%'); ^
 $diff=($end-$start).TotalSeconds; ^
 Write-Host ''; ^
 Write-Host '========================='; ^
 Write-Host ('Running Time : {0:N2} sec' -f $diff); ^
 Write-Host '========================='"

pause