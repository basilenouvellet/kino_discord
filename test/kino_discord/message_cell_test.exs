defmodule KinoDiscord.MessageCellTest do
  use ExUnit.Case

  import Kino.Test

  alias KinoDiscord.MessageCell

  setup :configure_livebook_bridge

  test "when required fields are filled in, generates source code" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "DISCORD_TOKEN")
    push_event(kino, "update_channel", "#discord-channel")
    push_event(kino, "update_message", "discord message")

    assert_smart_cell_update(
      kino,
      %{
        "token_secret_name" => "DISCORD_TOKEN",
        "channel" => "#discord-channel",
        "message" => "discord message"
      },
      generated_code
    )

    expected_code = ~S"""
    req =
      Req.new(
        base_url: "https://discord.com/api",
        auth: {:bearer, System.fetch_env!("LB_DISCORD_TOKEN")}
      )

    response =
      Req.post!(req,
        url: "/chat.postMessage",
        json: %{channel: "#discord-channel", text: "discord message"}
      )

    case response.body do
      %{"ok" => true} -> :ok
      %{"ok" => false, "error" => error} -> {:error, error}
    end
    """

    expected_code = String.trim(expected_code)

    assert generated_code == expected_code
  end

  test "generates source code from stored attributes" do
    stored_attrs = %{
      "token_secret_name" => "DISCORD_TOKEN",
      "channel" => "#discord-channel",
      "message" => "discord message"
    }

    {_kino, source} = start_smart_cell!(MessageCell, stored_attrs)

    expected_source = ~S"""
    req =
      Req.new(
        base_url: "https://discord.com/api",
        auth: {:bearer, System.fetch_env!("LB_DISCORD_TOKEN")}
      )

    response =
      Req.post!(req,
        url: "/chat.postMessage",
        json: %{channel: "#discord-channel", text: "discord message"}
      )

    case response.body do
      %{"ok" => true} -> :ok
      %{"ok" => false, "error" => error} -> {:error, error}
    end
    """

    expected_source = String.trim(expected_source)

    assert source == expected_source
  end

  test "when any required field is empty, returns empty source code" do
    required_attrs = %{
      "token_secret_name" => "DISCORD_TOKEN",
      "channel" => "#discord-channel",
      "message" => "discord message"
    }

    attrs_missing_required = put_in(required_attrs["token_secret_name"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["channel"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["message"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""
  end

  test "when discord token secret field changes, broadcasts secret name back to client" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "DISCORD_TOKEN")

    assert_broadcast_event(kino, "update_token_secret_name", "DISCORD_TOKEN")
  end
end
