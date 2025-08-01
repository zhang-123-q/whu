// games/gomoku/gomoku.js
class Gomoku {
    constructor() {
      // 棋盘初始化
      this.canvas = document.getElementById('board');
      this.ctx = this.canvas.getContext('2d');
      this.cellSize = 30;
      this.boardSize = 15;
      this.board = Array(this.boardSize).fill().map(() => Array(this.boardSize).fill(0));
      this.currentPlayer = 1; // 1: 黑棋, 2: 白棋
      this.gameActive = true;
      this.roomId = null;
      this.isOnline = false;
      
      // DOM 元素
      this.statusElement = document.getElementById('current-player');
      this.messageElement = document.getElementById('message');
      this.inviteButton = document.getElementById('invite-btn');
    }
  
    /**
     * 初始化游戏
     * @param {string|null} roomId 房间ID（联机模式使用）
     */
    init(roomId = null) {
      this.drawBoard();
      this.bindEvents();
      
      if (roomId) {
        this.roomId = roomId;
        this.isOnline = true;
        this.initOnline();
        this.updateStatus('等待对手连接...');
      } else {
        this.updateStatus();
      }
    }
  
    /**
     * 初始化联机模式
     */
    initOnline() {
      if (!window.firebase) {
        console.error('Firebase 未加载！');
        return;
      }
  
      // 监听对手落子
      window.firebase.listenMoves(this.roomId, (move) => {
        if (move.player !== this.currentPlayer && this.gameActive) {
          this.handleOpponentMove(move.x, move.y);
        }
      });
  
      // 设置邀请按钮
      this.inviteButton.onclick = () => {
        const inviteLink = `${location.origin}/games/gomoku?room=${this.roomId}`;
        navigator.clipboard.writeText(inviteLink)
          .then(() => this.showMessage('邀请链接已复制！'))
          .catch(() => this.showMessage('复制失败，请手动分享URL'));
      };
      this.inviteButton.style.display = 'block';
    }
  
    /**
     * 绘制棋盘
     */
    drawBoard() {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      
      // 绘制网格线
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
      const starPoints = [3, 7, 11]; // 棋盘上的星位坐标
      starPoints.forEach(x => {
        starPoints.forEach(y => {
          this.drawStar(x, y);
        });
      });
      
      // 重绘已有棋子
      for (let x = 0; x < this.boardSize; x++) {
        for (let y = 0; y < this.boardSize; y++) {
          if (this.board[x][y] !== 0) {
            this.drawPiece(x, y, this.board[x][y]);
          }
        }
      }
    }
  
    /**
     * 绘制星位标记
     */
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
  
    /**
     * 绑定事件监听
     */
    bindEvents() {
      this.canvas.addEventListener('click', (e) => {
        if (!this.gameActive) return;
        
        const rect = this.canvas.getBoundingClientRect();
        const x = Math.floor((e.clientX - rect.left) / this.cellSize);
        const y = Math.floor((e.clientY - rect.top) / this.cellSize);
        
        if (this.isValidMove(x, y)) {
          this.handleMove(x, y);
        }
      });
    }
  
    /**
     * 验证落子位置是否有效
     */
    isValidMove(x, y) {
      return (
        x >= 0 && x < this.boardSize &&
        y >= 0 && y < this.boardSize &&
        this.board[x][y] === 0
      );
    }
  
    /**
     * 处理落子
     */
    handleMove(x, y) {
      this.board[x][y] = this.currentPlayer;
      this.drawPiece(x, y, this.currentPlayer);
      
      // 联机模式：发送落子数据
      if (this.isOnline && window.firebase) {
        window.firebase.sendMove(this.roomId, x, y, this.currentPlayer);
      }
      
      // 检查胜负
      if (this.checkWin(x, y)) {
        const winner = this.currentPlayer === 1 ? '黑棋' : '白棋';
        this.endGame(`${winner}获胜！`);
        return;
      }
      
      // 切换玩家
      this.switchPlayer();
    }
  
