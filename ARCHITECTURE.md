# Campus Job Board - Complete System Architecture

## 1. System Overview

**Campus Job Board (CJB)** is a multi-role job posting and application platform built with:
- **Frontend**: Flutter (Android/iOS)
- **Backend**: Django REST Framework
- **Authentication**: Firebase Auth + Django Profile Sync
- **Database**: PostgreSQL (via Supabase)
- **File Storage**: Cloudinary for images/resumes
- **Deployment**: Render (backend), Firebase (frontend)
- **Notifications**: Firebase Cloud Messaging (FCM)

### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                          │
│  (lib/ directory - Android/iOS builds)                           │
└──────────────┬──────────────────────────────────────────────────┘
               │
               │ Firebase ID Token (Bearer Authorization)
               │ HTTPS
               │
┌──────────────▼──────────────────────────────────────────────────┐
│         Django REST API (Render)                                │
│  /api/users/  /api/jobs/  /api/applications/  /api/common/     │
└──────────────┬──────────────────────────────────────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
    ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌──────────────┐
│Firebase│ │Postgres│ │ Cloudinary   │
│Auth +  │ │(via    │ │ (file        │
│FCM     │ │Supabase)│ │storage)      │
└────────┘ └────────┘ └──────────────┘
```

---

## 2. Authentication System

### **2.1 Authentication Flow**

```
┌─────────────┐
│   User      │
│  Enter      │
│  Email/Pwd  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│ Firebase Auth                   │
│ (createUserWithEmailAndPassword)│
│ (signInWithEmailAndPassword)    │
└────────────┬────────────────────┘
             │
             ▼
     ┌───────────────┐
     │Firebase Token │
     │(ID Token)     │
     └───────┬───────┘
             │
             ▼
┌─────────────────────────────┐
│ ApiClient - Attach Token    │
│ Authorization: Bearer <token>
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Django Backend                      │
│ - Verify Firebase token             │
│ - Create/Update UserProfile         │
│ - Return synced profile with role   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ AuthService._syncProfile()      │
│ Caches UserProfile object       │
│ Routes to correct dashboard     │
└─────────────────────────────────┘
```

**Key Files:**
- [lib/services/auth_service.dart](lib/services/auth_service.dart) - Main authentication logic
- [lib/firebase_options.dart](lib/firebase_options.dart) - Firebase config
- [lib/services/api_client.dart](lib/services/api_client.dart) - Token attachment

**Authentication Flow Steps:**

1. **Sign Up** (line 184 in auth_service.dart):
   ```dart
   Future<UserProfile> register({
     required String email,
     required String password,
     required String role,
     Map<String, dynamic> profileData = const {},
   })
   ```
   - Creates Firebase account
   - Calls `GET /api/users/me/` to create backend profile
   - PATCHes role + profile data to backend

2. **Sign In** (line 168 in auth_service.dart):
   ```dart
   Future<UserProfile> signIn(String email, String password)
   ```
   - Uses Firebase to authenticate
   - Calls `GET /api/users/me/` to sync profile
   - Caches profile for role-based routing

3. **Token Attachment** (api_client.dart, line 48):
   ```dart
   Future<Map<String, String>> _headers({bool auth = true}) async {
     final token = await user.getIdToken(forceTokenRefresh);
     headers['Authorization'] = 'Bearer $token';
   }
   ```

**Django Backend Authentication:**
- Uses Firebase Admin SDK to verify JWT tokens
- Custom middleware extracts firebase_user data from token
- All endpoints protected with `@permission_classes([IsAuthenticated])`

---

## 3. User Roles and Profile Structure

### **3.1 User Roles**

[django_backend/apps/users/models.py](django_backend/apps/users/models.py) defines 4 roles:

```python
class Role(models.TextChoices):
    STUDENT = "student", "Student"
    RECRUITER = "recruiter", "Recruiter"
    LECTURER = "lecturer", "Lecturer"
    ADMIN = "admin", "Admin"
