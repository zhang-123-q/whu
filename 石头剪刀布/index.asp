<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>局域网石头剪刀布对战</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .choices button { font-size: 20px; padding: 10px 20px; margin: 10px; }
        #gameArea { margin: 20px auto; width: 500px; border: 1px solid #ccc; padding: 20px; }
        #status { font-weight: bold; margin: 10px; }
        #playerList { margin: 20px; text-align: left; }
    </style>
</head>
<body>
    <div id="gameArea">
        <h1>石头剪刀布对战</h1>
        <div>
            <input type="text" id="playerName" placeholder="输入你的名字">
            <button onclick="joinGame()">加入游戏</button>
        </div>
        
        <div id="gameControls" style="display:none;">
            <h2 id="status">等待对手...</h2>
            <div class="choices">
                <button onclick="makeChoice('rock')">✊ 石头</button>
                <button onclick="makeChoice('paper')">✋ 布</button>
                <button onclick="makeChoice('scissors')">✌ 剪刀</button>
            </div>
            <div id="result"></div>
        </div>
        
        <div id="playerList"></div>
    </div>

    <script>
        var currentPlayer = "";
        var pollInterval;
        
        function joinGame() {
            var name = document.getElementById("playerName").value.trim();
            if(name === "") {
                alert("请输入名字");
                return;
            }
            
            fetch("game.asp?action=join&name=" + encodeURIComponent(name))
                .then(response => response.text())
                .then(data => {
                    if(data === "success") {
                        currentPlayer = name;
                        document.getElementById("gameControls").style.display = "block";
                        document.getElementById("playerName").disabled = true;
                        startPolling();
                    } else {
                        alert("加入游戏失败: " + data);
                    }
                });
        }
        
        function makeChoice(choice) {
            fetch("game.asp?action=choice&player=" + encodeURIComponent(currentPlayer) + "&choice=" + choice)
                .then(response => response.text());
        }
        
        function startPolling() {
            pollInterval = setInterval(updateGameState, 500);
        }
        
        function updateGameState() {
            fetch("game.asp?action=poll&player=" + encodeURIComponent(currentPlayer))
                .then(response => response.json())
                .then(data => {
                    document.getElementById("playerList").innerHTML = 
                        "<h3>在线玩家(" + data.playerCount + "):</h3><ul>" + 
                        data.players.map(p => "<li>" + p + "</li>").join("") + "</ul>";
                    
                    if(data.gameState) {
                        document.getElementById("status").innerHTML = "游戏进行中";
                        if(data.gameState.result) {
                            let resultText = "你出了: " + data.gameState.choices[currentPlayer] + "<br>";
                            resultText += "对手出了: " + data.gameState.choices[data.gameState.opponent] + "<br>";
                            resultText += "结果: " + data.gameState.result;
                            document.getElementById("result").innerHTML = resultText;
                        }
                    }
                });
        }
    </script>
</body>
</html>