from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.models import UserProfile
from apps.users.permissions import IsAdminFromProfile
from apps.users.serializers import UserOnboardingSerializer, UserProfileSerializer


class MeView(APIView):
    def get(self, request):
        firebase_user = getattr(request, "firebase_user", {})
        uid = firebase_user.get("uid")
        email = firebase_user.get("email")

        profile, _ = UserProfile.objects.get_or_create(
            firebase_uid=uid,
            defaults={"email": email or ""},
        )

        if email and profile.email != email:
            profile.email = email

        profile.last_login_at = timezone.now()
        profile.save(update_fields=["email", "last_login_at", "updated_at"])

        return Response(UserProfileSerializer(profile).data)

    def patch(self, request):
        firebase_user = getattr(request, "firebase_user", {})
        uid = firebase_user.get("uid")

        profile = UserProfile.objects.get(firebase_uid=uid)
        serializer = UserProfileSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class UserOnboardingView(APIView):
    def post(self, request):
        firebase_user = getattr(request, "firebase_user", {})
        uid = firebase_user.get("uid")
        email = firebase_user.get("email")
        firebase_name = firebase_user.get("name", "")

        profile, _ = UserProfile.objects.get_or_create(
            firebase_uid=uid,
            defaults={"email": email or "", "full_name": firebase_name or ""},
        )

        serializer = UserOnboardingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        payload = serializer.validated_data
        for field, value in payload.items():
            setattr(profile, field, value)

        if email and profile.email != email:
            profile.email = email

        profile.save()

        if profile.role == UserProfile.Role.LECTURER:
            self._send_lecturer_verification_email(profile)

        return Response(UserProfileSerializer(profile).data)

    def _send_lecturer_verification_email(self, profile: UserProfile) -> None:
        hod_email = getattr(settings, "LECTURER_HOD_EMAIL", "").strip()
        if not hod_email:
            return

        subject = "Lecturer Verification Request - Campus Job Board"
        message = (
            "A lecturer has registered on Campus Job Board and requires verification.\n\n"
            f"Name: {profile.full_name}\n"
            f"Email: {profile.email}\n"
            f"Department: {profile.department}\n"
            f"Phone: {profile.phone}\n\n"
            "Please review and verify this lecturer from the admin dashboard."
        )

        try:
            send_mail(
                subject=subject,
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[hod_email],
                fail_silently=True,
            )
        except Exception:
            # Do not block onboarding if email delivery fails.
            pass


class UserProfileListCreateView(generics.ListCreateAPIView):
    queryset = UserProfile.objects.all().order_by("-created_at")
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminFromProfile]


class UserProfileDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminFromProfile]


class UserManagementListView(APIView):
    permission_classes = [IsAdminFromProfile]

    def get(self, request):
        search = request.query_params.get("search", "").strip()
        role = request.query_params.get("role", "").strip().lower()
        status = request.query_params.get("status", "").strip().lower()

        queryset = UserProfile.objects.all().order_by("-updated_at")
        if search:
            queryset = queryset.filter(full_name__icontains=search) | queryset.filter(email__icontains=search)
        if role:
            queryset = queryset.filter(role=role)

        online_cutoff = timezone.now() - timezone.timedelta(minutes=15)
        if status == "online":
            queryset = queryset.filter(last_login_at__gte=online_cutoff)
        elif status == "offline":
            queryset = queryset.exclude(last_login_at__gte=online_cutoff)

        data = []
        for profile in queryset:
            is_online = bool(profile.last_login_at and profile.last_login_at >= online_cutoff)
            data.append(
                {
                    "id": profile.id,
                    "name": profile.full_name,
                    "role": profile.role,
                    "email": profile.email,
                    "last_login": profile.last_login_at,
                    "status": "online" if is_online else "offline",
                    "is_verified": profile.is_verified,
                    "is_suspended": profile.is_suspended,
                }
            )

        return Response(data)


class UserRoleUpdateView(APIView):
    permission_classes = [IsAdminFromProfile]

    def patch(self, request, pk):
        profile = UserProfile.objects.filter(pk=pk).first()
        if not profile:
            raise ValidationError("User not found.")

        new_role = request.data.get("role", "").strip().lower()
        allowed_roles = {
            UserProfile.Role.STUDENT,
            UserProfile.Role.RECRUITER,
            UserProfile.Role.LECTURER,
            UserProfile.Role.ADMIN,
        }
        if new_role not in allowed_roles:
            raise ValidationError("Invalid role.")

        profile.role = new_role
        profile.save(update_fields=["role", "updated_at"])
        return Response(UserProfileSerializer(profile).data)


class UserSuspendView(APIView):
    permission_classes = [IsAdminFromProfile]

    def patch(self, request, pk):
        profile = UserProfile.objects.filter(pk=pk).first()
        if not profile:
            raise ValidationError("User not found.")

        suspend = bool(request.data.get("suspend", True))
        profile.is_suspended = suspend
        profile.save(update_fields=["is_suspended", "updated_at"])
        return Response(UserProfileSerializer(profile).data)


class LecturerVerificationView(APIView):
    permission_classes = [IsAdminFromProfile]

    def patch(self, request, pk):
        profile = UserProfile.objects.filter(pk=pk).first()
        if not profile:
            raise ValidationError("User not found.")
        if profile.role != UserProfile.Role.LECTURER:
            raise ValidationError("Target user is not a lecturer.")

        verify = bool(request.data.get("verify", True))
        profile.is_verified = verify
        profile.save(update_fields=["is_verified", "updated_at"])
        return Response(UserProfileSerializer(profile).data)


class UserDeleteView(APIView):
    permission_classes = [IsAdminFromProfile]

    def delete(self, request, pk):
        admin_uid = getattr(request, "firebase_user", {}).get("uid")
        target = UserProfile.objects.filter(pk=pk).first()
        if not target:
            raise ValidationError("User not found.")

        if target.firebase_uid == admin_uid:
            raise PermissionDenied("You cannot delete your own admin profile.")

        target.delete()
        return Response({"status": "deleted"})