```

### **3.2 UserProfile Model**

**Location:** [django_backend/apps/users/models.py](django_backend/apps/users/models.py)

```python
class UserProfile(models.Model):
    # Core fields (all roles)
    firebase_uid = CharField(unique=True)
    email = EmailField()
    full_name = CharField()
    role = CharField(choices=Role.choices)
    phone = CharField()
    image_url = URLField
    gender = CharField()
    age_range = CharField()
    
    # Shared profile fields
    about_me = TextField()
    skills = TextField()
    portfolio_url = URLField()
    
    # Student-specific
    college = CharField()
    program = CharField()
    student_number = CharField()
    work_experience = TextField()
    education = TextField()
    hobbies_interests = TextField()
    job_preference = CharField()
    resume_url = URLField()
    notifications_enabled = BooleanField()
    fcm_token = TextField()
    
    # Recruiter-specific
    company_name = CharField()
    company_description = TextField()
    company_website = URLField()
    company_location = CharField()
    
    # Lecturer-specific
    department = CharField()
    is_verified = BooleanField()  # Verified by HOD/Admin
    is_suspended = BooleanField()
```

### **3.3 Flutter UserProfile Class**

[lib/services/auth_service.dart](lib/services/auth_service.dart) mirrors Django model:

```dart
class UserProfile {
  final int id;
  final String firebaseUid;
  final String email;
  final String fullName;
  final String role;  // student | recruiter | lecturer | admin
  
  // All fields from Django, with getters:
  bool get isStudent => role == 'student';
  bool get isRecruiter => role == 'recruiter';
  bool get isLecturer => role == 'lecturer';
  bool get isAdmin => role == 'admin';
}
```

### **3.4 Role-Based Navigation**

[lib/pages/app_router.dart](lib/pages/app_router.dart):

```dart
Widget homePageForProfile(UserProfile profile) {
  if (profile.isAdmin) return AdminMainPage();
  if (profile.isRecruiter) return RecruiterMainPage();
  if (profile.isLecturer) return LecturerMainPage();
  return MainPage();  // Student dashboard
}

bool needsOnboarding(UserProfile profile) {
  if (profile.isStudent) {
    return profile.college.isEmpty || 
           profile.program.isEmpty || 
           profile.studentNumber.isEmpty;
  }
  if (profile.isRecruiter) return profile.companyName.isEmpty;
  if (profile.isLecturer) return profile.department.isEmpty;
  return false;
}
```

**Home Pages:**
- **Students**: [lib/pages/main/main_page/main_page.dart](lib/pages/main/main_page/main_page.dart)
- **Recruiters**: [lib/pages/main/recruiter_main_page.dart](lib/pages/main/recruiter_main_page.dart)
- **Lecturers**: [lib/pages/main/lecturer_main_page.dart](lib/pages/main/lecturer_main_page.dart)
- **Admins**: [lib/pages/main/admin/admin_main_page.dart](lib/pages/main/admin/admin_main_page.dart)

---

## 4. Job Posting System

### **4.1 Job Model**

**Location:** [django_backend/apps/jobs/models.py](django_backend/apps/jobs/models.py)

```python
class Job(models.Model):
    class Status(models.TextChoices):
        OPEN = "open"
        CLOSED = "closed"
    
    # Job details
    title = CharField(max_length=200)
    company = CharField(max_length=200)
    location = CharField(max_length=200)
    category = CharField(max_length=80)
    description = TextField()
    requirements = TextField()
    salary_min = DecimalField(null=True)
    salary_max = DecimalField(null=True)
    employment_type = CharField()  # Full-time, Part-time, Internship, etc.
    image_url = URLField()
    
    # Ownership & Deletion
    posted_by = ForeignKey(UserProfile)  # recruiter/lecturer/admin
    status = CharField(choices=Status.choices, default=Status.OPEN)
    is_deleted = BooleanField(default=False)
    deleted_at = DateTimeField(null=True)
    deleted_by = ForeignKey(UserProfile, related_name="deleted_jobs")
    
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

