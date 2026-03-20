from django.urls import path

from apps.users.views import MeView, UserProfileDetailView, UserProfileListCreateView

urlpatterns = [
    path("me/", MeView.as_view(), name="users-me"),
    path("profiles/", UserProfileListCreateView.as_view(), name="user-profile-list"),
    path("profiles/<int:pk>/", UserProfileDetailView.as_view(), name="user-profile-detail"),
]
