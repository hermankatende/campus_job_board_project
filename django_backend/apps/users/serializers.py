from rest_framework import serializers

from apps.users.models import UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            "id",
            "firebase_uid",
            "email",
            "full_name",
            "role",
            "phone",
            "image_url",
            "gender",
            "age_range",
            # Shared
            "about_me",
            "skills",
            "portfolio_url",
            # Student
            "college",
            "program",
            "student_number",
            "work_experience",
            "education",
            "hobbies_interests",
            "job_preference",
            "resume_url",
            "notifications_enabled",
            "fcm_token",
            # Recruiter
            "company_name",
            "company_description",
            "company_website",
            "company_location",
            # Lecturer
            "department",
            "is_verified",
            # Admin-controlled
            "is_suspended",
            "last_login_at",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "firebase_uid", "is_verified", "is_suspended", "created_at", "updated_at"]
