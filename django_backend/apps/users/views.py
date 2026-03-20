from rest_framework import generics, permissions
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
            profile.save(update_fields=["email", "updated_at"])

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
        return Response(UserProfileSerializer(profile).data)


class UserProfileListCreateView(generics.ListCreateAPIView):
    queryset = UserProfile.objects.all().order_by("-created_at")
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminFromProfile]


class UserProfileDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminFromProfile]
