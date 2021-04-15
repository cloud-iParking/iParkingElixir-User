defmodule Api.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug(:dispatch)

  forward("/user", to: Api.EndpointUsers)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
