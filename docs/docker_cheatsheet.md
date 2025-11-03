# Docker Cheatsheet

## Basic Commands

| Command                              | Description                                      |
|---------------------------------------|--------------------------------------------------|
| `docker compose up`                   | Start containers and show logs                   |
| `docker compose up -d`                | Start containers in background (detached mode)   |
| `docker compose down`                 | Stop and remove containers, networks, volumes    |
| `docker compose ps`                   | List running containers                          |
| `docker compose logs`                 | Show logs for all containers                     |
| `docker compose logs db`              | Show logs for the `db` service                   |
| `docker ps`                           | List all running containers                      |
| `docker stop <container>`             | Stop a running container                         |
| `docker rm <container>`               | Remove a stopped container                       |
| `docker images`                       | List downloaded images                           |
| `docker exec -it <container> bash`    | Open a shell inside a running container          |

## What We've Done & Why

- **Created a `docker-compose.yml` file:**  
  To automate starting a MySQL database container for your project.

- **Mapped ports (`3307:3306`):**  
  So you can connect to MySQL at `localhost:3307` without conflicting with other local services.

- **Used `.env` for credentials:**  
  Keeps sensitive info out of code and easy to change.

- **Mounted `schema.sql` as an init script:**  
  Automatically sets up your database tables when the container starts.

- **Detached mode (`-d`):**  
  Lets you run containers in the background, keeping your terminal clean.

## Why Use Docker?

- **Isolation:** Your database runs separately from your host system.
- **Consistency:** Everyone gets the same environment, avoiding "works on my machine" problems.
- **Automation:** Setup is fast and repeatable.
- **Portability:** Move your project anywhere and run it the same way.

## Useful Tips

- If you change your schema or config, restart containers with:
  ```
  sudo docker compose up --force-recreate
  ```
- To clean up unused containers and volumes:
  ```
  docker system prune
  ```

---