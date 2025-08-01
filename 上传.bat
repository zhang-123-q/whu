@echo off
cd /d "D:\1-编程\wdu"


git add .
git commit -m "自动提交：%date% %time%"
git push origin main


echo 代码已上传至GitHub！
pause