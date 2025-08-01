<%@ Language="VBScript" %>
<% 
' 设置响应内容的编码为UTF-8
Response.CodePage = 65001
Response.Charset = "UTF-8"
%>
<% 
' 这个文件用于延迟清理完成的游戏
' 由于免费空间限制，使用简单的延迟方式

Dim gameKey
gameKey = Request.QueryString("gameKey")

If Not IsEmpty(gameKey) Then
    ' 等待5秒
    Server.ScriptTimeout = 10 ' 设置超时为10秒
    Dim waitUntil
    waitUntil = DateAdd("s", 5, Now())
    Do While Now() < waitUntil
        ' 简单等待
    Loop
    
    Application.Lock
    If Application("games").Exists(gameKey) Then
        Application("games").Remove(gameKey)
    End If
    Application.Unlock
End If
%>