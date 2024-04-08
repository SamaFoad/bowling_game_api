import consumer from "./consumer"

consumer.subscriptions.create("GameChannel", {
  connected() {
    console.log("Connected to the game channel")
  },

  received(data) {
    console.log("Received data:", data)
    // Update the UI to display the current game score
    document.getElementById("score").innerText = data.score
  }
})
