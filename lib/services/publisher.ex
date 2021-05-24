defmodule Api.Service.Publisher do
  use Api.Helpers.EventBus
  use Timex

  require Poison

  def start_link(), do: start

  def publish(routing_key, payload, options \\ []) do
    Api.Helpers.EventBus.publish(routing_key, Poison.encode!(payload), options ++ [
      app_id: "auth_service",
      content_type: "application/json",
      persistent: true
    ])
  end
end
