defmodule Api.Router do
  use Plug.Router

  alias Api.Service.Publisher

  @routing_keys Application.get_env(:api_test, :routing_keys)


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
    |>send_resp(conn.status, conn.assigns|> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  post "/login", private: %{view: LoginView} do
    {username, password} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "password", nil)
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
          case User.getUser(username) do
            {:ok, user} ->

              {:ok, service} = Api.Service.Auth.start_link

              case Api.Service.Auth.verify_hash(service, {password, user.password}) do
                true ->
                  token = Api.Service.Auth.issue_token(service, %{:id => user.id})

                  #publishing login event
                  Publisher.publish(
                  @routing_keys |> Map.get("user_login"), Map.take(user, [:id, :username]))

                  conn
                  |> put_status(200)
                  |> assign(:userId,  %{:id => user.id}) #claims, id
                  |> assign(:jsonapi, %{:token => token})
                false ->
                    conn
                    |> put_status(404)
                    |> assign(:jsonapi, %{"error" => "'password' is wrong"})
              end
              :error ->
                conn
                |> put_status(404)
                |> assign(:jsonapi, %{"error" => "'user' not found"})
        end
      end
  end

  post "/logout" do

    {id} = {
      Map.get(conn.params, "id", nil)
    }

    {:ok, service} = Api.Service.Auth.start_link

    #id = conn.assigns.[:userId]

    case Api.Service.Auth.revoke_token(service, %{:id => id}) do
      :ok ->
        Publisher.publish(@routing_keys |> Map.get("user_logout"), %{:id => id})

        conn
        |> put_status(200)
        |> assign(:jsonapi, %{"message" => "logged out: #{id}, token deleted"})
      :error ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"message" => "Could not log out. problem! Please log in."})

    end
  end

  forward("/user", to: Api.EndpointUsers)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
