@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =============================================
:: 第一部分：智能路径检测（自动获取脚本所在位置）
:: =============================================
set "script_path=%~dp0"
echo 脚本所在路径：%script_path%

:: 检查是否在项目根目录中（包含.git文件夹）
if exist "%script_path%.git\" (
    set "project_path=%script_path%"
) else (
    :: 如果不是，尝试向上搜索一级
    pushd "%script_path%..\"
    if exist ".git\" (
        set "project_path=%cd%"
    ) else (
        echo [错误] 未找到Git项目目录！
        echo 请确保脚本放在项目根目录或其子目录中
        pause
        exit /b 1
    )
    popd
)

:: =============================================
:: 第二部分：安全的Git操作
:: =============================================
echo 正在切换到项目目录：%project_path%
cd /d "%project_path%"

:: 获取精确时间戳（兼容所有语言环境）
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set "date_time=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!_!datetime:~8,2!:!datetime:~10,2!:!datetime:~12,2!"

:: 执行Git操作
git add .
git commit -m "自动提交：[%date_time%]"
if errorlevel 1 (
    echo [警告] 没有需要提交的更改
) else (
    git push origin main
    if errorlevel 1 (
        echo [错误] 推送失败！
    ) else (
        echo.
        echo [成功] 代码已上传至 GitHub 仓库！
        echo 仓库地址：https://github.com/zhang-123-q/whu
        echo 最近提交：%date_time%
        echo.
    )
)

pause