**Related Model - SavedJob:**
```python
class SavedJob(models.Model):
    user = ForeignKey(UserProfile)
    job = ForeignKey(Job)
    saved_at = DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ("user", "job")
```

### **4.2 Flutter AppJob Class**

[lib/services/jobs_service.dart](lib/services/jobs_service.dart):

```dart
class AppJob {
  final int id;
  final String title;
  final String company;
  final String location;
  final String category;
  final String description;
  final String requirements;
  final String imageUrl;
  final String employmentType;
  final String status;  // "open" or "closed"
  final String postedByName;
  final String postedByUid;
  final String postedByRole;  // recruiter/lecturer/admin
  final DateTime? createdAt;
}
```

### **4.3 Job Posting Permissions**

[django_backend/apps/jobs/views.py](django_backend/apps/jobs/views.py) - JobListCreateView:

```python
def perform_create(self, serializer):
    uid = getattr(self.request, "firebase_user", {}).get("uid")
    profile = UserProfile.objects.get_or_create(firebase_uid=uid)
    
    # Only recruiters, lecturers, and admins can post
    if profile.role not in {
        UserProfile.Role.RECRUITER,
        UserProfile.Role.LECTURER,
        UserProfile.Role.ADMIN,
    }:
        raise PermissionDenied(
            "Only recruiters, lecturers, and admins can post jobs."
        )
    
    serializer.save(posted_by=profile)
```

### **4.4 Job Query Filters**

[django_backend/apps/jobs/views.py](django_backend/apps/jobs/views.py) - JobListCreateView.get_queryset():

**Query Parameters:**
- `search` - Full-text search (title, description, company, requirements)
- `category` - Exact category match
- `status` - "open" or "closed"
- `location` - Contains location
- `employment_type` - Full-time, Part-time, etc.
- `posted_by_role` - Filter by recruiter/lecturer/admin
- `remote` - "true" to filter for remote jobs

**Role-Based Default Filtering:**
```python
# Students see only OPEN jobs by default
if current_profile.role == UserProfile.Role.STUDENT and not status:
    queryset = queryset.filter(status=Job.Status.OPEN)
```

### **4.5 Job Lifecycle**

**API Endpoints:** [django_backend/API_ENDPOINTS.txt](django_backend/API_ENDPOINTS.txt)

```
JOBS
GET    /api/jobs/                  # List all jobs (with filters)
POST   /api/jobs/                  # Create job (recruiter/lecturer/admin only)
GET    /api/jobs/mine/             # Get your posted jobs
GET    /api/jobs/<id>/             # Get job details
PATCH  /api/jobs/<id>/             # Update job (owner or admin only)
DELETE /api/jobs/<id>/             # Delete/soft-delete job (owner or admin only)
```

**Soft Delete Implementation:**
- `is_deleted` flag marks job as deleted (not permanent)
- `deleted_at` timestamp when soft-deleted
- `deleted_by` which admin/user deleted it
- Undo window: 1 minute (line 118 in jobs/views.py)

---

## 5. Job Application System

### **5.1 Application Model**

**Location:** [django_backend/apps/applications/models.py](django_backend/apps/applications/models.py)

```python
class Application(models.Model):
    class Status(models.TextChoices):
        APPLIED = "applied"
        REVIEWED = "reviewed"
        SHORTLISTED = "shortlisted"
        REJECTED = "rejected"
        HIRED = "hired"
    
    job = ForeignKey(Job, on_delete=models.CASCADE)
    applicant = ForeignKey(UserProfile)
    cover_letter = TextField()
    resume_url = URLField()
    status = CharField(choices=Status.choices, default=Status.APPLIED)
    
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ("job", "applicant")  # One app per job per person
```

### **5.2 Flutter JobApplication Class**

[lib/services/applications_service.dart](lib/services/applications_service.dart):

