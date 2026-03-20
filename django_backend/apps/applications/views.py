from django.shortcuts import get_object_or_404
from rest_framework import generics
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated

from apps.applications.models import Application
from apps.applications.serializers import ApplicationSerializer
from apps.jobs.models import Job
from apps.users.models import UserProfile


class ApplicationListCreateView(generics.ListCreateAPIView):
    serializer_class = ApplicationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        role = self.request.query_params.get("role", "applicant")

        if role == "employer":
            return Application.objects.select_related("job", "applicant", "job__posted_by").filter(
                job__posted_by__firebase_uid=uid
            )

        return Application.objects.select_related("job", "applicant").filter(applicant__firebase_uid=uid)

    def perform_create(self, serializer):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        email = getattr(self.request, "firebase_user", {}).get("email", "")
        profile, _ = UserProfile.objects.get_or_create(firebase_uid=uid, defaults={"email": email})

        job = serializer.validated_data["job"]
        if job.status != Job.Status.OPEN:
            raise ValidationError("Cannot apply to a closed job.")

        if Application.objects.filter(job=job, applicant=profile).exists():
            raise ValidationError("You have already applied to this job.")

        serializer.save(applicant=profile)


class ApplicationDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Application.objects.select_related("job", "applicant", "job__posted_by").all()
    serializer_class = ApplicationSerializer
    permission_classes = [IsAuthenticated]

    def perform_update(self, serializer):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        application = self.get_object()

        is_owner = application.applicant.firebase_uid == uid
        is_job_owner = application.job.posted_by.firebase_uid == uid

        if not (is_owner or is_job_owner):
            raise PermissionDenied("Not allowed to update this application.")

        if is_owner and "status" in serializer.validated_data:
            raise PermissionDenied("Applicants cannot change application status.")

        serializer.save()

    def perform_destroy(self, instance):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        is_owner = instance.applicant.firebase_uid == uid
        is_job_owner = instance.job.posted_by.firebase_uid == uid

        if not (is_owner or is_job_owner):
            raise PermissionDenied("Not allowed to delete this application.")

        instance.delete()


class JobApplicationListView(generics.ListAPIView):
    serializer_class = ApplicationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        job = get_object_or_404(Job, pk=self.kwargs["job_id"])
        if job.posted_by.firebase_uid != uid:
            raise PermissionDenied("Only the job owner can view applications for this job.")
        return Application.objects.select_related("job", "applicant").filter(job=job)
