defmodule Api.Models.LoggedUser do

defstruct [
  :id,
  :lastName,
  :firstName,
  :username,
  :phone,
  :email,
  :password,
  :carNumber,
  :isBlocked,
  :isAdmin,
  :token
  ]
end