from rest_framework import serializers

from apps.applications.models import Application


class ApplicationSerializer(serializers.ModelSerializer):
    job_id = serializers.IntegerField(source="job.id", read_only=True)
    applicant_name = serializers.CharField(source="applicant.full_name", read_only=True)
    applicant_program = serializers.CharField(source="applicant.program", read_only=True)
    applicant_uid = serializers.CharField(source="applicant.firebase_uid", read_only=True)
    applicant_email = serializers.CharField(source="applicant.email", read_only=True)
    job_title = serializers.CharField(source="job.title", read_only=True)

    class Meta:
        model = Application
        fields = [
            "id",
            "job",
            "job_id",
            "job_title",
            "applicant",
            "applicant_uid",
            "applicant_name",
            "applicant_program",
            "applicant_email",
            "cover_letter",
            "resume_url",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "applicant",
            "job_title",
            "applicant_name",
            "applicant_email",
            "created_at",
            "updated_at",
        ]
