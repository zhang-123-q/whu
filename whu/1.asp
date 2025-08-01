<%@ Language=VBScript %>
<% 
' 设置响应内容的编码为UTF-8
Response.CodePage = 65001
Response.Charset = "UTF-8"
%>
<%
' 声明变量
Dim num1, num2, result, operation
Dim hasError, errorMessage

' 初始化变量
hasError = False
errorMessage = ""

' 检查表单是否已提交
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    ' 获取表单数据
    num1 = Request.Form("num1")
    num2 = Request.Form("num2")
    operation = Request.Form("operation")
    
    ' 验证输入
    If Not IsNumeric(num1) Or Not IsNumeric(num2) Then
        hasError = True
        errorMessage = "请输入有效的数字!"
    Else
        ' 转换为数字
        num1 = CDbl(num1)
        num2 = CDbl(num2)
        
        ' 执行计算
        Select Case operation
            Case "add"
                result = num1 + num2
            Case "subtract"
                result = num1 - num2
            Case "multiply"
                result = num1 * num2
            Case "divide"
                If num2 = 0 Then
                    hasError = True
                    errorMessage = "除数不能为零!"
                Else
                    result = num1 / num2
                End If
            Case Else
                hasError = True
                errorMessage = "无效的操作!"
        End Select
    End If
End If
%>

<!DOCTYPE html>
<html>
<head>
    <title>ASP 网页计算器</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .calculator {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"], select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .result {
            margin-top: 20px;
            padding: 10px;
            background-color: #e9f7ef;
            border-radius: 4px;
        }
        .error {
            color: red;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="calculator">
        <h1>ASP 网页计算器</h1>
        
        <form method="post" action="">
            <div class="form-group">
                <label for="num1">第一个数字:</label>
                <input type="text" id="num1" name="num1" value="<%= num1 %>" required>
            </div>
            
            <div class="form-group">
                <label for="operation">运算:</label>
                <select id="operation" name="operation">
                    <option value="add" <% If operation = "add" Then Response.Write "selected" %>>加 (+)</option>
                    <option value="subtract" <% If operation = "subtract" Then Response.Write "selected" %>>减 (-)</option>
                    <option value="multiply" <% If operation = "multiply" Then Response.Write "selected" %>>乘 (×)</option>
                    <option value="divide" <% If operation = "divide" Then Response.Write "selected" %>>除 (÷)</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="num2">第二个数字:</label>
                <input type="text" id="num2" name="num2" value="<%= num2 %>" required>
            </div>
            
            <div class="form-group">
                <input type="submit" value="计算">
            </div>
        </form>
        
        <% If Request.ServerVariables("REQUEST_METHOD") = "POST" And Not hasError Then %>
            <div class="result">
                <strong>计算结果:</strong> 
                <%= num1 %> 
                <% 
                Select Case operation
                    Case "add": Response.Write "+"
                    Case "subtract": Response.Write "-"
                    Case "multiply": Response.Write "×"
                    Case "divide": Response.Write "÷"
                End Select 
                %> 
                <%= num2 %> = <%= result %>
            </div>
        <% ElseIf hasError Then %>
            <div class="error">
                <%= errorMessage %>
            </div>
        <% End If %>
    </div>
</body>
</html>