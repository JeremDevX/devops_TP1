# Gym Management System

[![CI Pipeline](https://github.com/JeremDevX/devops_TP1/actions/workflows/ci.yml/badge.svg)](https://github.com/JeremDevX/devops_TP1/actions/workflows/ci.yml)
[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=cloud-native-gym&metric=alert_status&token=sqb_6f6aa51c89f6e92e20dd52cf00f7fce9a63fe006)](https://sonarcloud.io/dashboard?id=cloud-native-gym)

A complete fullstack gym management application built with modern web technologies, fully containerized with Docker and integrated into a complete CI/CD pipeline.

## 🔄 CI/CD Pipeline & Docker

### Docker Images

Docker images are automatically built, tested, and pushed to GitHub Container Registry (GHCR):

- **Backend**: `ghcr.io/<username>/cloudnative-backend:latest`
- **Frontend**: `ghcr.io/<username>/cloudnative-frontend:latest`

Each deployment includes both `:latest` and `:commit-sha` tags.

### Pipeline Execution

The CI/CD pipeline runs on a **self-hosted GitHub Actions runner** and includes:

1. **Lint** - Code style validation (ESLint)
2. **Build** - Compilation of frontend and backend
3. **Tests** - Backend test suite
4. **Docker Build** - Container image creation
5. **Docker Test** - Health checks and HTTP validation
6. **Docker Push** - Registry deployment (all branches)
7. **Deploy** - Automatic application deployment to local runner
8. **SonarCloud** - Code quality analysis

**Requirements:**

- Self-hosted runner with Docker installed
- GitHub secrets configured: `GHCR_TOKEN` (PAT with write:packages permission), `SONAR_TOKEN`
- Push triggers full pipeline including automatic deployment

```
lint → build → tests → docker-build → docker-test → docker-push → deploy → sonarcloud
```

### 🔄 Déploiement local automatisé

Le stage **deploy** redémarre automatiquement l'application après chaque publication d'image Docker, **uniquement sur les branches de production**.

#### Processus de déploiement

1. **Arrête les conteneurs en cours** : `docker compose down --remove-orphans`
   - ⚠️ Sans options destructrices (`--volumes`, `--rmi`) → **les données PostgreSQL sont préservées**
   
2. **Récupère les nouvelles images depuis GHCR** :
   ```bash
   docker pull ghcr.io/<username>/cloudnative-backend:<commit-sha>
   docker pull ghcr.io/<username>/cloudnative-frontend:<commit-sha>
   ```

3. **Redémarre l'application** : `docker compose up -d --pull always`
   - Lance tous les services (PostgreSQL, Backend, Frontend)
   - Lance les migrations Prisma automatiquement
   
4. **Vérifie que l'application fonctionne** :
   - Attend 10 secondes que les services soient prêts
   - Teste l'endpoint `/health` du backend
   - Aborte le déploiement en cas d'échec

#### Branches actives et conditions

Le déploiement s'exécute **automatiquement** uniquement lorsque :

- ✅ Un `push` est fait sur la branche **`main`** (production)
- ✅ Un `push` est fait sur la branche **`develop`** (staging)
- ✅ Les étapes précédentes (build, test, docker-push) ont réussi

**Important** : Les branches de feature (`feature/*`, `bugfix/*`, etc.) **ne déclenchent pas** le déploiement automatique. Elles exécutent le pipeline complet (lint, build, tests, docker-push) mais **sans redémarrer l'application en production**.

#### Prérequis pour le déploiement

- ✅ **Runner local GitHub Actions** actif et connecté à votre dépôt
- ✅ **Secret `GHCR_TOKEN`** configuré (PAT avec permission `write:packages`)
- ✅ **Accès au registre GHCR** (images doivent être publiques ou authentifiées)
- ✅ **Fichier `.env`** présent dans le répertoire du runner avec les variables :
  ```env
  POSTGRES_USER=gymuser
  POSTGRES_PASSWORD=gympass
  POSTGRES_DB=gymdb
  DATABASE_URL=postgresql://gymuser:gympass@postgres:5432/gymdb
  NODE_ENV=production
  BACKEND_PORT=3000
  FRONTEND_PORT=8080
  FRONTEND_URL=http://localhost:8080
  VITE_API_BASE_URL=http://localhost:3000/api
  ```
- ✅ **Docker & Docker Compose** installés sur le runner

#### Idempotence du déploiement

Le script de déploiement est **idempotent** et peut être exécuté **plusieurs fois de suite sans erreurs** :

- Les conteneurs arrêtés sont relancés proprement
- Les données PostgreSQL persistent entre les redémarrages
- Les migrations Prisma sont appliquées une seule fois
- En cas d'erreur, le script affiche les logs Docker pour le debugging

#### Exécution manuelle du déploiement

Vous pouvez aussi déclencher manuellement le déploiement sur le runner local :

```bash
./scripts/deploy.sh <commit-sha> <repository-owner>
```

Exemple :

```bash
./scripts/deploy.sh abc123def456 jeremdevx
```

📚 **Documentation complète** : Voir [TP4_DEPLOYMENT.md](TP4_DEPLOYMENT.md) pour tous les détails sur le déploiement automatique.

## Git Workflow

### Branches

- **`main`** - Production-ready code (protected)
- **`develop`** - Integration branch (protected)
- **`feature/*`** - Feature development (e.g., `feature/user-auth`)
- **`bugfix/*`** - Bug fixes (e.g., `bugfix/login-issue`)
- **`hotfix/*`** - Urgent production fixes (e.g., `hotfix/security-patch`)

### Commit Convention

Commits follow **Conventional Commits**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Test addition/update
- `chore`: Build/config changes

**Example:**

```
feat(auth): add JWT token refresh endpoint

- Implement refresh token mechanism
- Add expiration validation
- Update auth middleware

Closes #123
```

### Pull Request Rules

1. **Branch Protection** (main & develop)

   - ✅ CI Pipeline must pass (Lint, Build, Tests, SonarCloud)
   - ✅ Minimum 1 code review required
   - ✅ Quality Gate must pass (SonarCloud)
   - ❌ No direct pushes allowed

2. **PR Requirements**

   - Descriptive title and description
   - Link related issues (`Closes #123`)
   - Must be merged from feature branch

3. **Merge Strategy**
   - Use **Squash and merge** for features
   - Use **Rebase and merge** for hotfixes
   - Use **Create merge commit** for releases

## Features

### User Features

- **User Dashboard**: View stats, billing, and recent bookings
- **Class Booking**: Book and cancel fitness classes
- **Subscription Management**: View subscription details and billing
- **Profile Management**: Update personal information

### Admin Features

- **Admin Dashboard**: Overview of gym statistics and revenue
- **User Management**: CRUD operations for users
- **Class Management**: Create, update, and delete fitness classes
- **Booking Management**: View and manage all bookings
- **Subscription Management**: Manage user subscriptions

### Business Logic

- **Capacity Management**: Classes have maximum capacity limits
- **Time Conflict Prevention**: Users cannot book overlapping classes
- **Cancellation Policy**: 2-hour cancellation policy (late cancellations become no-shows)
- **Billing System**: Dynamic pricing with no-show penalties
- **Subscription Types**: Standard (€30), Premium (€50), Student (€20)

## Tech Stack

### Backend

- **Node.js** with Express.js
- **Prisma** ORM with PostgreSQL
- **RESTful API** with proper error handling
- **MVC Architecture** with repositories pattern

### Frontend

- **Vue.js 3** with Composition API
- **Pinia** for state management
- **Vue Router** with navigation guards
- **Responsive CSS** styling

### DevOps

- **Docker** containerization
- **Docker Compose** for orchestration
- **PostgreSQL** database
- **Nginx** for frontend serving

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Git

### Installation & Launch

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd gym-management-system
   ```

2. **Set up environment variables**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` file if needed (default values should work for development).

3. **Start the application with Docker Compose**

   ```bash
   docker compose up --build
   ```

   This command will:

   - Build Docker images for backend and frontend
   - Start PostgreSQL database
   - Start backend API server
   - Start frontend application with Nginx
   - Run database migrations and seeding

### Access the Application

- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Database**: localhost:5432 (local only)

### Default Login Credentials

The application comes with seeded test data:

**Admin User:**

- Email: admin@gym.com
- Password: admin123
- Role: ADMIN

**Regular Users:**

- Email: john.doe@email.com
- Email: jane.smith@email.com
- Email: mike.wilson@email.com
- Password: password123 (for all users)

## Project Structure

```
gym-management-system/
├── backend/
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── services/        # Business logic
│   │   ├── repositories/    # Data access layer
│   │   ├── routes/          # API routes
│   │   └── prisma/          # Database schema and client
│   ├── seed/                # Database seeding
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── views/           # Vue components/pages
│   │   ├── services/        # API communication
│   │   ├── store/           # Pinia stores
│   │   └── router/          # Vue router
│   ├── Dockerfile
│   └── nginx.conf
└── docker-compose.yml
```

## API Endpoints

### Authentication

- `POST /api/auth/login` - User login

### Users

- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Classes

- `GET /api/classes` - Get all classes
- `GET /api/classes/:id` - Get class by ID
- `POST /api/classes` - Create class
- `PUT /api/classes/:id` - Update class
- `DELETE /api/classes/:id` - Delete class

### Bookings

- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/user/:userId` - Get user bookings
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id/cancel` - Cancel booking
- `DELETE /api/bookings/:id` - Delete booking

### Subscriptions

- `GET /api/subscriptions` - Get all subscriptions
- `GET /api/subscriptions/user/:userId` - Get user subscription
- `POST /api/subscriptions` - Create subscription
- `PUT /api/subscriptions/:id` - Update subscription

### Dashboard

- `GET /api/dashboard/user/:userId` - Get user dashboard
- `GET /api/dashboard/admin` - Get admin dashboard

## Development

### Local Development Setup

1. **Backend Development**

   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Frontend Development**

   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Database Setup**
   ```bash
   cd backend
   npx prisma migrate dev
   npm run seed
   ```

### Database Management

- **View Database**: `npx prisma studio`
- **Reset Database**: `npx prisma db reset`
- **Generate Client**: `npx prisma generate`
- **Run Migrations**: `npx prisma migrate deploy`

### Useful Commands

```bash
# Stop all containers
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Rebuild specific service
docker-compose up --build [service-name]

# Access database
docker exec -it gym_db psql -U postgres -d gym_management
```

## Features in Detail

### Subscription System

- **STANDARD**: €30/month, €5 per no-show
- **PREMIUM**: €50/month, €3 per no-show
- **ETUDIANT**: €20/month, €7 per no-show

### Booking Rules

- Users can only book future classes
- Maximum capacity per class is enforced
- No double-booking at the same time slot
- 2-hour cancellation policy

### Admin Dashboard

- Total users and active subscriptions
- Booking statistics (confirmed, no-show, cancelled)
- Monthly revenue calculations
- User management tools

### User Dashboard

- Personal statistics and activity
- Current subscription details
- Monthly billing with no-show penalties
- Recent booking history

## 🌿 Git Workflow & Conventions

### Branch Strategy

We follow a professional Git workflow with the following branch structure:

- **`main`** - Production branch (stable releases only)
- **`develop`** - Integration branch for features
- **`feature/<nom>`** - Feature branches (created from `develop`)

**Rules:**

- ❌ Never commit directly to `main` or `develop`
- ✅ Always create a feature branch: `git checkout -b feature/your-feature develop`
- ✅ Create a Pull Request to merge into `develop`
- ✅ PR must be reviewed before merging

### Conventional Commits

All commits must follow the **Conventional Commit** format enforced by Commitlint:

```
<type>(<scope>): <subject>
```

**Allowed types:**

- `feat:` - New feature
  - Example: `feat: add user authentication`
- `fix:` - Bug fix
  - Example: `fix: resolve database connection issue`
- `chore:` - Maintenance tasks, dependency updates
  - Example: `chore: update NestJS dependencies`
- `docs:` - Documentation updates
  - Example: `docs: update API endpoints`
- `style:` - Code style (formatting, semicolons, etc.)
- `refactor:` - Code refactoring without feature changes
- `test:` - Adding or updating tests
- `ci:` - CI/CD configuration changes
- `build:` - Build system changes
- `perf:` - Performance improvements
- `revert:` - Revert a previous commit

**Examples:**

```bash
git commit -m "feat: add class booking functionality"
git commit -m "fix: correct Postgres connection pool size"
git commit -m "chore: upgrade Vue.js to v3.4"
git commit -m "docs: add deployment guide"
```

### 🔒 Git Hooks (Automated Quality Checks)

This project uses **Husky** for automated Git hooks that enforce code quality:

#### 1. **`pre-commit` Hook**

- 🔐 Detects hardcoded secrets, API keys, and tokens with **Gitleaks**
- ❌ Blocks commit if secrets are detected
- ✅ Allows clean, secure commits only

**How it works:**

```bash
git add .
git commit -m "feat: new feature"
# → Gitleaks scans files
# → If secrets found: ❌ Commit blocked
# → If clean: ✅ Commit allowed
```

#### 2. **`commit-msg` Hook**

- ✅ Validates commit message format with **Commitlint**
- ❌ Rejects commits that don't follow Conventional Commits
- 📋 Shows helpful error messages

**Invalid commits will be rejected:**

```bash
git commit -m "lol: just testing stuff"
# ❌ Error: type must be one of [feat, fix, chore, etc.]
```

#### 3. **`pre-push` Hook**

- 📦 Builds frontend and backend before pushing
- ❌ Blocks push if build fails
- 🛡️ Ensures only working code reaches remote repository

**Before pushing to GitHub:**

```bash
git push origin feature/my-feature
# → Builds frontend
# → Builds backend (if applicable)
# → If successful: ✅ Push allowed
# → If failed: ❌ Push blocked
```

### 🚀 Typical Workflow

```bash
# 1. Create feature branch
git checkout -b feature/user-profile develop

# 2. Make changes and commit (hooks run automatically)
echo "new feature code" > src/newFeature.js
git add src/newFeature.js
git commit -m "feat: add user profile page"
# → pre-commit hook runs (Gitleaks checks)
# → commit-msg hook runs (Commitlint validates message)
# → ✅ Commit successful

# 3. Push to remote (hooks run automatically)
git push -u origin feature/user-profile
# → pre-push hook runs (build verification)
# → ✅ Push successful

# 4. Create Pull Request on GitHub
# → Get code review
# → Merge into develop

# 5. Later, merge develop → main for release
git checkout main
git merge develop
git tag v1.0.0
git push origin main --tags
```

### ⚠️ Emergency: Bypassing Hooks (Not Recommended)

If absolutely necessary, you can skip hooks (use with caution):

```bash
git commit --no-verify  # Skips pre-commit and commit-msg hooks
git push --no-verify   # Skips pre-push hook
```

**⚠️ WARNING:** Only use `--no-verify` in emergencies. It defeats the purpose of automated quality checks.

### 🔗 Branch Protection Rules (GitHub)

The `main` and `develop` branches are protected with:

- ✅ Require pull request reviews
- ✅ Block direct pushes
- ✅ Require linear history
- ✅ Require status checks (CI/CD pipelines)

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch from `develop`: `git checkout -b feature/your-feature develop`
3. Make your changes following Conventional Commits
4. Ensure your commits pass all Git hooks
5. Push to your branch
6. Submit a Pull Request to `develop`
7. Wait for code review and CI/CD checks to pass
8. Merge only after approval

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.
