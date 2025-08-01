class Gomoku {
    constructor() {
        this.canvas = document.getElementById('board');
        this.ctx = this.canvas.getContext('2d');
        this.cellSize = 30;
        this.boardSize = 15;
        this.board = Array(this.boardSize).fill().map(() => Array(this.boardSize).fill(0));
        this.currentPlayer = 1; // 1: 黑棋, 2: 白棋
        this.gameActive = true;
    }

    init() {
        this.drawBoard();
        this.bindEvents();
    }

    drawBoard() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        // 绘制网格
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 1;
        for (let i = 0; i < this.boardSize; i++) {
            // 横线
            this.ctx.beginPath();
            this.ctx.moveTo(this.cellSize/2, this.cellSize/2 + i*this.cellSize);
            this.ctx.lineTo(this.canvas.width - this.cellSize/2, this.cellSize/2 + i*this.cellSize);
            this.ctx.stroke();
            
            // 竖线
            this.ctx.beginPath();
            this.ctx.moveTo(this.cellSize/2 + i*this.cellSize, this.cellSize/2);
            this.ctx.lineTo(this.cellSize/2 + i*this.cellSize, this.canvas.height - this.cellSize/2);
            this.ctx.stroke();
        }
        
        // 绘制星位
        const starPoints = [3, 7, 11];
        starPoints.forEach(x => {
            starPoints.forEach(y => {
                this.drawStar(x, y);
            });
        });
    }

    drawStar(x, y) {
        this.ctx.fillStyle = '#000';
        this.ctx.beginPath();
        this.ctx.arc(
            this.cellSize/2 + x*this.cellSize,
            this.cellSize/2 + y*this.cellSize,
            3, 0, Math.PI*2
        );
        this.ctx.fill();
    }

    drawPiece(x, y, player) {
        this.ctx.beginPath();
        this.ctx.arc(
            this.cellSize/2 + x*this.cellSize,
            this.cellSize/2 + y*this.cellSize,
            this.cellSize/2 - 2, 0, Math.PI*2
        );
        
        const gradient = this.ctx.createRadialGradient(
            this.cellSize/2 + x*this.cellSize - 5,
            this.cellSize/2 + y*this.cellSize - 5,
            2,
            this.cellSize/2 + x*this.cellSize,
            this.cellSize/2 + y*this.cellSize,
            this.cellSize/2 - 2
        );
        
        if (player === 1) { // 黑棋
            gradient.addColorStop(0, '#666');
            gradient.addColorStop(1, '#000');
        } else { // 白棋
            gradient.addColorStop(0, '#fff');
            gradient.addColorStop(1, '#ddd');
        }
        
        this.ctx.fillStyle = gradient;
        this.ctx.fill();
        this.ctx.strokeStyle = '#333';
        this.ctx.stroke();
    }

    bindEvents() {
        this.canvas.addEventListener('click', (e) => {
            if (!this.gameActive) return;
            
            const rect = this.canvas.getBoundingClientRect();
            const x = Math.floor((e.clientX - rect.left) / this.cellSize);
            const y = Math.floor((e.clientY - rect.top) / this.cellSize);
            
            if (x >= 0 && x < this.boardSize && y >= 0 && y < this.boardSize) {
                this.handleMove(x, y);
            }
        });
    }

    handleMove(x, y) {
        if (this.board[x][y] !== 0) return;
        
        this.board[x][y] = this.currentPlayer;
        this.drawPiece(x, y, this.currentPlayer);
        
        // 发送落子数据（需配合socket-client.js）
        if (window.gameConnection) {
            window.gameConnection.sendMove(x, y);
        }
        
        if (this.checkWin(x, y)) {
            this.showMessage(`${this.currentPlayer === 1 ? '黑棋' : '白棋'}获胜！`);
            this.gameActive = false;
            return;
        }
        
        this.currentPlayer = 3 - this.currentPlayer; // 切换玩家
        this.updateStatus();
    }

    checkWin(x, y) {
        const directions = [
            [1, 0], [0, 1], [1, 1], [1, -1] // 横、竖、斜、反斜
        ];
        
        return directions.some(([dx, dy]) => {
            let count = 1;
            
            // 正向检测
            for (let i = 1; i < 5; i++) {
                const nx = x + i*dx, ny = y + i*dy;
                if (nx >= 0 && nx < this.boardSize && 
                    ny >= 0 && ny < this.boardSize && 
                    this.board[nx][ny] === this.currentPlayer) {
                    count++;
                } else {
                    break;
                }
            }
            
            // 反向检测
            for (let i = 1; i < 5; i++) {
                const nx = x - i*dx, ny = y - i*dy;
                if (nx >= 0 && nx < this.boardSize && 
                    ny >= 0 && ny < this.boardSize && 
                    this.board[nx][ny] === this.currentPlayer) {
                    count++;
                } else {
                    break;
                }
            }
            
            return count >= 5;
        });
    }

    updateStatus() {
        const playerText = this.currentPlayer === 1 ? '黑棋' : '白棋';
        document.getElementById('current-player').textContent = playerText;
    }

    showMessage(msg) {
        document.getElementById('message').textContent = msg;
    }
}