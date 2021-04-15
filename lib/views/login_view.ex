defmodule Api.Views.LoginView do
  use JSONAPI.View

  def fields, do: [:username, :password]
  def type, do: "user"
  def relationships, do: []
end
