// games/gomoku/gomoku.js
class Gomoku {
    constructor() {
      this.board = Array(15).fill().map(() => Array(15).fill(0));
      this.currentPlayer = 1; // 1:黑棋 2:白棋
    }
  
    handleMove(x, y) {
      if(this.board[x][y] !== 0) return;
      
      this.board[x][y] = this.currentPlayer;
      drawPiece(x, y, this.currentPlayer);
      
      // 发送落子数据
      if(window.conn) conn.send({x, y, player: this.currentPlayer});
      
      this.checkWin(x, y);
      this.currentPlayer = 3 - this.currentPlayer; // 切换玩家
    }
  
    checkWin(x, y) {
      // 实现五子连珠检测逻辑
      // 返回true/false
    }
  }