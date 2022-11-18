defmodule KinoSlackTest do
  use ExUnit.Case
  doctest KinoSlack

  test "greets the world" do
    assert KinoSlack.hello() == :world
  end
end
