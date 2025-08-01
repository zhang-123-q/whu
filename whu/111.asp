<%@ Language="VBScript" %>
<% Option Explicit %>

<%
' 系统配置
Const ADMIN_PASSWORD = "admin123"  ' 管理员密码
Const MAX_USER_MSG_LENGTH = 500    ' 普通用户留言长度限制
Const MAX_GUEST_MSG = 20           ' 普通用户最大留言条数

' 初始化数据
Dim cookieMessages, messagesArray, isAdmin
cookieMessages = Request.Cookies("GuestbookData")
isAdmin = (Request.Cookies("AdminAuth") = ADMIN_PASSWORD)

' 处理登录/登出
If Request.QueryString("action") = "login" Then
    If Request.Form("password") = ADMIN_PASSWORD Then
        Response.Cookies("AdminAuth") = ADMIN_PASSWORD
        Response.Cookies("AdminAuth").Expires = Date + 30
        isAdmin = True
    End If
ElseIf Request.QueryString("action") = "logout" Then
    Response.Cookies("AdminAuth") = ""
    isAdmin = False
End If

' 初始化留言数组
If cookieMessages = "" Then
    ReDim messagesArray(0)
Else
    messagesArray = Split(cookieMessages, "|#|")
End If

' 处理表单提交
If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request.Form("message") <> "" Then
    Dim name, message, newEntry, userType
    
    ' 获取用户身份
    If isAdmin Then
        name = "[管理员] " & Left(Server.HtmlEncode(Trim(Request.Form("name"))), 50)
        userType = "admin"
    Else
        name = Left(Server.HtmlEncode(Trim(Request.Form("name"))), 50)
        userType = "user"
    End If
    
    ' 处理留言内容
    If isAdmin Then
        message = Server.HtmlEncode(Trim(Request.Form("message"))) ' 管理员无长度限制
    Else
        message = Left(Server.HtmlEncode(Trim(Request.Form("message"))), MAX_USER_MSG_LENGTH)
    End If
    
    ' 构建新留言条目
    newEntry = userType & "||" & name & "||" & message & "||" & Now()
    
    ' 普通用户留言数量限制
    If Not isAdmin Then
        Dim userMsgCount, i
        userMsgCount = 0
        For i = 1 To UBound(messagesArray)
            If Split(messagesArray(i), "||")(0) = "user" Then
                userMsgCount = userMsgCount + 1
            End If
        Next
        
        If userMsgCount >= MAX_GUEST_MSG Then
            ' 移除最早的一条普通用户留言
            For i = 1 To UBound(messagesArray)
                If Split(messagesArray(i), "||")(0) = "user" Then
                    messagesArray(i) = ""
                    messagesArray = Filter(messagesArray, "", False)
                    Exit For
                End If
            Next
        End If
    End If
    
    ' 添加新留言
    ReDim Preserve messagesArray(UBound(messagesArray) + 1)
    messagesArray(UBound(messagesArray)) = newEntry
    
    ' 存储到Cookie
    Response.Cookies("GuestbookData") = Join(messagesArray, "|#|")
    Response.Cookies("GuestbookData").Expires = Date + 30
End If

' 处理删除操作（仅管理员）
If isAdmin And Request.QueryString("action") = "delete" Then
    Dim msgIndex
    msgIndex = CInt(Request.QueryString("index"))
    If msgIndex > 0 And msgIndex <= UBound(messagesArray) Then
        messagesArray(msgIndex) = ""
        messagesArray = Filter(messagesArray, "", False)
        Response.Cookies("GuestbookData") = Join(messagesArray, "|#|")
        Response.Cookies("GuestbookData").Expires = Date + 30
    End If
End If
%>

<!DOCTYPE html>
<html>
<head>
    <title>留言板系统</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial; max-width: 800px; margin: 0 auto; padding: 20px; }
        .message-form { background: #f8f9fa; padding: 20px; border-radius: 5px; }
        textarea { width: 100%; height: 100px; resize: vertical; }
        .message { 
            border-left: 3px solid #4285f4; 
            padding: 10px; 
            margin: 10px 0; 
            position: relative;
        }
        .admin-message { border-left-color: #f44336; }
        .author { font-weight: bold; color: #3367d6; }
        .admin-author { color: #f44336; }
        .date { color: #5f6368; font-size: 0.9em; }
        .delete-btn {
            position: absolute;
            right: 10px;
            top: 10px;
            color: #f44336;
            text-decoration: none;
        }
        .login-form {
            margin: 20px 0;
            padding: 15px;
            background: #e8f5e9;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h1>留言板系统</h1>
    
    <% If Not isAdmin Then %>
        <div class="login-form">
            <form method="post" action="?action=login">
                <h3>管理员登录</h3>
                <input type="password" name="password" placeholder="管理员密码">
                <button type="submit">登录</button>
            </form>
        </div>
    <% Else %>
        <div style="text-align:right;">
            <a href="?action=logout">退出管理</a>
        </div>
    <% End If %>
    
    <div class="message-form">
        <form method="post">
            <p><input type="text" name="name" placeholder="您的姓名" value="<%=IIf(isAdmin,"管理员","")%>" <%=IIf(isAdmin,"readonly","")%>></p>
            <p><textarea name="message" placeholder="留言内容" required></textarea></p>
            <button type="submit">提交留言</button>
        </form>
    </div>

    <h2>留言列表</h2>
    <%
    Dim i, msgParts, msgType
    If UBound(messagesArray) > 0 Then
        For i = UBound(messagesArray) To 1 Step -1
            msgParts = Split(messagesArray(i), "||")
            If UBound(msgParts) >= 3 Then
                msgType = msgParts(0)
                %>
                <div class="message <%=IIf(msgType="admin","admin-message","")%>">
                    <% If isAdmin Then %>
                        <a href="?action=delete&index=<%=i%>" class="delete-btn" onclick="return confirm('确定删除此留言？')">删除</a>
                    <% End If %>
                    <div class="author <%=IIf(msgType="admin","admin-author","")%>">
                        <%= msgParts(1) %>
                    </div>
                    <div class="date"><%= msgParts(3) %></div>
                    <div><%= Replace(msgParts(2), vbCrLf, "<br>") %></div>
                </div>
                <%
            End If
        Next
    Else
        Response.Write "<p>暂无留言</p>"
    End If
    %>
</body>
</html>