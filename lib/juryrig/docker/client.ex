defmodule Juryrig.Docker.Client do
  use HTTPoison.Base

  @docker_sock "http+unix://%2Fvar%2Frun%2Fdocker.sock"

  def process_url(url) do
    @docker_sock <> url
  end


  def process_response_body body do
    case Jason.decode(body) do
      {:ok, parsed} -> parsed
      {:error, _} -> body
    end
  end

  def process_request_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  def process_request_body(body) do
    body
  end

  def process_request {:ok, %HTTPoison.Response{status_code: 200} = req} do
    req.body
  end

  def process_request {:error, res} do
    case res do
      %HTTPoison.Response{ status_code: 404 } -> {:error, "Not found"}
      %HTTPoison.Error{ reason: :enoent } -> {:error, "Docker is down"}
    end
  end

end
