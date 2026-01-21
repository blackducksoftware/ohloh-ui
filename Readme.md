# OhlohUI

A Ruby on Rails application for the Open Hub platform.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [Pull Request Checks](#pull-request-checks)
- [Contributing](#contributing)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby**: 3.1.7 (use `rbenv` or `rvm`)
- **Rails**: 6.1.7.10
- **PostgreSQL**: Latest stable version

### System-Specific Requirements

#### macOS
```bash
brew install postgresql
brew services start postgresql
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib libpq-dev
```

# Install Ruby version manager (rbenv)
```bash
brew install rbenv
rbenv install 3.1.7
rbenv global 3.1.7
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone git@github.com:blackducksoftware/ohloh-ui.git
cd ohloh-ui
```

### 2. Install Dependencies

```bash
gem install bundler
bundle install
```

## 💾 Database Setup

### 1. Configure Environment Variables

Create a file named `.env.development` in the project root with the following content:

```bash
DB_ENCODING=UTF-8
DB_HOST=localhost
DB_NAME=oh_db
DB_USERNAME=fis_user
DB_PASSWORD=fis_password

TEST_DB_HOST=localhost
TEST_DB_NAME=oh_test
TEST_DB_USERNAME=fis_user
TEST_DB_PASSWORD=fis_password
```

### 2. Create PostgreSQL User

```bash
psql postgres
```

In PostgreSQL prompt:
```sql
CREATE USER fis_user WITH PASSWORD 'fis_password';
ALTER USER fis_user WITH SUPERUSER;
```

> **Note**: The default DB encoding was set to SQL_ASCII for legacy data compatibility. UTF-8 encoding is recommended for new data.

### 2. Create and Setup Databases

```bash
rails db:create
rake db:structure:load
rake db:migrate
```

> **Note**: You may see errors about existing relations and constraints. These can be safely ignored.

### 3. Setup Admin User

Create a default admin user (arguments are optional):

```bash
ruby script/setup_default_admin.rb <login> <password> <email>
```

**Default credentials if no arguments provided:**
- Login: `admin_user`
- Password: `admin_password`
- Email: `admin@example.com`

## ▶️ Running the Application

Start the Rails server:

```bash
rails s
```

Visit [http://localhost:3000](http://localhost:3000) to view the application.

## 🧪 Testing

### Unit & Integration Tests
Run the full test suite:

```bash
$ rake test
```

Run a single test file:

```bash
$ rake test test/models/account_test.rb
```

Run a directory of tests:

```bash
$ rake test test/models
```

## 🔄 Pull Request Checks

### Pre Pull Request Checks

The CI pipeline runs the following checks on all pull requests:

```bash
rake ci:all_tasks
```

This includes:
- **rubocop** - Ruby style linting
- **bundle audit** - Dependency vulnerability checking
- **rake test** - Ruby unit tests

### Post Pull Request Checks

After all the successful checks, CI pipeline will have success message like
`All checks has been passed`.

## 🤝 Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Run `rake ci:all_tasks` to ensure all checks pass
4. Submit a pull request

## 📝 License

See [LICENSE](LICENSE) file for details.

## 🔒 Security

For security concerns, please refer to [security.md](security.md).
