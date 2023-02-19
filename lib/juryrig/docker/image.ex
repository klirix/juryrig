defmodule Juryrig.Docker.Image do
  alias Juryrig.Docker.Client

  def list do
    "/images/json"
    |> Client.get
    |> Client.process_request()
  end

  def inspect(name) when is_binary(name) do
    "/images/#{name}/json"
    |> Client.get
    |> Client.process_request()
  end

  def delete(name) when is_binary(name) do
    "/images/#{name}"
    |> Client.delete
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        :ok
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "image not found"}
      {:ok, %HTTPoison.Response{status_code: 409} = err} ->
        {:error, err.body["message"]}
      res ->
        IO.inspect(res)
        {:error, "unknown error, check logs"}
    end
  end
end
