defmodule Juryrig.Repo do
  use Ecto.Repo,
    otp_app: :juryrig,
    adapter: Ecto.Adapters.SQLite3
end
