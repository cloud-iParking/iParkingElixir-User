defmodule Api.EndpointUsers do
  use Plug.Router

  alias Api.Views.UserView
  alias Api.Models.User
  alias Api.Views.LoginView
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @routing_keys Application.get_env(:api_test, :routing_keys)
  @skip_token_verification %{jwt_skip: true}

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

  plug :match

  plug :dispatch
  plug JsonTestPlug
  plug Api.AuthPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  get "/", private: %{view: UserView}  do
    params = Map.get(conn.params, "filter", %{})

    {_, users} =  User.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, users)
  end

  get "/:id", private: %{view: UserView}  do
    {parsedId, ""} = Integer.parse(id)

    case User.get(parsedId) do
      {:ok, user} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, user)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'user' not found"})
    end
  end

  post "/add", private: %{jwt_skip: true, view: UserView} do
    {id, lastName, firstName, username, email, phone, password, carNumber} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "lastName", nil),
      Map.get(conn.params, "firstName", nil),
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "phone", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "carNumber", nil)
    }

    cond do
      is_nil(lastName) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "lastName must be present!"})

      is_nil(firstName) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "firstName must be present!"})

      is_nil(username) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "username must be present!"})

      is_nil(email) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "email must be present!"})

      is_nil(phone) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "phone must be present!"})

      is_nil(password) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      true ->
        case User.getUser(username) do
           nil ->
            {:ok, service} = Api.Service.Auth.start_link
            case %User{ id: username,
                    lastName: lastName,
                    firstName: firstName,
                    username: username,
                    phone: phone,
                    email: email,
                    password: Api.Service.Auth.generate_hash(service, password),
                    carNumber: carNumber,
                    isBlocked: false,
                    isAdmin: false} |> User.saveUser do
                  {:ok, createdEntry} -> uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"

            Publisher.publish(@routing_keys |> Map.get("user_register"), %{:id => id, :name => username})

            conn
            |> put_resp_header("location", "#{uri}#{id}")
            |> put_status(201)
            |> assign(:jsonapi, createdEntry)
            :error ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
            end
          {:ok, %{}} ->
            conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "User exists"})
        end
      end
  end

  patch "/:username", private: %{view: UserView} do

    {username} = {
      Map.get(conn.params, "username", nil)
    }
    case User.getUser(username) do
      {:ok, user} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, user)

    User.delete(user.id)

    case %User{ id: user.id,
                lastName: user.lastName,
                firstName: user.firstName,
                username: user.username,
                phone: user.phone,
                email: user.email,
                password: user.password,
                carNumber: user.carNumber,
                isBlocked: true,
                isAdmin: user.isAdmin} |> User.saveUser do
      {:ok, createdEntry} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end
end

end
