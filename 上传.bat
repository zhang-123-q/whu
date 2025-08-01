@echo off
:: 切换到项目目录（如果脚本不在项目目录）
cd /d "D:\1-编程\wdu"

:: Git 操作
git add .
git commit -m "自动提交：%date% %time%"
git push origin main

:: 可选：完成后提示
echo 代码已上传至GitHub！
pause