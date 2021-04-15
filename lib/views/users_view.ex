defmodule Api.Views.UserView do
  use JSONAPI.View

  def fields, do: [ :id, :lastName, :firstName, :username, :phone, :email, :password, :carNumber, :isBlocked, :isAdmin]
  def type, do: "user"
  def relationships, do: []
end
