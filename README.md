# Microservices Todo List Application

A microservices-based Todo List application built with Lumen, Docker, and PostgreSQL.

## Architecture

- **API Gateway**: Lumen (Port 8000)
- **User Service**: Lumen (Port 8001) 
- **Todo Service**: Lumen (Port 8002)
- **Database**: PostgreSQL

## Services

### User Service
- User registration and authentication
- JWT token management
- User profile management

### Todo Service  
- Todo CRUD operations
- Todo categorization
- User-specific todo management

### API Gateway
- Request routing
- Authentication middleware
- Service orchestration

## Tech Stack

- **Framework**: Lumen (PHP)
- **Database**: PostgreSQL
- **Authentication**: JWT
- **Containerization**: Docker & Docker Compose
- **API**: RESTful

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/microservices-todo.git
cd microservices-todo