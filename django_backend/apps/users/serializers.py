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
            "about_me",
            "work_experience",
            "education",
            "skills",
            "hobbies_interests",
            "portfolio_url",
            "job_preference",
            "gender",
            "age_range",
            "image_url",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "firebase_uid", "created_at", "updated_at"]
