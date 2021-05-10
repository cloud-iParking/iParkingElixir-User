defmodule Api.Views.LoginView do
  use JSONAPI.View

  def fields, do: [:username, :password, :id]
  def type, do: "user"
  def relationships, do: []
end