    /**
     * 处理对手落子
     */
    handleOpponentMove(x, y) {
      this.board[x][y] = 3 - this.currentPlayer; // 对手的player值
      this.drawPiece(x, y, 3 - this.currentPlayer);
      
      if (this.checkWin(x, y)) {
        const winner = this.currentPlayer === 1 ? '白棋' : '黑棋';
        this.endGame(`${winner}获胜！`);
      } else {
        this.updateStatus(); // 更新当前玩家显示
      }
    }
  
    /**
     * 绘制棋子
     */
    drawPiece(x, y, player) {
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
      
      this.ctx.beginPath();
      this.ctx.arc(
        this.cellSize/2 + x*this.cellSize,
        this.cellSize/2 + y*this.cellSize,
        this.cellSize/2 - 2, 0, Math.PI*2
      );
      this.ctx.fillStyle = gradient;
      this.ctx.fill();
      this.ctx.strokeStyle = '#333';
      this.ctx.stroke();
    }
  
    /**
     * 检查胜利条件
     */
    checkWin(x, y) {
      const directions = [
        [1, 0],  // 水平
        [0, 1],  // 垂直
        [1, 1],  // 对角线
        [1, -1]  // 反对角线
      ];
      
      return directions.some(([dx, dy]) => {
        let count = 1; // 当前落子点
        
        // 正向检测
        for (let i = 1; i < 5; i++) {
          const nx = x + i * dx;
          const ny = y + i * dy;
          if (!this.isValidPosition(nx, ny) break;
          if (this.board[nx][ny] === this.currentPlayer) {
            count++;
          } else {
            break;
          }
        }
        
        // 反向检测
        for (let i = 1; i < 5; i++) {
          const nx = x - i * dx;
          const ny = y - i * dy;
          if (!this.isValidPosition(nx, ny)) break;
          if (this.board[nx][ny] === this.currentPlayer) {
            count++;
          } else {
            break;
          }
        }
        
        return count >= 5;
      });
    }
  
    /**
     * 验证棋盘位置是否有效
     */
    isValidPosition(x, y) {
      return x >= 0 && x < this.boardSize && y >= 0 && y < this.boardSize;
    }
  
    /**
     * 切换当前玩家
     */
    switchPlayer() {
      this.currentPlayer = 3 - this.currentPlayer; // 1 ↔ 2
      this.updateStatus();
    }
  
    /**
     * 更新状态显示
     */
    updateStatus(message = null) {
      if (message) {
        this.statusElement.textContent = message;
        return;
      }
      
      const playerText = this.currentPlayer === 1 ? '黑棋' : '白棋';
      this.statusElement.textContent = `当前玩家: ${playerText}`;
      this.statusElement.style.color = this.currentPlayer === 1 ? '#000' : '#888';
    }
  
    /**
     * 显示消息
     */
    showMessage(message, isError = false) {
      this.messageElement.textContent = message;
      this.messageElement.style.color = isError ? 'red' : 'green';
      setTimeout(() => this.messageElement.textContent = '', 3000);
    }
  
    /**
     * 结束游戏
     */
    endGame(message) {
      this.gameActive = false;
      this.showMessage(message);
      this.updateStatus('游戏结束');
      
      // 联机模式：禁用邀请按钮
      if (this.isOnline) {
        this.inviteButton.disabled = true;
      }
    }
  
    /**
     * 重新开始游戏
     */
    restart() {
      this.board = Array(this.boardSize).fill().map(() => Array(this.boardSize).fill(0));
      this.currentPlayer = 1;
      this.gameActive = true;
      this.drawBoard();
      this.updateStatus();
      this.messageElement.textContent = '';
      
      if (this.isOnline) {
        this.inviteButton.disabled = false;
      }
    }
  }
  
  // 全局访问
  window.Gomoku = Gomoku;