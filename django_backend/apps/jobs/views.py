from django.db.models import Q
from django.utils import timezone
from rest_framework import generics
from rest_framework import status
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.jobs.models import Job, SavedJob
from apps.jobs.serializers import JobSerializer, SavedJobSerializer
from apps.users.models import UserProfile


class JobListCreateView(generics.ListCreateAPIView):
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Job.objects.select_related("posted_by").filter(is_deleted=False)

        uid = getattr(self.request, "firebase_user", {}).get("uid")
        current_profile = UserProfile.objects.filter(firebase_uid=uid).first()

        search = self.request.query_params.get("search", "").strip()
        category = self.request.query_params.get("category", "").strip()
        status = self.request.query_params.get("status", "").strip()
        location = self.request.query_params.get("location", "").strip()
        employment_type = self.request.query_params.get("employment_type", "").strip()
        posted_by_role = self.request.query_params.get("posted_by_role", "").strip().lower()
        remote = self.request.query_params.get("remote", "").strip().lower()

        # Students should only see open jobs by default.
        if current_profile and current_profile.role == UserProfile.Role.STUDENT and not status:
            queryset = queryset.filter(status=Job.Status.OPEN)

        if search:
            queryset = queryset.filter(
                Q(title__icontains=search)
                | Q(description__icontains=search)
                | Q(company__icontains=search)
                | Q(requirements__icontains=search)
            )
        if category:
            queryset = queryset.filter(category__iexact=category)
        if status:
            queryset = queryset.filter(status__iexact=status)
        if location:
            queryset = queryset.filter(location__icontains=location)
        if employment_type:
            queryset = queryset.filter(employment_type__iexact=employment_type)
        if posted_by_role in {
            UserProfile.Role.RECRUITER,
            UserProfile.Role.LECTURER,
            UserProfile.Role.ADMIN,
        }:
            queryset = queryset.filter(posted_by__role=posted_by_role)
        if remote in {"1", "true", "yes"}:
            queryset = queryset.filter(
                Q(location__icontains="remote") | Q(employment_type__icontains="remote")
            )

        return queryset

    def perform_create(self, serializer):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        email = getattr(self.request, "firebase_user", {}).get("email", "")
        profile, _ = UserProfile.objects.get_or_create(firebase_uid=uid, defaults={"email": email})

        if profile.role not in {
            UserProfile.Role.RECRUITER,
            UserProfile.Role.LECTURER,
            UserProfile.Role.ADMIN,
        }:
            raise PermissionDenied("Only recruiters, lecturers, and admins can post jobs.")

        serializer.save(posted_by=profile)


class JobDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Job.objects.select_related("posted_by").filter(is_deleted=False)
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]

    def perform_update(self, serializer):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        profile = UserProfile.objects.filter(firebase_uid=uid).first()
        job = self.get_object()

        if not profile:
            raise PermissionDenied("Profile not found.")

        is_owner = job.posted_by_id == profile.id
        is_admin = profile.role == UserProfile.Role.ADMIN
        if not (is_owner or is_admin):
            raise PermissionDenied("You can only update your own job posts.")

        serializer.save()

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        profile = UserProfile.objects.filter(firebase_uid=uid).first()

        if not profile:
            raise PermissionDenied("Profile not found.")

        is_owner = instance.posted_by_id == profile.id
        is_admin = profile.role == UserProfile.Role.ADMIN
        if not (is_owner or is_admin):
            raise PermissionDenied("You can only delete your own job posts.")

        now = timezone.now()
        instance.is_deleted = True
        instance.deleted_at = now
        instance.deleted_by = profile
        instance.save(update_fields=["is_deleted", "deleted_at", "deleted_by", "updated_at"])

        return Response(
            {
                "status": "deleted",
                "job_id": instance.id,
                "undo_expires_at": (now + timezone.timedelta(minutes=1)).isoformat(),
            },
            status=status.HTTP_200_OK,
        )


class MyJobsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        uid = getattr(request, "firebase_user", {}).get("uid")
        jobs = Job.objects.select_related("posted_by").filter(
            posted_by__firebase_uid=uid,
            is_deleted=False,
        )
        serializer = JobSerializer(jobs, many=True)
        return Response(serializer.data)


class JobRestoreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        uid = getattr(request, "firebase_user", {}).get("uid")
        profile = UserProfile.objects.filter(firebase_uid=uid).first()
        if not profile:
            raise PermissionDenied("Profile not found.")

        job = Job.objects.select_related("posted_by").filter(pk=pk).first()
        if not job:
            return Response({"detail": "Job not found."}, status=status.HTTP_404_NOT_FOUND)

        is_owner = job.posted_by_id == profile.id
        is_admin = profile.role == UserProfile.Role.ADMIN
        if not (is_owner or is_admin):
            raise PermissionDenied("You can only restore your own job posts.")

        if not job.is_deleted or not job.deleted_at:
            return Response({"detail": "Job is not in deleted state."}, status=status.HTTP_400_BAD_REQUEST)

        if timezone.now() > job.deleted_at + timezone.timedelta(minutes=1):
            return Response({"detail": "Undo window has expired."}, status=status.HTTP_400_BAD_REQUEST)

        job.is_deleted = False
        job.deleted_at = None
        job.deleted_by = None
        job.save(update_fields=["is_deleted", "deleted_at", "deleted_by", "updated_at"])

        return Response(JobSerializer(job).data, status=status.HTTP_200_OK)


class SavedJobListView(APIView):
    """GET  /api/jobs/saved/   – list saved jobs for the authenticated user.
       POST /api/jobs/saved/   – save a job (body: {"job_id": <int>}).
    """
    permission_classes = [IsAuthenticated]

    def _get_profile(self, request):
        uid = getattr(request, "firebase_user", {}).get("uid")
        return UserProfile.objects.filter(firebase_uid=uid).first()

    def get(self, request):
        profile = self._get_profile(request)
        if not profile:
            return Response([], status=status.HTTP_200_OK)
        saved = SavedJob.objects.select_related("job", "job__posted_by").filter(user=profile)
        serializer = SavedJobSerializer(saved, many=True)
        return Response(serializer.data)

    def post(self, request):
        profile = self._get_profile(request)
        if not profile:
            raise PermissionDenied("Profile not found.")
        job_id = request.data.get("job_id")
        if not job_id:
            return Response({"detail": "job_id is required."}, status=status.HTTP_400_BAD_REQUEST)
        job = Job.objects.filter(pk=job_id, is_deleted=False).first()
        if not job:
            return Response({"detail": "Job not found."}, status=status.HTTP_404_NOT_FOUND)
        saved, created = SavedJob.objects.get_or_create(user=profile, job=job)
        serializer = SavedJobSerializer(saved)
        return Response(serializer.data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class SavedJobDeleteView(APIView):
    """DELETE /api/jobs/saved/<job_id>/   – unsave a job."""
    permission_classes = [IsAuthenticated]

    def delete(self, request, job_id):
        uid = getattr(request, "firebase_user", {}).get("uid")
        profile = UserProfile.objects.filter(firebase_uid=uid).first()
        if not profile:
            raise PermissionDenied("Profile not found.")
        deleted_count, _ = SavedJob.objects.filter(user=profile, job_id=job_id).delete()
        if deleted_count == 0:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)
