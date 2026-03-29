# Flodo Task App

A full-stack Task Management app built for the Flodo AI Take-Home Assessment.

**Track A** — Full-Stack Builder (FastAPI + SQLite + Flutter)  
**Stretch Goal** — Debounced Autocomplete Search with match highlighting

---

## Features

- ✅ Full CRUD for tasks (Title, Description, Due Date, Status, Blocked By)
- 🚫 Blocked task visual state — greyed-out cards with lock icon
- 🔍 Debounced search (300 ms) with highlighted matching text
- 📋 Filter tasks by status (To-Do / In Progress / Done)
- 💾 Draft persistence — in-progress forms survive app minimization
- ⏳ Simulated 2-second save delay with loading state + double-tap protection
- 🔄 Drag-and-drop task reordering persisted to the database

---

## Tech Stack

| Layer     | Technology                 |
|-----------|----------------------------|
| Frontend  | Flutter 3.29 (Android + iOS) |
| State     | Riverpod                   |
| Backend   | FastAPI (Python 3.12)      |
| Database  | SQLite (via SQLAlchemy)    |
| HTTP      | Dio                        |

---

## Project Structure

```
flodo_ai_assessment/
├── backend/       # FastAPI REST API
└── frontend/      # Flutter mobile app
```

---

## Setup & Running 🚀

The easiest way to run the entire stack locally without installing Python or Flutter SDKs is to use Docker Compose.

### Running with Docker (Recommended)

Ensure you have [Docker](https://www.docker.com/) installed, then run from the project root:

```bash
docker compose up --build -d
```

That's it! 
- **Flodo Web App**: Access it at [http://localhost](http://localhost)
- **Backend API**: Running at `http://localhost:8000`
- **API Docs**: Interactive Swagger UI at `http://localhost:8000/docs`

*(The database uses a persistent local volume so your tasks won't disappear on container restart).*

---

### Manual Setup (Without Docker)

#### Backend

```bash
cd backend

# 1. Create virtual environment
python -m venv .venv
.venv\Scripts\activate       # Windows
# source .venv/bin/activate  # Mac/Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Copy env file
copy .env.example .env      # Windows
# cp .env.example .env      # Mac/Linux

# 4. Start the server
uvicorn main:app --reload
```

API runs at `http://localhost:8000`  
Interactive docs at `http://localhost:8000/docs`

---

### Frontend

```bash
cd frontend

# 1. Copy env file
copy .env.example .env      # Windows
# cp .env.example .env      # Mac/Linux

# 2. Get packages
flutter pub get

# 3. Run on your device/emulator
flutter run
```

> **Android Emulator**: Uses `10.0.2.2:8000` to reach host localhost.  
> **iOS Simulator**: Uses `localhost:8000` directly.

---

## API Overview

| Method | Endpoint           | Description                       |
|--------|--------------------|-----------------------------------|
| GET    | /tasks             | List all tasks (`?q=` for search) |
| POST   | /tasks             | Create task (2s delay)            |
| GET    | /tasks/{id}        | Get single task                   |
| PUT    | /tasks/{id}        | Update task (2s delay)            |
| DELETE | /tasks/{id}        | Delete task                       |
| PATCH  | /tasks/reorder     | Update drag-and-drop order        |
| GET    | /health            | Health check                      |

---

## AI Usage Report

> 💡 **For a complete breakdown of the prompting strategy and the workflow used to build this full-stack project, please read [`workflow.md`](./workflow.md).**

### Most helpful prompts

1. *"Design a FastAPI + SQLAlchemy project for a Task model with a self-referential 'blocked_by' foreign key, position-based drag-and-drop, and async CRUD operations with a 2-second simulated delay."*  
   → Generated the full backend skeleton with correct async patterns.

2. *"Build a Flutter Riverpod StateNotifier for async task operations with optimistic UI updates for drag-and-drop reordering."*  
   → Gave the core provider structure with `AsyncValue` patterns.

3. *"Implement a debounced search TextField in Flutter that waits 300ms after the user stops typing, then highlights matching substrings in a RichText widget."*  
   → Clean `Timer`-based debounce + `TextSpan` highlight logic.

## Commit History Convention

| Commit message              | What it covers                      |
|-----------------------------|-------------------------------------|
| `chore: project setup`      | Scaffolding, .gitignore, README     |
| `feat: backend implementation` | FastAPI + SQLite CRUD API        |
| `feat: flutter core screens`   | Home screen, task cards, CRUD UI |
| `feat: debounced search`       | 300ms debounce + match highlight |
| `feat: drag and drop`          | Reorderable list + persistence   |
| `fix: <description>`           | Bug fixes as needed               |
