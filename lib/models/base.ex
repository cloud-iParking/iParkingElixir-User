defmodule Api.Models.Base do

  alias Api.Helpers.MapHelper

  use Timex

  defmacro __using__(_) do
    quote do

      def get(id) do
        case Mongo.find_one(:mongo, @db_table, %{id: id}) do
          nil ->
            nil
          doc ->
            {:ok, doc |> MapHelper.string_keys_to_atoms |> merge_to_struct}
        end
      end

      def getUser(username) do
        case Mongo.find_one(:mongo, @db_table, %{username: username}) do
          nil ->
            nil
          doc ->
            {:ok, doc |> MapHelper.string_keys_to_atoms |> merge_to_struct}
        end
      end

      def saveUser(document) when is_map(document) do
        # Saving document
        case Mongo.insert_one(:mongo, @db_table, document) do
          {:ok, _} ->
            {:ok, document}
          _ ->
            :error
        end
      end

      def find(filters) when is_map(filters) do
        cursor = Mongo.find(:mongo, @db_table, filters)

        case cursor |> Enum.to_list do
          [] ->
            {:error, []}
          saved_docs ->
            {:ok, saved_docs |> Enum.map(&(merge_to_struct(MapHelper.string_keys_to_atoms(&1))))}
        end
      end


      def delete(id) do
        {:ok, res} = Mongo.delete_one(:mongo, @db_table, %{id: id})

        if res.deleted_count  > 0 do
         :ok
        else
         :error
        end
      end


      defp merge_to_struct(document) when is_map(document) do
         __struct__ |> Map.merge(document)
      end
    end
  end
end
