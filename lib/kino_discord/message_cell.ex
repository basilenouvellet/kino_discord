defmodule KinoDiscord.MessageCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Discord message"

  alias KinoDiscord.Helpers

  @impl true
  def init(attrs, ctx) do
    fields = %{
      "token_secret_name" => attrs["token_secret_name"] || "",
      "channel_id" => attrs["channel_id"] || "",
      "message" => attrs["message"] || ""
    }

    {:ok, assign(ctx, fields: fields)}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{fields: ctx.assigns.fields}, ctx}
  end

  @impl true
  def handle_event("update_channel_id", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"channel_id" => value}))
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_message", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"message" => value}))
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_token_secret_name", value, ctx) do
    broadcast_event(ctx, "update_token_secret_name", value)
    ctx = update(ctx, :fields, &Map.merge(&1, %{"token_secret_name" => value}))
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns.fields
  end

  @impl true
  def to_source(attrs) do
    required_fields = ~w(token_secret_name channel_id message)

    if Helpers.all_fields_filled?(attrs, required_fields) do
      quote do
        req =
          Req.new(
            base_url: "https://discord.com/api",
            headers: [
              {"Authorization",
               "Bot #{System.fetch_env!(unquote("LB_#{attrs["token_secret_name"]}"))}"}
            ]
          )

        case Req.post!(req,
               url: unquote("/channels/#{attrs["channel_id"]}/messages"),
               json: %{content: unquote(attrs["message"])}
             ) do
          %Req.Response{status: 200} ->
            :ok

          %Req.Response{status: 400, body: %{"message" => reason}} ->
            {:error, reason}

          %Req.Response{status: status, body: "\n<html>" <> _ = body} ->
            "```html#{body}```" |> Kino.Markdown.new() |> Kino.render()
            {:error, %{status: status, body: body}}

          %Req.Response{status: status, body: body} ->
            {:error, %{status: status, body: body}}
        end
      end
      |> Kino.SmartCell.quoted_to_string()
    else
      ""
    end
  end
end
