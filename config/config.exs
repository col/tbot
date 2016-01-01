# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :tbot, Tbot.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "LpIce5R1DfJRmxRYKpC9VR494t5n9GOMTqdnd7hl3zY/p2NqC4Q4uYYe4ho3feMR",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Tbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :nadia,
  token: "161988047:AAHAW8rB4CzSQBi7JiVi5PJv0VY04aXmDqo"
