# Kointos API Documentation

This document provides an overview of the Kointos API endpoints and how to use them.

## Getting Started

To start the API server:

```bash
./run-api-server.sh
```

By default, the server runs on port 8080. You can customize the port by setting the `API_PORT` environment variable:

```bash
API_PORT=9000 ./run-api-server.sh
```

## Authentication

Most endpoints require authentication using a JWT token. Include the token in the Authorization header:

```
Authorization: Bearer <your_token>
```

## API Endpoints

### Users

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|--------------|
| `/users` | GET | Get list of users | No |
| `/users` | POST | Create a new user | No |
| `/users/{id}` | GET | Get user details | No |
| `/users/{id}` | PUT | Update user | Yes |
| `/users/{id}` | DELETE | Delete user | Yes |
| `/users/{id}/profile` | GET | Get user profile | No |
| `/users/{id}/profile` | PUT | Update user profile | Yes |
| `/users/{id}/follow` | POST | Follow user | Yes |
| `/users/{id}/follow` | DELETE | Unfollow user | Yes |

### Cryptocurrencies

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|--------------|
| `/cryptocurrencies` | GET | Get list of cryptocurrencies | No |
| `/cryptocurrencies/{id}` | GET | Get cryptocurrency details | No |
| `/cryptocurrencies/{id}/market-data` | GET | Get market data for a cryptocurrency | No |
| `/cryptocurrencies/trending` | GET | Get trending cryptocurrencies | No |

### Portfolios

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|--------------|
| `/portfolios` | GET | Get user's portfolios | Yes |
| `/portfolios` | POST | Create a new portfolio | Yes |
| `/portfolios/{id}` | GET | Get portfolio details | Yes |
| `/portfolios/{id}` | PUT | Update portfolio | Yes |
| `/portfolios/{id}` | DELETE | Delete portfolio | Yes |
| `/portfolios/{id}/items` | GET | Get portfolio items | Yes |
| `/portfolios/{id}/items` | POST | Add item to portfolio | Yes |
| `/portfolios/{id}/items/{itemId}` | GET | Get portfolio item details | Yes |
| `/portfolios/{id}/items/{itemId}` | PUT | Update portfolio item | Yes |
| `/portfolios/{id}/items/{itemId}` | DELETE | Remove item from portfolio | Yes |
| `/portfolios/{id}/performance` | GET | Get portfolio performance data | Yes |

### Posts

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|--------------|
| `/posts` | GET | Get list of posts | No |
| `/posts` | POST | Create a new post | Yes |
| `/posts/{id}` | GET | Get post details | No |
| `/posts/{id}` | PUT | Update post | Yes |
| `/posts/{id}` | DELETE | Delete post | Yes |
| `/posts/{id}/like` | POST | Like a post | Yes |
| `/posts/{id}/like` | DELETE | Unlike a post | Yes |
| `/posts/{id}/comments` | GET | Get post comments | No |
| `/posts/{id}/comments` | POST | Add comment to post | Yes |
| `/posts/user/{userId}` | GET | Get user's posts | No |

### Articles

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|--------------|
| `/articles` | GET | Get list of articles | No |
| `/articles` | POST | Create a new article | Yes |
| `/articles/{id}` | GET | Get article details | No |
| `/articles/{id}` | PUT | Update article | Yes |
| `/articles/{id}` | DELETE | Delete article | Yes |
| `/articles/{id}/like` | POST | Like an article | Yes |
| `/articles/{id}/like` | DELETE | Unlike an article | Yes |
| `/articles/{id}/comments` | GET | Get article comments | No |
| `/articles/{id}/comments` | POST | Add comment to article | Yes |
| `/articles/featured` | GET | Get featured articles | No |
| `/articles/user/{userId}` | GET | Get user's articles | No |

## Query Parameters

Many GET endpoints support the following query parameters:

- `page`: Page number for pagination (default: 1)
- `limit`: Number of items per page (default: 20, max: 100)

## Response Format

All endpoints return JSON responses with appropriate HTTP status codes.

### Success Response

```json
{
  "data": [ ... ],  // For list endpoints
  "page": 1,        // Current page (for paginated responses)
  "limit": 20       // Items per page (for paginated responses)
}
```

### Error Response

```json
{
  "error": "Error message"
}
```

## Status Codes

- `200 OK`: Request succeeded
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Not authorized to perform the action
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error
