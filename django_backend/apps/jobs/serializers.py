from rest_framework import serializers

from apps.jobs.models import Job


class JobSerializer(serializers.ModelSerializer):
    posted_by_id = serializers.IntegerField(source="posted_by.id", read_only=True)
    posted_by_name = serializers.CharField(source="posted_by.full_name", read_only=True)
    posted_by_uid = serializers.CharField(source="posted_by.firebase_uid", read_only=True)
    posted_by_role = serializers.CharField(source="posted_by.role", read_only=True)

    class Meta:
        model = Job
        fields = [
            "id",
            "title",
            "company",
            "location",
            "category",
            "description",
            "requirements",
            "salary_min",
            "salary_max",
            "employment_type",
            "image_url",
            "posted_by_id",
            "posted_by_name",
            "posted_by_uid",
            "posted_by_role",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "posted_by_id", "posted_by_name", "created_at", "updated_at"]
