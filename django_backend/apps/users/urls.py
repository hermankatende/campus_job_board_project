from django.urls import path

from apps.users.views import (
    LecturerVerificationView,
    MeView,
    StudentSearchView,
    UserDeleteView,
    UserManagementListView,
    UserOnboardingView,
    UserProfileDetailView,
    UserProfileListCreateView,
    UserRoleUpdateView,
    UserSuspendView,
)

urlpatterns = [
    path("me/", MeView.as_view(), name="users-me"),
    path("onboarding/", UserOnboardingView.as_view(), name="users-onboarding"),
    path("search/", StudentSearchView.as_view(), name="student-search"),
    path("profiles/", UserProfileListCreateView.as_view(), name="user-profile-list"),
    path("profiles/<int:pk>/", UserProfileDetailView.as_view(), name="user-profile-detail"),
    path("admin/users/", UserManagementListView.as_view(), name="admin-user-list"),
    path("admin/users/<int:pk>/role/", UserRoleUpdateView.as_view(), name="admin-user-role"),
    path("admin/users/<int:pk>/suspend/", UserSuspendView.as_view(), name="admin-user-suspend"),
    path("admin/users/<int:pk>/verify-lecturer/", LecturerVerificationView.as_view(), name="admin-verify-lecturer"),
    path("admin/users/<int:pk>/", UserDeleteView.as_view(), name="admin-user-delete"),
]
