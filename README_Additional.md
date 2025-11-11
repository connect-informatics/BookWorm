# Developer Setup Guide

## Prerequisites

Before you start, ensure you have the following installed:

### Required

- [npm](https://www.npmjs.com/) - v9.0.0 or higher (check with `npm --version`)

### Configure Local Secrets

The project uses User Secrets for local development. You'll need to configure:

```bash
# Navigate to AppHost
cd src/Aspire/BookWorm.AppHost

# Initialize user secrets (if not already initialized)
dotnet user-secrets init

# Set required secrets (see appsettings.Development.json for required values)
dotnet user-secrets set "Parameters:postgres-user" "postgres"
dotnet user-secrets set "Parameters:postgres-password" "your-dev-password"
```

## Development Workflow

### Linting API Specifications

The project includes OpenAPI and AsyncAPI specifications that should be validated before committing:

```bash
# Lint all API specs
npm run lint:api

# Lint only OpenAPI specs
npm run lint:openapi

# Lint only AsyncAPI specs
npm run lint:asyncapi
```

**VS Code Integration**: Install the [Spectral extension](https://marketplace.visualstudio.com/items?itemName=stoplight.spectral) for real-time linting in the editor.


## Common Issues

### PostgreSQL container fails to start

**Solution**: 
1. Stop and remove existing containers: `docker stop $(docker ps -aq) && docker rm $(docker ps -aq)`
2. Remove volumes: `docker volume prune -f`
3. Restart Docker Desktop
4. Run the application again

## CI/CD Integration

The project uses GitHub Actions for CI/CD. Your local setup should match what runs in CI:

- **Format check**: `dotnet format --verify-no-changes`
- **Build**: `dotnet build`
- **Test**: `dotnet test`
- **API linting**: `npm run lint:api` (if configured in CI)

Run these commands before pushing to ensure CI will pass.

