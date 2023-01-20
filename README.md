# KinoDiscord

[![Docs](https://img.shields.io/badge/hex.pm-docs-8e7ce6.svg)](https://hexdocs.pm/kino_discord)
[![Actions Status](https://github.com/basilenouvellet/kino_discord/workflows/Test/badge.svg)](https://github.com/basilenouvellet/kino_discord/actions)

Discord integration with [Kino](https://github.com/livebook-dev/kino)
for [Livebook](https://github.com/livebook-dev/livebook).

This project is heavily inspired from [:kino_slack](https://github.com/livebook-dev/kino_slack).

## Installation

To bring KinoDiscord to Livebook all you need to do is `Mix.install/2`:

```elixir
Mix.install([
  {:kino_discord, "~> 0.1.0"}
])
```

## Get started

- Create Discord app ([see doc](https://discord.com/developers/docs/getting-started#creating-an-app))

- Create a bot for your app ([see doc](https://discord.com/developers/docs/getting-started#configuring-a-bot)) & copy the **bot token**

- Generate an installation URL ([see doc](https://discord.com/developers/docs/getting-started#adding-scopes-and-permissions)) with:

  - scopes: `bot`
  - permissions: `Send Messages`

- Install the bot on your Discord server by visiting the installation URL

- Copy the **channel id** of your Discord channel (i.e. the last part of the channel URL)

  > Discord channel URLs have this shape: `https://discord.com/channels/[GUILD_ID]/[CHANNEL_ID]`

- Create a "Discord message" smart cell in your Livebook and fill in the channel id & bot token

## License

Copyright (C) 2023 Basile Nouvellet

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