```dart
class JobApplication {
  final int id;
  final int jobId;
  final String jobTitle;
  final String applicantUid;
  final String applicantName;
  final String applicantProgram;
  final String applicantEmail;
  final String coverLetter;
  final String resumeUrl;
  final String status;  // applied|reviewed|shortlisted|rejected|hired
  final DateTime? createdAt;
}

class JobApplicationStats {
  final int jobId;
  final String jobTitle;
  final int totalApplicants;
  final int newApplications;
  final int reviewed;
  final int shortlisted;
  final int rejected;
  final int hired;
}
```

### **5.3 Application Workflow**

**API Endpoints:**
```
APPLICATIONS
GET    /api/applications/              # List apps (your role)
POST   /api/applications/              # Apply to job (student only)
GET    /api/applications/<id>/         # Get application details
PATCH  /api/applications/<id>/         # Update status (poster only) or withdraw
DELETE /api/applications/<id>/         # Delete/withdraw application
GET    /api/applications/job/<job_id>/ # Get all apps for a job (poster only)
```

**Application Creation Validations:** [django_backend/apps/applications/views.py](django_backend/apps/applications/views.py)

```python
def perform_create(self, serializer):
    uid = getattr(self.request, "firebase_user", {}).get("uid")
    profile = UserProfile.objects.get_or_create(firebase_uid=uid)
    
    job = serializer.validated_data["job"]
    
    # Validation checks:
    if job.status != Job.Status.OPEN:
        raise ValidationError("Cannot apply to a closed job.")
    
    if job.posted_by.firebase_uid == uid:
        raise ValidationError("You cannot apply to your own job post.")
    
    if Application.objects.filter(job=job, applicant=profile).exists():
        raise ValidationError("You have already applied to this job.")
    
    serializer.save(applicant=profile)
```

**Status Update Permissions:**
```python
def perform_update(self, serializer):
    application = self.get_object()
    is_owner = application.applicant.firebase_uid == uid
    is_job_owner = application.job.posted_by.firebase_uid == uid
    
    if not (is_owner or is_job_owner):
        raise PermissionDenied("Not allowed to update.")
    
    # Only job owner (recruiter) can change status
    if is_owner and "status" in serializer.validated_data:
        raise PermissionDenied("Applicants cannot change status.")
```

**Application Statistics View:**
```
GET /api/applications/job/<job_id>/
```
Returns breakdown of application statuses (total, new, reviewed, shortlisted, rejected, hired).

---

## 6. File Storage & Media Management

### **6.1 Cloudinary Integration**

**Location:** [lib/services/cloudinary_upload_service.dart](lib/services/cloudinary_upload_service.dart)

**Configuration:**
```dart
static Future<String> uploadFile({
  required String filePath,
  String resourceType = 'auto',
  String? folder,
})
```

Uses environment variables:
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_UPLOAD_PRESET`

**Usage:**
- Image uploads: Profile pictures, job images
- Document uploads: Resumes, portfolio files

**Typical Flow:**
1. User picks file from device
2. Call `CloudinaryUploadService.uploadFile()`
3. Get back secure URL (https://res.cloudinary.com/...)
4. Store URL in database (image_url, resume_url, portfolio_url)

---

## 7. API Client & Request/Response Pattern

### **7.1 ApiClient Singleton**

[lib/services/api_client.dart](lib/services/api_client.dart)

```dart
class ApiClient {
  static const String _defaultBaseUrl =
      'https://campus-job-board-project.onrender.com';
  
  Future<dynamic> get(String path, {bool auth = true}) async
  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async
  Future<dynamic> patch(String path, Map<String, dynamic> body, {bool auth = true}) async
  Future<void> delete(String path, {bool auth = true}) async
}
```

**Key Features:**
- Automatically attaches Firebase ID token to all authenticated requests
- Handles 401/403 with automatic token refresh
- Centralized error handling
- Base URL configurable via .env or --dart-define

**Usage Pattern:**
```dart
final data = await ApiClient.instance.get('/api/users/me/');
final profile = UserProfile.fromJson(data);

