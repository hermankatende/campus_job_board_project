# campus_job_board_project

A central platform where:
- **Students** can look for job opportunities
- **Recruiters** can find potential candidates
- **Lecturers** can share job opportunities with students

Built with Flutter for cross-platform support and a Django backend for business logic, role workflows, and administration.

## Render Deployment

The backend is ready to deploy to Render from `django_backend/`.

### Render Web Service

- **Environment:** Python
- **Root Directory:** `django_backend`
- **Build Command:** `pip install -r requirements.txt && python manage.py collectstatic --noinput`
- **Start Command:** `gunicorn config.wsgi:application`

### Required Environment Variables

- `DJANGO_SECRET_KEY`
- `DJANGO_DEBUG=False`
- `DJANGO_ALLOWED_HOSTS=your-service-name.onrender.com`
- `DJANGO_CSRF_TRUSTED_ORIGINS=https://your-service-name.onrender.com`
- `DATABASE_URL=postgresql://...`

Optional but typically required for this project:

- `DJANGO_CORS_ALLOWED_ORIGINS`
- `FIREBASE_CREDENTIALS_FILE` or `FIREBASE_CREDENTIALS_JSON`
- `LECTURER_HOD_EMAIL`
- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD`, `EMAIL_USE_TLS`, `DEFAULT_FROM_EMAIL`

### Notes

- Supabase works well as the production PostgreSQL host.
- Render injects `RENDER_EXTERNAL_HOSTNAME`, and the backend now accepts it automatically.
- Static files are served with WhiteNoise.
- Run `python manage.py migrate` once from Render Shell after setting environment variables.

## Flutter Backend URL

The Flutter app reads `BACKEND_URL` from the root `.env` file, or from a compile-time define:

- `.env`: `BACKEND_URL=https://campus-job-board-api.onrender.com`
- build/run override: `--dart-define=BACKEND_URL=https://campus-job-board-api.onrender.com`

An example app env file is included at `.env.example`.

