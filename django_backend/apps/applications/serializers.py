from rest_framework import serializers

from apps.applications.models import Application


class ApplicationSerializer(serializers.ModelSerializer):
    job_id = serializers.IntegerField(source="job.id", read_only=True)
    applicant_name = serializers.SerializerMethodField()
    applicant_program = serializers.CharField(source="applicant.program", read_only=True)
    applicant_uid = serializers.CharField(source="applicant.firebase_uid", read_only=True)
    applicant_email = serializers.CharField(source="applicant.email", read_only=True)
    job_title = serializers.CharField(source="job.title", read_only=True)
    resume_url = serializers.SerializerMethodField()

    def get_applicant_name(self, obj):
        full_name = (obj.applicant.full_name or "").strip()
        if full_name:
            return full_name

        email = (obj.applicant.email or "").strip()
        if email:
            return email

        return obj.applicant.firebase_uid or "Unnamed Applicant"

    def get_resume_url(self, obj):
        application_resume = (obj.resume_url or "").strip()
        if application_resume:
            return application_resume

        return (obj.applicant.resume_url or "").strip()

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