await ApiClient.instance.patch('/api/users/me/', {
  'full_name': 'John Doe',
  'college': 'Engineering',
});
```

### **7.2 Error Handling**

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
}

// Typical 2xx response
Future<dynamic> _handleResponse(http.Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException(response.statusCode, 'API Error');
  }
  return jsonDecode(response.body);
}
```

---

## 8. Backend Architecture

### **8.1 Django Project Structure**

```
django_backend/
├── config/                          # Main project settings
│   ├── settings.py                 # Django configuration
│   ├── urls.py                     # URL routing
│   ├── wsgi.py                     # WSGI application
│   └── middleware.py               # Firebase auth middleware
│
├── apps/
│   ├── common/                     # Health checks, stats
│   │   ├── views.py
│   │   └── urls.py
│   │
│   ├── users/                      # User management
│   │   ├── models.py              # UserProfile model
│   │   ├── views.py               # MeView, UserOnboardingView
│   │   ├── serializers.py         # UserProfileSerializer
│   │   ├── permissions.py         # Custom permissions
│   │   ├── urls.py                # /api/users/ routes
│   │   └── admin.py               # Django admin
│   │
│   ├── jobs/                       # Job posting
│   │   ├── models.py              # Job, SavedJob models
│   │   ├── views.py               # JobListCreateView, JobDetailView
│   │   ├── serializers.py         # JobSerializer
│   │   ├── urls.py                # /api/jobs/ routes
│   │   └── admin.py
│   │
│   └── applications/               # Job applications
│       ├── models.py              # Application model
│       ├── views.py               # ApplicationListCreateView
│       ├── serializers.py         # ApplicationSerializer
│       ├── urls.py                # /api/applications/ routes
│       └── admin.py
│
├── manage.py
└── requirements.txt
```

### **8.2 Dependencies**

[django_backend/requirements.txt](django_backend/requirements.txt):

```
Django==5.1.7
djangorestframework==3.15.2
django-cors-headers==4.7.0
dj-database-url==2.3.0
python-dotenv==1.0.1
firebase-admin==6.7.0      # Firebase token verification
gunicorn==23.0.0           # Production WSGI server
mysqlclient==2.2.4         # MySQL driver
psycopg2-binary==2.9.10    # PostgreSQL driver
Pillow==11.1.0             # Image processing
whitenoise==6.9.0          # Static file serving
```

### **8.3 Firebase Admin Integration**

**Location:** `config/middleware.py`

```python
import firebase_admin
from firebase_admin import credentials, auth

firebase_admin.initialize_app()

class FirebaseAuthMiddleware:
    def __call__(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        
        if auth_header.startswith('Bearer '):
            token = auth_header[7:]
            try:
                decoded_token = auth.verify_id_token(token)
                request.firebase_user = decoded_token
            except Exception:
                raise PermissionDenied("Invalid Firebase token")
```

---

## 9. Notifications System

### **9.1 Firebase Cloud Messaging (FCM)**

**Main Setup:** [lib/main.dart](lib/main.dart)

```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Local notifications
const AndroidInitializationSettings initializationSettingsAndroid = ...;
final InitializationSettings initializationSettings = ...;
```

**Database:**
- FCM tokens stored in `UserProfile.fcm_token`
- Notifications enabled/disabled via `UserProfile.notifications_enabled`
- Notification history stored in Hive box: `'notifications'`

---

## 10. Deployment Architecture

### **10.1 Render Deployment**

[render.yaml](render.yaml) and [RENDER_SETUP.md](RENDER_SETUP.md):

**Service:** `campus-job-board-api`

**Build Command:**
```bash
pip install -r requirements.txt && python manage.py collectstatic --noinput
```

**Start Command:**
```bash
python manage.py bootstrap_deploy && gunicorn config.wsgi:application
```

**Database:** PostgreSQL via Supabase
```
Host: aws-1-eu-west-1.pooler.supabase.com
Port: 6543 (connection pooler)
Database: postgres
SSL: require
```

