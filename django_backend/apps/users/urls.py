from django.urls import path

from apps.users.views import MeView, UserOnboardingView, UserProfileDetailView, UserProfileListCreateView

urlpatterns = [
    path("me/", MeView.as_view(), name="users-me"),
    path("onboarding/", UserOnboardingView.as_view(), name="users-onboarding"),
    path("profiles/", UserProfileListCreateView.as_view(), name="user-profile-list"),
    path("profiles/<int:pk>/", UserProfileDetailView.as_view(), name="user-profile-detail"),
]
