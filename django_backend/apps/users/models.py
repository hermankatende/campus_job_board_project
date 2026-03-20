from django.db import models


class UserProfile(models.Model):
    class Role(models.TextChoices):
        STUDENT = "student", "Student"
        EMPLOYER = "employer", "Employer"
        ADMIN = "admin", "Admin"

    firebase_uid = models.CharField(max_length=128, unique=True)
    email = models.EmailField(blank=True, null=True)
    full_name = models.CharField(max_length=180, blank=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)

    about_me = models.TextField(blank=True)
    work_experience = models.TextField(blank=True)
    education = models.TextField(blank=True)
    skills = models.TextField(blank=True)
    hobbies_interests = models.TextField(blank=True)
    portfolio_url = models.URLField(blank=True)
    job_preference = models.CharField(max_length=255, blank=True)
    gender = models.CharField(max_length=20, blank=True)
    age_range = models.CharField(max_length=20, blank=True)
    image_url = models.URLField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"{self.full_name or self.email or self.firebase_uid}"
