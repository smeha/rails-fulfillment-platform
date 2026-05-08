# Internal Fulfillment Platform
Ruby on Rails project: Internal fulfillment platform used by operations staff to manage customer orders from placement through delivery

## Tech Stack
- Ruby (v3.4.8)
- Rails (v8.1)
- PostgreSQL (v18)
- Bundler (v4.0.10)
- RSpec-Rails (v8)
- RuboCop (via rubocop-rails-omakase + rubocop-performance + rubocop-rspec + rubocop-factory_bot)

## How to run locally in one command
```bash
bin/setup
```

This installs dependencies, prepares the database, clears stale logs/temp files, and starts the Rails server. After the server boots, open http://localhost:3000.

To rebuild the database from scratch:
```bash
bin/setup --reset
```

After the setup to run server again:
```bash
bin/dev
```

## Default login credentials
* Email: `internal@example.com`
* Password: `password123`

## Design decisions and tradeoffs
- Load only the Rails frameworks this app currently uses. Kept unused defaults commented so they are easy to restore.
- Internal users are seeded and managed by code/database, not public registration.
- Store money as integer cents to avoid decimal rounding issues.
- Keep order status rules in a service object because lifecycle transitions are core business semantics.
- Use polymorphic audit entries so status-change history can grow beyond orders later.

## How to run locally step by step
### Install dependencies
```bash
bundle install
```

### Setup database
```bash
rails db:prepare
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

## Initial application assignment
### Overview
Internal fulfillment platform used by operations staff to manage customer orders from placement through delivery. The team is currently tracking  everything in spreadsheets and needs a proper web application to replace that workflow.

### Initial business issues to solve
Operations staff currently have no reliable way to:
* Know which orders are waiting on action from them
* Prevent orders from being processed out of sequence (e.g., marking something as shipped before it's
been reviewed)
* See live carrier tracking updates without manually checking the carrier's website
* Take bulk actions on groups of orders instead of processing them one at a time

### System requirements
#### Access Control
Only authenticated staff members should be able to access the dashboard. There is no self-serve registration — accounts are managed internally.

#### Order Lifecycle Management
Orders move through a fulfillment pipeline. Staff need to be able to advance orders through that pipeline, but the system should prevent nonsensical transitions — you can't ship something that hasn't been approved, and you can't cancel something that's already been delivered. When a staff member attempts an invalid transition, they should see a clear explanation, not an error page.

#### Audit History
Compliance requires that status changes on orders are logged — what changed, and when it moved from one state to another. This requirement may apply to other models in the future, so keep that in mind when designing the solution.

#### Carrier Tracking Integration (Note: for now can be simulated)
When an order ships, the platform needs to pull tracking events from the carrier's API and display them to staff. The carrier integration should be treated as an external dependency with a clean boundary — assume the API can fail, be slow, or return unexpected data.

Tracking syncs should not block the user — they should happen in the background and update the page automatically when complete.

#### Staff Dashboard
Staff need a central view of all orders — filterable by status — and a detail view per order showing line items, pricing, current status, available actions, and the tracking timeline.

They also need the ability to perform bulk operations (e.g., approving multiple orders at once) without opening each one individually.

#### Data
The system manages orders made up of line items referencing products. Prices should be handled precisely — think about the right storage type for monetary values.

Seed the application with enough realistic data that an evaluator can immediately explore a populated dashboard.
