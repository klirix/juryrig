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

  @spec create(any) :: {:error, any} | {:ok, any}
  def create(map) do
    Client.post("/containers/create", map)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 201, body: %{"Id" => id}}} -> {:ok, id}
      {:ok, %HTTPoison.Response{body: %{"message" => message}}} -> {:error, message}
    end
  end

  @spec stop(any) :: :ok | {:error, any}
  def stop(id) when is_binary(id) do
    Client.post("/containers/#{id}/stop", nil)
    |> case do
      {:ok, %HTTPoison.Response{status_code: code}} when code == 204 or code == 304 ->
        :ok

      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        {:error, body["message"]}
    end
  end

  def delete(id, options \\ %{}) when is_binary(id) do
    query = URI.encode_query(options)

    Client.delete("/containers/#{id}?#{query}")
    |> case do
      {:ok, %HTTPoison.Response{status_code: 204}} ->
        :ok

      {:ok, %HTTPoison.Response{status_code: code} = res} when code >= 400 and code < 500 ->
        {:error, res.body["message"]}
    end
  end
end
