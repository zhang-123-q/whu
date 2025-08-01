// games/gomoku/room.js
export function createRoom() {
    const roomId = generateId(); // 生成随机房间ID
    return roomId;
  }
  
  function generateId() {
    return Math.random().toString(36).substring(2, 8);
  }