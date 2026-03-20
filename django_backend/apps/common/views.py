import json

from django.db.models import Count
from django.utils import timezone
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
        online_cutoff = timezone.now() - timezone.timedelta(minutes=15)

        top_categories = (
            Job.objects.values("category")
            .annotate(total=Count("id"))
            .order_by("-total")[:5]
        )

        return Response(
            {
                "users": UserProfile.objects.count(),
                "active_users": UserProfile.objects.filter(last_login_at__gte=online_cutoff).count(),
                "students": UserProfile.objects.filter(role=UserProfile.Role.STUDENT).count(),
                "recruiters": UserProfile.objects.filter(role=UserProfile.Role.RECRUITER).count(),
                "lecturers": UserProfile.objects.filter(role=UserProfile.Role.LECTURER).count(),
                "pending_lecturer_verifications": UserProfile.objects.filter(
                    role=UserProfile.Role.LECTURER, is_verified=False
                ).count(),
                "jobs": Job.objects.count(),
                "open_jobs": Job.objects.filter(status=Job.Status.OPEN).count(),
                "applications": Application.objects.count(),
                "top_categories": list(top_categories),
            }
        )


class SendNotificationView(APIView):
    """Proxy that sends an FCM push notification via firebase-admin."""

    def post(self, request):
        token = request.data.get("token", "").strip()
        title = request.data.get("title", "")
        body = request.data.get("body", "")

        if not token:
            return Response({"error": "token is required"}, status=400)

        try:
            import firebase_admin
            from firebase_admin import messaging

            # Ensure Firebase is initialised (reuses the auth module's logic)
            from apps.common.auth import FirebaseAuthentication
            FirebaseAuthentication._initialize_firebase_if_needed()

            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                token=token,
            )
            messaging.send(message)
            return Response({"status": "sent"})
        except Exception as exc:
            return Response({"error": str(exc)}, status=500)
