defmodule Api.Models.User do
    @db_name Application.get_env(:api_test, :db_db)
    @db_table "users"

use Api.Models.Base

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
  :reportNumber
  ]
end
