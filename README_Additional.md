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

⚠️ **CURRENTLY DISABLED**: SonarQube analysis is temporarily disabled due to breaking changes in SonarCloud API.

**Issue**: The `/analysis/analyses` endpoint returns `404` errors affecting all SonarScanner versions (9.x, 10.x, 11.x) both locally and in CI/CD. This is a known SonarCloud API compatibility issue.

**Status**: 
- ❌ Local analysis: **Disabled** (API 404 error)
- ❌ CI/CD analysis: **Disabled** (workflow set to manual trigger only)

**Workaround**: The workflow can be manually triggered via GitHub Actions if needed, but will fail at the "Sonarqube End" step.

**Resolution**: Waiting for SonarSource to fix the API compatibility. The workflow will be re-enabled once the issue is resolved upstream.

<details>
<summary>Setup Instructions (for when the issue is fixed)</summary>

#### Local Analysis Setup

**One-time setup**:

```bash
# Install SonarScanner globally
dotnet tool install --global dotnet-sonarscanner 

# Configure token
cd src/Aspire/BookWorm.AppHost
dotnet user-secrets set "Sonar:Token" "your-sonarcloud-token-here"
```

**Run Analysis**:

```powershell
# Execute the analysis script (reads token from User Secrets)
.\scripts\run-sonar-analysis.ps1
```

</details>


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

