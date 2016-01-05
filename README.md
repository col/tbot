# Tbot

[![Build Status](https://travis-ci.org/col/tbot.svg)](https://travis-ci.org/col/tbot)

## Requirements
  - Elixir >= 1.1
  - Erlang >= 18
  - Node >= 5.3
  - npm >= 3.5.2
  - Postgress >= 9.3
  
## Setup and run

  1. Install dependencies with `mix deps.get` and `npm install`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Test 

`mix test`

## Deploy

Please [check the deployment guides](https://gist.github.com/col/5c598560770465cef98b).
