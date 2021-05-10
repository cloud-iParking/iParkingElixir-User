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
jwt_validity: 3600
