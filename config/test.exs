import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_eval, CodeEvalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "xflhrbFCLlaaWjCJrGfLbVZCW51PlycV2ZN0syhMjYFKy2Mv2zNx7ACTNxq59lYH",
  server: false

config :code_eval, auth_tokens: ["test_token"]

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
