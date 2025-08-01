@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 设置正确的项目路径（替换为你的实际路径）
set "project_path=D:\1-编程\wdu"

:: 检查路径是否存在
if not exist "%project_path%" (
    echo 错误：项目路径不存在！请检查路径：%project_path%
    pause
    exit /b 1
)

:: 进入项目目录
cd /d "%project_path%"

:: 获取当前时间（解决中文乱码）
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set date=%%a-%%b-%%c)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (set time=%%a-%%b)

:: Git 操作
git add .
git commit -m "自动提交：[%date% %time%]"
git push origin main

:: 结果提示（中文显示正常）
echo.
echo [成功] 代码已上传至 GitHub 仓库！
echo 仓库地址：https://github.com/zhang-123-q/whu
pause