**Environment Variables (Render Dashboard):**
```env
# Django Config
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=campus-job-board-project.onrender.com
DJANGO_CSRF_TRUSTED_ORIGINS=https://campus-job-board-project.onrender.com
DJANGO_SECRET_KEY=<auto-generated>

# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=postgres
DB_USER=postgres.<project-ref>
DB_PASSWORD=<your-password>
DB_HOST=aws-1-eu-west-1.pooler.supabase.com
DB_PORT=6543
DB_SSLMODE=require

# Firebase
FIREBASE_CREDENTIALS_JSON={...service account JSON...}

# Superuser (created on first deploy)
DJANGO_SUPERUSER_USERNAME=herman
DJANGO_SUPERUSER_PASSWORD=12345herman
DJANGO_SUPERUSER_EMAIL=herman@example.com
```

### **10.2 URL Routing**

**Django URL Configuration:**
```python
# Main urls.py
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/common/', include('apps.common.urls')),
    path('api/users/', include('apps.users.urls')),
    path('api/jobs/', include('apps.jobs.urls')),
    path('api/applications/', include('apps.applications.urls')),
]
```

### **10.3 Bootstrap/Migration Command**

```bash
python manage.py bootstrap_deploy
```

This custom command:
- Runs migrations
- Creates superuser (if env vars set)
- Initializes common data
- Runs once per deployment

---

## 11. API Endpoints Summary

**Base URL:** `https://campus-job-board-project.onrender.com`

**Authentication:** All endpoints require Firebase ID token in Authorization header:
```
Authorization: Bearer <firebase-id-token>
```

### **Health & Stats**
```
GET /api/common/health/           # Health check
GET /api/common/stats/            # Platform statistics
```

### **User Profiles**
```
GET    /api/users/me/             # Get current user profile
PATCH  /api/users/me/             # Update current user profile
GET    /api/users/profiles/       # List all profiles (admin-only)
POST   /api/users/profiles/       # Create profile (admin-only)
GET    /api/users/profiles/<id>/  # Get profile by ID (admin-only)
PATCH  /api/users/profiles/<id>/  # Update profile (admin-only)
DELETE /api/users/profiles/<id>/  # Delete profile (admin-only)
```

### **Jobs**
```
GET    /api/jobs/                 # List jobs (with filters)
POST   /api/jobs/                 # Create job
GET    /api/jobs/mine/            # Get your posted jobs
GET    /api/jobs/<id>/            # Get job details
PATCH  /api/jobs/<id>/            # Update job
DELETE /api/jobs/<id>/            # Soft-delete job
```

**Query Parameters for GET /api/jobs/:**
- `search` - Full text search
- `category` - Filter by category
- `status` - Filter by status (open/closed)
- `location` - Filter by location
- `employment_type` - Full-time, Part-time, Internship, etc.
- `posted_by_role` - Filter by recruiter/lecturer/admin
- `remote` - Filter for remote jobs (true/false)

### **Applications**
```
GET    /api/applications/         # List applications
POST   /api/applications/         # Apply to job
GET    /api/applications/<id>/    # Get application details
PATCH  /api/applications/<id>/    # Update application status
DELETE /api/applications/<id>/    # Delete application
GET    /api/applications/job/<job_id>/  # Get apps for a job (owner only)
```

**Query Parameters for GET /api/applications/:**
- `role` - "applicant" (your applications) or "recruiter"/"lecturer"/"admin" (apps to your jobs)
- `status` - Filter by status (applied, reviewed, shortlisted, rejected, hired)
- `job` - Filter by job ID

---

## 12. Data Flow Examples

### **Example 1: User Registration and Profile Setup**

```
1. User enters email, password, name → Sign Up Page
2. FirebaseAuth.createUserWithEmailAndPassword()
3. AuthService.register() calls ApiClient.post('/api/users/me/')
4. Django creates UserProfile with firebase_uid
5. Flutter receives UserProfile with role (still empty)
6. App redirects to Onboarding (RoleSelectionPage)
7. User selects role + fills role-specific fields
8. ApiClient.post('/api/users/onboarding/', roleData)
9. Django updates UserProfile with role + specific fields
10. Sends email to HOD if role == LECTURER
11. Frontend redirects to role-specific dashboard
```

