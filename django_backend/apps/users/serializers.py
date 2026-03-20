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


class UserOnboardingSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=UserProfile.Role.choices)
    full_name = serializers.CharField(required=False, allow_blank=True, max_length=180)
    phone = serializers.CharField(required=False, allow_blank=True, max_length=30)

    # Student
    college = serializers.CharField(required=False, allow_blank=True, max_length=200)
    program = serializers.CharField(required=False, allow_blank=True, max_length=200)
    student_number = serializers.CharField(required=False, allow_blank=True, max_length=50)
    job_preference = serializers.CharField(required=False, allow_blank=True, max_length=255)

    # Recruiter
    company_name = serializers.CharField(required=False, allow_blank=True, max_length=200)
    company_description = serializers.CharField(required=False, allow_blank=True)
    company_website = serializers.URLField(required=False, allow_blank=True)
    company_location = serializers.CharField(required=False, allow_blank=True, max_length=200)

    # Lecturer
    department = serializers.CharField(required=False, allow_blank=True, max_length=200)

    def validate(self, attrs):
        role = attrs.get("role")

        # Users should not self-assign admin role via onboarding.
        if role == UserProfile.Role.ADMIN:
            raise serializers.ValidationError("Admin role cannot be self-assigned.")

        if role == UserProfile.Role.STUDENT:
            required_fields = ["college", "program", "student_number"]
            missing = [f for f in required_fields if not attrs.get(f)]
            if missing:
                raise serializers.ValidationError(
                    {"detail": f"Student onboarding missing fields: {', '.join(missing)}"}
                )

        if role == UserProfile.Role.RECRUITER and not attrs.get("company_name"):
            raise serializers.ValidationError(
                {"detail": "Recruiter onboarding requires company_name."}
            )

        if role == UserProfile.Role.LECTURER and not attrs.get("department"):
            raise serializers.ValidationError(
                {"detail": "Lecturer onboarding requires department."}
            )

        return attrs
