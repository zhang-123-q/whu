@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =============================================
:: 第一部分：智能路径检测（兼容所有Windows版本）
:: =============================================
set "script_path=%~dp0"
echo [信息] 脚本位置：%script_path%

:: 自动检测项目根目录
if exist "%script_path%.git\" (
    set "project_path=%script_path%"
) else (
    pushd "%script_path%..\"
    if exist ".git\" (
        set "project_path=%cd%"
    ) else (
        echo [错误] 未找到Git仓库！
        pause
        exit /b 1
    )
    popd
)

:: =============================================
:: 第二部分：兼容的时间戳获取方案
:: =============================================
:: 方案1：使用PowerShell获取时间戳（首选）
for /f "delims=" %%a in ('powershell -command "Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'"') do (
    set "date_time=%%a"
)

:: 如果PowerShell不可用，使用备用方案
if not defined date_time (
    echo [警告] 使用备用时间格式
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "date=%%a-%%b-%%c"
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "time=%%a:%%b"
    set "date_time=%date%_%time%"
)

:: =============================================
:: 第三部分：Git操作流程
:: =============================================
echo [信息] 项目目录：%project_path%
cd /d "%project_path%"

git add .
git commit -m "自动提交：[%date_time%]"
if errorlevel 1 (
    echo [信息] 没有需要提交的更改
) else (
    git push origin main
    if errorlevel 1 (
        echo [错误] 推送失败！
    ) else (
        echo.
        echo [成功] 代码已成功同步到GitHub
        echo 仓库地址：https://github.com/zhang-123-q/whu
        echo 提交时间：%date_time%
        echo.
    )
)

pause