defmodule JuryrigWeb.PageController do
  use JuryrigWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