### **Example 2: Recruiter Posts a Job**

```
1. Recruiter fills job form (title, company, location, etc.)
2. Uploads job image via CloudinaryUploadService
3. Gets secure_url back
4. Submits via ApiClient.post('/api/jobs/', jobData)
5. Django JobListCreateView.perform_create():
   - Verifies user.role in {recruiter, lecturer, admin}
   - Creates Job with posted_by=current_user
   - Returns JobSerializer data
6. Job appears in search results for all students
```

### **Example 3: Student Applies to Job**

```
1. Student views job details
2. Fills cover letter, optionally provides resume_url
3. Submits via ApiClient.post('/api/applications/', appData)
4. Django ApplicationListCreateView.perform_create():
   - Validates job.status == OPEN
   - Checks no duplicate application exists
   - Checks applicant != job.posted_by
   - Creates Application with applicant=current_user
5. Recruiter sees application in dashboard
6. Recruiter updates status: reviewed → shortlisted → hired
   - ApiClient.patch('/api/applications/<id>/', {status: 'hired'})
7. Student can see status updates in their applications list
```

### **Example 4: Job Soft Delete with Undo**

```
1. Recruiter deletes job
2. ApiClient.delete('/api/jobs/<id>/')
3. Django JobDetailView.destroy():
   - Sets is_deleted = True
   - Sets deleted_at = now()
   - Sets deleted_by = current_user
   - Returns undo_expires_at = now + 1 minute
4. Job hidden from search results
5. If user clicks UNDO within 1 minute:
   - ApiClient.post('/api/jobs/<id>/restore/')
   - Sets is_deleted = False
6. Job reappears in results
```

---

## 13. Development Setup Checklist

### **Environment Variables (.env)**

**Frontend (.env in root):**
```env
BACKEND_URL=https://campus-job-board-project.onrender.com
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-preset
```

**Backend (set in Render dashboard):**
```env
# See RENDER_SETUP.md for complete list
DB_ENGINE=django.db.backends.postgresql
DB_NAME=postgres
DB_USER=postgres.<project-ref>
DB_PASSWORD=...
DB_HOST=aws-1-eu-west-1.pooler.supabase.com
FIREBASE_CREDENTIALS_JSON={...}
```

### **Local Development**

```bash
# Backend
cd django_backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

# Frontend
flutter pub get
flutter run
```

### **Build for Release**

```bash
# Android Release APK
flutter build apk --release

# Check available tasks in VS Code
# - shell: build-release-apk
# - shell: build-debug-apk
```

---

## 14. Key Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **Firebase Auth + Django Sync** | Decouples frontend auth from backend; allows role-based backend logic |
| **PostgreSQL via Supabase** | Managed DB with auto-scaling, connection pooling, easy backups |
| **Cloudinary for Files** | Avoids server storage limits, provides CDN, image transformation |
| **Soft Deletes (is_deleted flag)** | Allows undo, maintains referential integrity, audit trail |
| **Status/Role-Based Querying** | Students see open jobs only, recruiters see their own jobs, admins see all |
| **Unique Application Constraint** | One application per user per job, prevents duplicate submissions |
| **FCM for Notifications** | Native support on Flutter, reliable delivery, no polling needed |

---

## 15. Common Integration Points

1. **New User Created** → Firebase Auth → Django auto-creates UserProfile
2. **User Updates Profile** → ApiClient.patch() → Cached in AuthService
3. **Job Posted** → Django validates role → Returns JobSerializer → Flutter AppJob
4. **Application Submitted** → Django validates constraints → Returns Application
5. **Status Changed** → Only job owner can update → Frontend shows updates
6. **File Uploaded** → Cloudinary → Returns secure_url → Store in database field

---

**Last Updated:** March 21, 2026
**Architecture Version:** 1.0

