# Internal Fullfillment Platform
Ruby on Rails project: Internal fulfillment platform used by operations staff to manage customer orders from placement through delivery

## Tech Stack
- Ruby (v4.0.3)
- Rails (v8.1)
- PostgreSQL (v18)
- Bundler (v4.0.10)
- RSpec-Rails (v8)
- RuboCop (via rubocop-rails-omakase + rubocop-performance + rubocop-rspec)

## How to run locally
### Install dependencies
```bash
bundle install
```

### Setup database
```bash
rails db:create
rails db:migrate
rails db:seed
```

### Run the project
```bash
rails s
```

## Linting, tests, and audits
### RuboCop
```bash
rubocop
rubocop -a  # auto-fix safe offenses
```

## Run test cases
```bash
bundle exec rspec
```

## Application audits
```bash
brakeman --no-pager
bundler-audit
rails zeitwerk:check
```
