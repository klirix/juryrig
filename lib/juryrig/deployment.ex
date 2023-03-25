defmodule Juryrig.Deployment do
  @moduledoc """
  This module defines a Deployment struct and provides functions for interacting with Docker containers.

  A Deployment represents a running Docker container that has been started with a specific set of configuration options.

  ## Examples

      iex> deployment = %Deployment{id: "abcd", name: "my-container", image: "nginx", domain: "example.com", ports: [%{from: 80, to: 8080}], env_variables: %{"ENV_VAR" => "value"}, status: "running"}
      iex> updated_deployment = upsert(deployment)

  """
  alias __MODULE__
  alias Juryrig.Deployment
  alias Juryrig.Docker.{Container}

  @type t :: %Deployment{
          id: String.t(),
          name: String.t(),
          image: String.t(),
          domain: String.t(),
          ports: list(container_port),
          # only used for deployments
          env_vairables: map(),
          status: String.t()
        }

  defstruct id: nil,
            name: nil,
            image: nil,
            domain: nil,
            ports: nil,
            # only used for deployments
            env_vairables: nil,
            status: nil

  @doc """
  Returns a list of all running Deployments in Docker.
  """
  @spec list :: list(Juryrig.Deployment.t())
  def list do
    Container.list()
    |> Enum.map(&container_to_deployment/1)
  end

  @doc """
  Returns the Deployment with the given ID or nil if no such Deployment exists.
  """
  @spec get(String.t()) :: Juryrig.Deployment.t()
  def get(id) do
    list()
    |> Enum.find(&(&1.id == id))
  end

  @spec container_to_deployment(map) :: Juryrig.Deployment.t()
  defp container_to_deployment(container) do
    %{"Image" => image, "State" => status, "Names" => ["/" <> name]} = container

    id =
      case container do
        %{"Labels" => %{"juryrig.id" => id}} -> id
        _ -> container["Id"]
      end

    %Deployment{
      id: id,
      image: image,
      status: status,
      domain: extract_domain(container),
      name: name,
      ports: readable_ports(container["Ports"])
    }
  end

  defp extract_domain(%{
         "Labels" => %{"traefik.http.routers.whoami.rule" => "Host(`" <> partial_host}
       }) do
    String.slice(partial_host, 0..-2)
  end

  defp extract_domain(_), do: nil

  @type container_port :: %{
          from: number() | nil,
          to: number() | nil,
          ip: String.t() | nil,
          type: String.t()
        }

  @spec readable_ports(list) :: list(container_port())
  defp readable_ports(ports) do
    Enum.map(ports, &readable_port/1)
  end

  defp readable_port(port) do
    %{ip: port["IP"], from: port["PrivatePort"], to: port["PublicPort"], type: port["Type"]}
  end
end
