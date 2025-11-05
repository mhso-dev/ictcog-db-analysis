# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker-based data analysis educational environment combining MySQL 8.0 and Python 3.11 with Jupyter Lab. Designed for Korean language support in data visualization (matplotlib, seaborn, plotly) with NanumGothic font pre-installed.

## Architecture

**Container Structure:**
- `mysql`: MySQL 8.0 database server with persistent volume storage
- `python`: Python 3.11 container running Jupyter Lab (port 8888) and Streamlit (port 8501)
- Containers communicate via Docker network (python → mysql using hostname `mysql`)

**Volume Mappings:**
- `./notebooks` ↔ `/workspace/notebooks` - Jupyter notebooks (persistent)
- `./data` ↔ `/workspace/data` - Data files (persistent)
- `./streamlit_apps` ↔ `/workspace/streamlit_apps` - Streamlit apps (persistent)
- `mysql_data` - Named volume for MySQL data persistence

**Key Design Pattern:**
- Python code inside containers MUST use `MYSQL_HOST=mysql` (Docker network hostname)
- External clients (DBeaver, etc.) use `MYSQL_HOST=localhost` (port mapping)
- Environment variables are pre-configured in docker-compose.yml for container usage

## Essential Commands

### Container Management
```bash
# Start all services (build if needed)
docker-compose up -d --build

# Check container status
docker-compose ps

# View logs (all or specific service)
docker-compose logs -f
docker-compose logs -f python
docker-compose logs -f mysql

# Restart services
docker-compose restart

# Stop services (preserves volumes)
docker-compose stop

# Stop and remove containers (preserves volumes)
docker-compose down

# Complete reset (WARNING: deletes all MySQL data)
docker-compose down -v
docker volume rm database-data-analysis_mysql_data
docker-compose up -d --build
```

### Container Access
```bash
# Access Python container shell
docker exec -it practice_python bash

# Access MySQL container shell
docker exec -it practice_mysql bash

# Direct MySQL CLI access
docker exec -it practice_mysql mysql -u user -p1111
docker exec -it practice_mysql mysql -u root -p1111
```

### Streamlit Operations
```bash
# Inside Python container
docker exec -it practice_python bash
streamlit run streamlit_apps/app.py

# Then access: http://localhost:8501
```

### Package Management
```bash
# Method 1: Install directly in container (temporary)
docker exec -it practice_python pip install package_name

# Method 2: Persistent installation
# 1. Add package to python/requirements.txt
# 2. Rebuild Python container
docker-compose up -d --build python
```

## Database Connection Patterns

### From Jupyter/Python Inside Container
```python
import pymysql
from sqlalchemy import create_engine
import os

# CRITICAL: Use 'mysql' hostname, NOT 'localhost'
MYSQL_HOST = os.getenv('MYSQL_HOST', 'mysql')  # Default: 'mysql'
MYSQL_USER = os.getenv('MYSQL_USER', 'user')
MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '1111')
MYSQL_DATABASE = os.getenv('MYSQL_DATABASE', 'analysis_db')

# PyMySQL direct connection
connection = pymysql.connect(
    host=MYSQL_HOST,  # Must be 'mysql' in container
    port=3306,
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database=MYSQL_DATABASE
)

# SQLAlchemy engine
engine = create_engine(
    f'mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:3306/{MYSQL_DATABASE}'
)
```

### From External Clients (DBeaver, etc.)
- Host: `localhost` (port 3306 is mapped to host)
- Database: `analysis_db`
- User: `user`
- Password: `1111`
- Root password: `1111`

**DBeaver Connection Properties:**
```
allowPublicKeyRetrieval=true
useSSL=false
```

## Korean Font Configuration

All matplotlib-based visualizations MUST include font configuration for Korean text:

```python
import matplotlib.pyplot as plt

# Required at start of notebook/script
plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False
```

## Service Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| Jupyter Lab | http://localhost:8888 | No token required |
| Streamlit | http://localhost:8501 | Start app first |
| MySQL | localhost:3306 | External client access |

## Common Issues & Solutions

**MySQL Connection Refused:**
- Verify container is running: `docker-compose ps`
- Check if using correct hostname (`mysql` inside containers, `localhost` outside)
- Wait 10-15 seconds after `docker-compose up` for MySQL initialization

**Access Denied Errors:**
- Execute complete reset: `docker-compose down -v && docker-compose up -d --build`
- Reason: Persistent volume may have conflicting credentials

**Korean Text Shows as Boxes:**
- Add font configuration (see Korean Font Configuration section)
- Verify NanumGothic is installed: `docker exec -it practice_python fc-list | grep Nanum`

**Port Already in Use:**
- Check existing processes: `lsof -i :8888` or `lsof -i :3306`
- Modify port mappings in docker-compose.yml

## File Organization Conventions

- `notebooks/` - Jupyter notebooks for interactive analysis
- `data/` - CSV, Excel, or other data files
- `streamlit_apps/` - Streamlit dashboard applications
- `mysql/init.sql` - MySQL initialization scripts (runs once on first container creation)

## Critical Environment Variables

Inside Python container (pre-configured in docker-compose.yml):
- `MYSQL_HOST=mysql` (Docker network hostname)
- `MYSQL_USER=user`
- `MYSQL_PASSWORD=1111`
- `MYSQL_DATABASE=analysis_db`

**IMPORTANT:** Always use `os.getenv()` to read these values, never hardcode `localhost` for MySQL host.

## Testing New Code

Before committing changes to Python code or notebooks:
1. Restart Python container: `docker-compose restart python`
2. Check logs for errors: `docker-compose logs python`
3. Test database connectivity in Jupyter Lab
4. Verify Korean font rendering in visualizations

## Google BigQuery Integration (Optional)

If BigQuery support is needed:
1. Place service account JSON key in `credentials/` directory
2. Add volume mount in docker-compose.yml:
   ```yaml
   volumes:
     - ./credentials:/workspace/credentials
   ```
3. Set environment variable:
   ```yaml
   environment:
     - GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials/your-key.json
   ```
