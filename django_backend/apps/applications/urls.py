from django.urls import path

from apps.applications.views import (
    ApplicationDetailView,
    ApplicationListCreateView,
    JobApplicationListView,
    JobApplicationStatsView,
)

urlpatterns = [
    path("", ApplicationListCreateView.as_view(), name="application-list-create"),
    path("<int:pk>/", ApplicationDetailView.as_view(), name="application-detail"),
    path("job/<int:job_id>/", JobApplicationListView.as_view(), name="job-applications"),
    path("job/<int:job_id>/stats/", JobApplicationStatsView.as_view(), name="job-application-stats"),
]
