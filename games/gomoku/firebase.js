// games/gomoku/firebase.js
import { initializeApp } from "firebase/app";
import { getDatabase, ref, set, onChildAdded } from "firebase/database";

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "your-project.firebaseapp.com",
  databaseURL: "https://your-project.firebaseio.com",
  projectId: "your-project",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID"
};

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

export function sendMove(roomId, x, y, player) {
  set(ref(db, `games/gomoku/${roomId}/moves`), {
    x, y, player, timestamp: Date.now()
  });
}

export function listenMoves(roomId, callback) {
  onChildAdded(ref(db, `games/gomoku/${roomId}/moves`), (snapshot) => {
    callback(snapshot.val());
  });
}