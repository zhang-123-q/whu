<%@ Language="VBScript" %>
<% 
' 设置响应内容的编码为UTF-8
Response.CodePage = 65001
Response.Charset = "UTF-8"
%>
<% 
Option Explicit
Response.ContentType = "text/plain"
Response.Charset = "UTF-8"

' 初始化应用程序变量
Sub InitApplication()
    If IsEmpty(Application("players")) Then
        Application.Lock
        Application("players") = CreateObject("Scripting.Dictionary")
        Application("games") = CreateObject("Scripting.Dictionary")
        Application.Unlock
    End If
End Sub

' 主处理逻辑
Sub Main()
    Dim action, playerName, choice
    action = Request.QueryString("action")
    
    InitApplication()
    
    Select Case action
        Case "join"
            playerName = Request.QueryString("name")
            JoinGame(playerName)
        Case "choice"
            playerName = Request.QueryString("player")
            choice = Request.QueryString("choice")
            MakeChoice(playerName, choice)
        Case "poll"
            playerName = Request.QueryString("player")
            PollGameState(playerName)
        Case Else
            Response.Write "invalid action"
    End Select
End Sub

' 加入游戏
Sub JoinGame(playerName)
    Application.Lock
    If Not Application("players").Exists(playerName) Then
        Application("players").Add playerName, Now()
        Response.Write "success"
    Else
        Response.Write "name exists"
    End If
    Application.Unlock
End Sub

' 做出选择
Sub MakeChoice(playerName, choice)
    Application.Lock
    If Application("players").Exists(playerName) Then
        ' 检查是否有进行中的游戏
        Dim gameKey, opponent
        For Each gameKey In Application("games").Keys
            If InStr(gameKey, playerName) > 0 Then
                ' 已经有一个游戏包含此玩家
                opponent = Replace(gameKey, playerName, "")
                opponent = Replace(opponent, "|", "")
                
                If Not Application("games")(gameKey).Exists(playerName) Then
                    Application("games")(gameKey).Add playerName, choice
                    
                    ' 检查是否双方都做出了选择
                    If Application("games")(gameKey).Count = 2 Then
                        DetermineWinner gameKey
                    End If
                End If
                Application.Unlock
                Exit Sub
            End If
        Next
        
        ' 没有现有游戏，尝试匹配对手
        Dim otherPlayer, foundOpponent
        foundOpponent = False
        For Each otherPlayer In Application("players").Keys
            If otherPlayer <> playerName Then
                ' 检查这个对手是否已经在其他游戏中
                Dim inGame
                inGame = False
                For Each gameKey In Application("games").Keys
                    If InStr(gameKey, otherPlayer) > 0 Then
                        inGame = True
                        Exit For
                    End If
                Next
                
                If Not inGame Then
                    ' 创建新游戏
                    gameKey = playerName & "|" & otherPlayer
                    Application("games").Add gameKey, CreateObject("Scripting.Dictionary")
                    Application("games")(gameKey).Add playerName, choice
                    foundOpponent = True
                    Exit For
                End If
            End If
        Next
        
        If Not foundOpponent Then
            Response.Write "waiting"
        End If
    Else
        Response.Write "not joined"
    End If
    Application.Unlock
End Sub

' 轮询游戏状态
Sub PollGameState(playerName)
    Application.Lock
    Dim playersArray(), i, player, gameKey, gameState, opponent
    ReDim playersArray(Application("players").Count - 1)
    i = 0
    For Each player In Application("players").Keys
        playersArray(i) = player
        i = i + 1
    Next
    
    ' 查找当前玩家的游戏
    gameState = Empty
    For Each gameKey In Application("games").Keys
        If InStr(gameKey, playerName) > 0 Then
            opponent = Replace(gameKey, playerName, "")
            opponent = Replace(opponent, "|", "")
            
            Set gameState = Server.CreateObject("Scripting.Dictionary")
            gameState.Add "opponent", opponent
            gameState.Add "choices", Application("games")(gameKey)
            
            If Application("games")(gameKey).Count = 2 Then
                If Application("games")(gameKey).Exists("result") Then
                    gameState.Add "result", Application("games")(gameKey)("result")
                End If
            End If
            Exit For
        End If
    Next
    
    Application.Unlock
    
    ' 返回JSON数据
    Response.ContentType = "application/json"
    Response.Write "{"
    Response.Write """playerCount"":" & UBound(playersArray) + 1 & ","
    Response.Write """players"":[" & JoinArray(playersArray) & "]"
    
    If IsObject(gameState) Then
        Response.Write ",""gameState"":{"
        Response.Write """opponent"":""" & gameState("opponent") & ""","
        Response.Write """choices"":{"
        
        Dim choiceKeys, j
        choiceKeys = gameState("choices").Keys
        For j = 0 To gameState("choices").Count - 1
            If choiceKeys(j) <> "result" Then
                If j > 0 Then Response.Write ","
                Response.Write """" & choiceKeys(j) & """:""" & gameState("choices")(choiceKeys(j)) & """"
            End If
        Next
        
        Response.Write "}"
        
        If gameState.Exists("result") Then
            Response.Write ",""result"":""" & gameState("result") & """"
        End If
        
        Response.Write "}"
    End If
    
    Response.Write "}"
End Sub

' 判断胜负
Sub DetermineWinner(gameKey)
    Dim players, choices, p1, p2, c1, c2
    Set players = Application("games")(gameKey)
    
    Dim playerNames
    playerNames = players.Keys
    p1 = playerNames(0)
    p2 = playerNames(1)
    c1 = players(p1)
    c2 = players(p2)
    
    Dim result
    If c1 = c2 Then
        result = "平局!"
    ElseIf (c1 = "rock" And c2 = "scissors") Or _
           (c1 = "scissors" And c2 = "paper") Or _
           (c1 = "paper" And c2 = "rock") Then
        result = p1 & " 获胜!"
    Else
        result = p2 & " 获胜!"
    End If
    
    players.Add "result", result
    
    ' 5秒后清除游戏
    Server.Execute "AsyncCleanup.asp?gameKey=" & Server.URLEncode(gameKey)
End Sub

' 辅助函数：连接数组为字符串
Function JoinArray(arr)
    Dim i, result
    result = ""
    For i = 0 To UBound(arr)
        If i > 0 Then result = result & ","
        result = result & """" & arr(i) & """"
    Next
    JoinArray = result
End Function

Call Main()
%>