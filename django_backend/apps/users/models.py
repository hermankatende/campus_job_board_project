from django.db import models


class UserProfile(models.Model):
    class Role(models.TextChoices):
        STUDENT = "student", "Student"
        RECRUITER = "recruiter", "Recruiter"
        LECTURER = "lecturer", "Lecturer"
        ADMIN = "admin", "Admin"

    firebase_uid = models.CharField(max_length=128, unique=True)
    email = models.EmailField(blank=True, null=True)
    full_name = models.CharField(max_length=180, blank=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)
    phone = models.CharField(max_length=30, blank=True)
    image_url = models.URLField(blank=True)
    gender = models.CharField(max_length=20, blank=True)
    age_range = models.CharField(max_length=20, blank=True)

    # Shared profile fields
    about_me = models.TextField(blank=True)
    skills = models.TextField(blank=True)
    portfolio_url = models.URLField(blank=True)

    # Student-specific fields
    college = models.CharField(max_length=200, blank=True)
    program = models.CharField(max_length=200, blank=True)
    student_number = models.CharField(max_length=50, blank=True)
    work_experience = models.TextField(blank=True)
    education = models.TextField(blank=True)
    hobbies_interests = models.TextField(blank=True)
    job_preference = models.CharField(max_length=255, blank=True)
    resume_url = models.URLField(blank=True)
    notifications_enabled = models.BooleanField(default=True)
    fcm_token = models.TextField(blank=True)

    # Recruiter-specific fields
    company_name = models.CharField(max_length=200, blank=True)
    company_description = models.TextField(blank=True)
    company_website = models.URLField(blank=True)
    company_location = models.CharField(max_length=200, blank=True)

    # Lecturer-specific fields
    department = models.CharField(max_length=200, blank=True)
    is_verified = models.BooleanField(default=False)  # Verified by HOD / Admin
    is_suspended = models.BooleanField(default=False)
    last_login_at = models.DateTimeField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"{self.full_name or self.email or self.firebase_uid} [{self.role}]"
