from django.db import models

from apps.users.models import UserProfile


class Job(models.Model):
    class Status(models.TextChoices):
        OPEN = "open", "Open"
        CLOSED = "closed", "Closed"

    title = models.CharField(max_length=200)
    company = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    category = models.CharField(max_length=80)
    description = models.TextField()
    requirements = models.TextField(blank=True)
    salary_min = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    salary_max = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    employment_type = models.CharField(max_length=50, blank=True)
    image_url = models.URLField(blank=True)
    posted_by = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="jobs")
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.ForeignKey(
        UserProfile,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="deleted_jobs",
    )
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.OPEN)
    # Recruiter contact info (filled by a lecturer posting on behalf of a recruiter)
    recruiter_contact_name = models.CharField(max_length=200, blank=True)
    recruiter_contact_email = models.EmailField(blank=True)
    recruiter_contact_phone = models.CharField(max_length=50, blank=True)
    recruiter_contact_company = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.title} - {self.company}"


class SavedJob(models.Model):
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="saved_jobs")
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name="saved_by")
    saved_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "job")
        ordering = ["-saved_at"]

    def __str__(self) -> str:
        return f"{self.user} saved {self.job}"
