from rest_framework import serializers

from apps.applications.models import Application


class ApplicationSerializer(serializers.ModelSerializer):
    job_id = serializers.IntegerField(source="job.id", read_only=True)
    applicant_name = serializers.SerializerMethodField()
    applicant_program = serializers.CharField(source="applicant.program", read_only=True)
    applicant_uid = serializers.CharField(source="applicant.firebase_uid", read_only=True)
    applicant_email = serializers.CharField(source="applicant.email", read_only=True)
    job_title = serializers.CharField(source="job.title", read_only=True)
    resume_url = serializers.URLField(required=False, allow_blank=True)

    def get_applicant_name(self, obj):
        full_name = (obj.applicant.full_name or "").strip()
        if full_name:
            return full_name

        email = (obj.applicant.email or "").strip()
        if email:
            return email

        return obj.applicant.firebase_uid or "Unnamed Applicant"

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if not (data.get("resume_url") or "").strip():
            data["resume_url"] = (instance.applicant.resume_url or "").strip()
        return data

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
