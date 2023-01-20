defmodule KinoDiscord.MessageCellTest do
  use ExUnit.Case

  import Kino.Test

  alias KinoDiscord.MessageCell

  setup :configure_livebook_bridge

  test "when required fields are filled in, generates source code" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "DISCORD_BOT_TOKEN")
    push_event(kino, "update_channel_id", "123456")
    push_event(kino, "update_message", "discord message")

    assert_smart_cell_update(
      kino,
      %{
        "token_secret_name" => "DISCORD_BOT_TOKEN",
        "channel_id" => "123456",
        "message" => "discord message"
      },
      generated_code
    )

    expected_code = ~S"""
    req =
      Req.new(
        base_url: "https://discord.com/api",
        headers: [{"Authorization", "Bot #{System.fetch_env!("LB_DISCORD_BOT_TOKEN")}"}]
      )

    case Req.post!(req, url: "/channels/123456/messages", json: %{content: "discord message"}) do
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
    """

    expected_code = String.trim(expected_code)

    assert generated_code == expected_code
  end

  test "generates source code from stored attributes" do
    stored_attrs = %{
      "token_secret_name" => "DISCORD_BOT_TOKEN",
      "channel_id" => "123456",
      "message" => "discord message"
    }

    {_kino, source} = start_smart_cell!(MessageCell, stored_attrs)

    expected_source = ~S"""
    req =
      Req.new(
        base_url: "https://discord.com/api",
        headers: [{"Authorization", "Bot #{System.fetch_env!("LB_DISCORD_BOT_TOKEN")}"}]
      )

    case Req.post!(req, url: "/channels/123456/messages", json: %{content: "discord message"}) do
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
    """

    expected_source = String.trim(expected_source)

    assert source == expected_source
  end

  test "when any required field is empty, returns empty source code" do
    required_attrs = %{
      "token_secret_name" => "DISCORD_BOT_TOKEN",
      "channel_id" => "123456",
      "message" => "discord message"
    }

    attrs_missing_required = put_in(required_attrs["token_secret_name"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["channel_id"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["message"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""
  end

  test "when discord token secret field changes, broadcasts secret name back to client" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "DISCORD_BOT_TOKEN")

    assert_broadcast_event(kino, "update_token_secret_name", "DISCORD_BOT_TOKEN")
  end
end
