Here's a template for a comprehensive README.md file for your Bowling Game API:

---

# Bowling Game API

This API provides endpoints for managing a bowling game, including starting a new game, inputting the number of pins knocked down by each ball, and outputting the current game score.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Server](#running-the-server)
- [API Endpoints](#api-endpoints)
- [Examples](#examples)
- [How to run the test suite](#rspec)

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- Ruby version (`ruby -v`) = 3.0.0 [Installation guide](https://www.ruby-lang.org/en/documentation/installation/)
- Rails version (`rails -v`) = 6.0.6.1 [Installation guide](https://guides.rubyonrails.org/getting_started.html#installing-rails)
- PostgreSQL version (`psql --version`) = 12.18 [Installation guide](https://www.postgresql.org/download/)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/bowling_game_api.git
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Set up the database:

   ```bash
   rails db:create
   rails db:migrate
   ```

### Running the Server

Start the Rails server:

```bash
rails server
```

The API will be accessible at `http://localhost:3000`.

## API Endpoints

- `POST /games`: Start a new game
- `GET /games/:id`: Output the current game.
- `GET /games/:id/status`: Output the current game status.
- `GET /games/:id/close`: close the current game.
- `POST /games/:id/rolls`: Input the number of pins knocked down by each ball.
- `GET /games/:id/score`: Output the current game score.

## Examples

### Starting a New Game

```bash
curl -X POST http://localhost:3000/games
```

### Inputting Rolls

```bash
curl -X POST http://localhost:3000/games/1/rolls -d "pins_knocked_down=7"
```

### Getting Game Score

```bash
curl http://localhost:3000/games/1/score
```

### Rspec (Unit Tests 👓 )
```bash
bundle exec rspec
```
