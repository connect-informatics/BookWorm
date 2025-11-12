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

# Set SonarQube token for local analysis (optional)
dotnet user-secrets set "Sonar:Token" "your-sonarcloud-token-here"
```

> **Note**: Get your SonarCloud token from [SonarCloud Security Settings](https://sonarcloud.io/account/security).

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

### SonarQube Analysis

#### CI/CD Analysis (Recommended)

SonarQube analysis runs automatically on GitHub Actions for every push to `main` and on pull requests. **This is the recommended approach** due to current API limitations with local analysis.

#### Local Analysis (Currently Limited)

⚠️ **Known Issue**: SonarCloud API currently has compatibility issues with recent SonarScanner versions, causing `404` errors on the `/analysis/analyses` endpoint. Local analysis may fail until this is resolved upstream.

If you still want to try local analysis:

**Setup (One-time)**:

```bash
# Install SonarScanner globally
dotnet tool install --global dotnet-sonarscanner --version 10.0.0

# Configure token (see "Configure Local Secrets" section above)
cd src/Aspire/BookWorm.AppHost
dotnet user-secrets set "Sonar:Token" "your-sonarcloud-token-here"
```

**Run Analysis**:

```powershell
# Execute the analysis script (reads token from User Secrets)
.\scripts\run-sonar-analysis.ps1
```

The script will:
1. Verify `dotnet-sonarscanner` installation
2. Read the SonarQube token from User Secrets (secure)
3. Execute SonarScanner begin
4. Build the solution
5. Execute SonarScanner end (upload results to SonarCloud)

**Note**: If the analysis fails with a `404` error, this is a known SonarCloud API issue. Please rely on the CI/CD pipeline for SonarQube analysis until resolved.


## Common Issues

### PostgreSQL container fails to start

**Solution**: 
1. Stop and remove existing containers: `docker stop $(docker ps -aq) && docker rm $(docker ps -aq)`
2. Remove volumes: `docker volume prune -f`
3. Restart Docker Desktop
4. Run the application again

### SonarQube Analysis Fails with 404 Error

**Issue**: Local SonarQube analysis fails with "Error 404 on https://api.sonarcloud.io/analysis/analyses"

**Solution**: This is a known SonarCloud API issue with recent scanner versions. Use the CI/CD pipeline instead:

```bash
# Push to trigger CI/CD analysis
git push origin main
```

The SonarQube analysis will run automatically in GitHub Actions.

## CI/CD Integration

The project uses GitHub Actions for CI/CD. Your local setup should match what runs in CI:

- **Format check**: `dotnet format --verify-no-changes`
- **Build**: `dotnet build`
- **Test**: `dotnet test`
- **API linting**: `npm run lint:api` (if configured in CI)

Run these commands before pushing to ensure CI will pass.

