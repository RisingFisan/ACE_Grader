defmodule AceGrader.Grader.API do
  def grader_url do
    "http://#{Application.get_env(:ace_grader, :grader_host)}:#{Application.get_env(:ace_grader, :grader_port)}"
  end
end

defmodule AceGrader.Grader.APICheck do
  use GenServer

  require Logger

  alias AceGrader.Grader.API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    Process.send(self(), :check_api, [])
    {:ok, %{}}
  end

  def handle_info(:check_api, state) do
    case check_api() do
      :ok -> schedule_check(60_000) # check if it's ok every 60 seconds
      :error -> schedule_check(15_000) # check if error is resolved every 15 seconds
    end
    {:noreply, state}
  end

  defp schedule_check(interval) do
    Process.send_after(self(), :check_api, interval)
  end

  defp check_api do
    case HTTPoison.get(API.grader_url <> "/ping", []) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        AceGrader.Grader.APIStatus.update_status(:online)
        # Logger.info("Grader API is online")
        :ok
      {:ok, %HTTPoison.Response{status_code: code}} ->
        AceGrader.Grader.APIStatus.update_status(:error)
        Logger.error("Grader API error: #{code}")
        :error
      {:error, %HTTPoison.Error{reason: reason}} ->
        AceGrader.Grader.APIStatus.update_status(:offline)
        Logger.error("Grader API is offline: #{reason}")
        :error
    end
  end
end

defmodule AceGrader.Grader.APIStatus do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> :offline end, name: __MODULE__)
  end

  def update_status(status) do
    Agent.update(__MODULE__, fn _ -> status end)
  end

  def get_status do
    Agent.get(__MODULE__, fn status -> status end)
  end
end
