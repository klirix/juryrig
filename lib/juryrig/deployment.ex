defmodule Juryrig.Deployment do
  alias __MODULE__
  alias Juryrig.Deployment
  alias Juryrig.Docker.{Container}

  @type t :: %Deployment{
    id: String.t(),
    name: String.t(),
    image: String.t(),
    domain: String.t(),
    ports: list(container_port),
    env_vairables: map(), # only used for deployments
    status: String.t()
  }

  defstruct id: nil,
            name: nil,
            image: nil,
            domain: nil,
            ports: nil,
            env_vairables: nil, # only used for deployments
            status: nil


  @spec get :: list(Juryrig.Deployment.t())
  def get do
    Container.list()
    |> IO.inspect()
    |> Enum.filter(&filter_exited/1)
    |> Enum.map(&container_to_deployment/1)
  end

  defp filter_exited(%{"State" => "exited"}), do: false
  defp filter_exited _ do
    true
  end

  @spec container_to_deployment(map) :: Juryrig.Deployment.t()
  defp container_to_deployment container do
    %{"Image" => image, "State" => status , "Names" => ["/"<> name] } = container
    id = case container do
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

  defp extract_domain %{ "Labels" => %{"traefik.http.routers.whoami.rule" => "Host(`"<>partial_host} } do
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
  defp readable_ports ports do
    Enum.map(ports, &readable_port/1)
  end

  defp readable_port (port) do
    %{ip: port["IP"], from: port["PrivatePort"], to: port["PublicPort"], type: port["Type"]}
  end
end
