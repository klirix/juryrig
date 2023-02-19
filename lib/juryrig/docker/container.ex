defmodule Juryrig.Docker.Container do
  alias Juryrig.Docker.Client

  def list do
    Client.get("/containers/json?all=true")
    |> Client.process_request()
  end

  def inspect(name) when is_binary(name) do
    Client.get("/containers/#{name}/json")
    |> Client.process_request()
  end

  def create map do
    Client.post("/containers/create", map)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 201, body: %{"Id" => id}}} -> {:ok, id}
      {:ok, %HTTPoison.Response{body: %{"message"=> message}}} -> {:error, message}
    end
  end
end
