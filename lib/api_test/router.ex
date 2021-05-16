defmodule Api.Router do
  use Plug.Router

  plug CORSPlug, origins: "*", allow_headers: ["content-type"]
  plug(:match)

  plug(Plug.Parsers,
  parsers: [:json],
  pass: ["application/json"],
  json_decoder: Poison
  )
  plug(:dispatch)
  plug :encode_response

  alias Api.Views.UserView
  alias Api.Models.User
  alias Api.Views.LoginView

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  post "/login", private: %{view: LoginView} do
    {username, password, id} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil),
    }

    cond do
      is_nil(username) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "username must be present!"})

      is_nil(password) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

        true ->
          case User.getUser(username, password) do
            {:ok, user} ->

              {:ok, service} = Api.Service.Auth.start_link
              token = Api.Service.Auth.issue_token(service, %{:id => id})

              conn
              |> put_status(200)
              |> assign(:jsonapi,  %{:token => token})

            :error ->
              conn
              |> put_status(404)
              |> assign(:jsonapi, %{"error" => "'user' not found"})
        end
    end
  end

  forward("/user", to: Api.EndpointUsers)

  # forward("/bands", to: Api.Endpoint)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
