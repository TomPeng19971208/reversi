defmodule ReversiWeb.GamesChannel do
  use ReversiWeb, :channel

  alias Reversi.Game
  alias Reversi.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game=GameServer.get_state(name)

      %{"user_name": user_name}=payload
      if length(game.players)<2 do
        GameServer.user_join(name, "player", user_name)
      else
        GameServer.user_join(name, "spectator", user_name)
      end
      game=GameServer.get_state(name)
      socket=socket
      |>assign(:name, name)
      |>assign(:game, game)

      broadcast! socket, "update", game
      {:ok, %{"join"=> name, "game"=> Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  def handle_in("click", %{x: x, y: y}, socket) do
    name=socket.assigns[:name]
    new_game=GameServer.click(name, x, y)
    socket.assign(socket, :game, new_game)
    broadcast! socket, "update", new_game
    socket=assign(socket, :game, new_game)
    {:reply, {:ok, %{game: Game.client_view(new_game)}}, socket}
  end

  #when a user leave
  #payload is %{"type": "player/spectator", "user_name": name}
  def handle_in("leave", %{"type": type, "user_name": user_name}, socket) do
    game=socket.assigns[:game]
    name=socket.assigns[:name]
    if type == "players" do
      game= GameServer.user_leave(name, "player", user_name)
    else
      game=GameServer.user_leave(name, "spectator", user_name)
    end
    socket.assign(:game, game)
    broadcast! socket, "update", game
    {:reply, {:ok, %{game: Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
