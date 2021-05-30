defmodule Api.Views.LoggedUserView do
    use JSONAPI.View
  
    def fields, do: [ :id, :lastName, :firstName, :username, :phone, :email, :password, :carNumber, :isBlocked, :isAdmin, :token]
    def type, do: "loggeduser"
    def relationships, do: []
  end
  