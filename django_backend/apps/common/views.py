from django.db.models import Count
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.applications.models import Application
from apps.jobs.models import Job
from apps.users.models import UserProfile


class HealthCheckView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({"status": "ok", "service": "django-backend"})


class DashboardStatsView(APIView):
    def get(self, request):
        top_categories = (
            Job.objects.values("category")
            .annotate(total=Count("id"))
            .order_by("-total")[:5]
        )

        return Response(
            {
                "users": UserProfile.objects.count(),
                "jobs": Job.objects.count(),
                "open_jobs": Job.objects.filter(status=Job.Status.OPEN).count(),
                "applications": Application.objects.count(),
                "top_categories": list(top_categories),
            }
        )
