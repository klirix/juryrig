defmodule JuryrigWeb.PageController do
  use JuryrigWeb, :controller

  alias Juryrig.{Repo, Deployment}

  def list(conn, _params) do
    json(conn, Deployment.list())
  end

  def get(conn, %{"id" => id}) do
    page = Repo.get(Page, id)

    case page do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Page not found"})

      _ ->
        conn
        |> put_status(:ok)
        |> json(page)
    end
  end

  def upsert(conn, %{"id" => id} = params) do
    if id do
      update(conn, params)
    else
      create(conn, params)
    end
  end

  def create(conn, %{"data" => data}) do
    changeset =
      @model_schema
      |> Map.put_new(:data, data)
      |> @model_changeset.call()

    case Repo.insert(changeset) do
      {:ok, model} ->
        conn
        |> put_status(:created)
        |> json(model)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset.errors})
    end
  end

  def update(conn, %{"id" => id, "data" => data}) do
    page = Repo.get(Page, id)
  end

  def delete(conn, %{"id" => id}) do
    page = Repo.get(Page, id)

    case page do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Page not found"})

      _ ->
        Repo.delete(page)

        conn
        |> put_status(:no_content)
    end
  end
end
