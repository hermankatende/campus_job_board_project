from rest_framework.permissions import BasePermission

from apps.users.models import UserProfile


class IsAdminFromProfile(BasePermission):
    def has_permission(self, request, view):
        uid = getattr(request, "firebase_user", {}).get("uid")
        if not uid:
            return False
        return UserProfile.objects.filter(firebase_uid=uid, role=UserProfile.Role.ADMIN).exists()
