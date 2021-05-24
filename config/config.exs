use Mix.Config

config :api_test,
  db_host: "localhost",
  db_port: 27017,
  db_db: "users",
  db_tables: [
    "users"
  ],

api_host: "localhost",
api_port: 8080,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600,

routing_keys: %{
  # User Events
  "user_login" => "api.login.auth-login.events",
  "user_logout" => "api.login.auth-logout.events",
  "user_register" => "api.login.register.events"
},
event_url: "guest:guest@localhost", #username:passwd (here default)
event_exchange: "my_api",
event_queue: "auth_service"
