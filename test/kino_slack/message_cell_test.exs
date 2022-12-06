defmodule KinoSlack.MessageCellTest do
  use ExUnit.Case

  import Kino.Test

  alias KinoSlack.MessageCell

  setup :configure_livebook_bridge

  test "when required fields are filled in, generates source code" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "SLACK_TOKEN")
    push_event(kino, "update_channel", "#slack-channel")
    push_event(kino, "update_message", "slack message")

    assert_smart_cell_update(
      kino,
      %{
        "fields" => %{
          "token_secret_name" => "SLACK_TOKEN",
          "channel" => "#slack-channel",
          "message" => "slack message"
        }
      },
      generated_code
    )

    expected_code = ~S"""
    req =
      Req.new(
        base_url: "https://slack.com/api",
        auth: {:bearer, System.fetch_env!("LB_SLACK_TOKEN")}
      )

    response =
      Req.post!(req,
        url: "/chat.postMessage",
        json: %{channel: "#slack-channel", text: "slack message"}
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
      "fields" => %{
        "token_secret_name" => "SLACK_TOKEN",
        "channel" => "#slack-channel",
        "message" => "slack message"
      }
    }

    {_kino, source} = start_smart_cell!(MessageCell, stored_attrs)

    expected_source = ~S"""
    req =
      Req.new(
        base_url: "https://slack.com/api",
        auth: {:bearer, System.fetch_env!("LB_SLACK_TOKEN")}
      )

    response =
      Req.post!(req,
        url: "/chat.postMessage",
        json: %{channel: "#slack-channel", text: "slack message"}
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
      "fields" => %{
        "token_secret_name" => "SLACK_TOKEN",
        "channel" => "#slack-channel",
        "message" => "slack message"
      }
    }

    attrs_missing_required = put_in(required_attrs["fields"]["token_secret_name"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["fields"]["channel"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""

    attrs_missing_required = put_in(required_attrs["fields"]["message"], "")
    assert MessageCell.to_source(attrs_missing_required) == ""
  end

  test "when slack token secret field changes, broadcasts secret name back to client" do
    {kino, _source} = start_smart_cell!(MessageCell, %{})

    push_event(kino, "update_token_secret_name", "SLACK_TOKEN")

    assert_broadcast_event(kino, "update_token_secret_name", "SLACK_TOKEN")
  end
end
