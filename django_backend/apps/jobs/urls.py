from django.urls import path

from apps.jobs.views import JobDetailView, JobListCreateView, MyJobsView, JobRestoreView

urlpatterns = [
    path("", JobListCreateView.as_view(), name="job-list-create"),
    path("mine/", MyJobsView.as_view(), name="my-jobs"),
    path("<int:pk>/restore/", JobRestoreView.as_view(), name="job-restore"),
    path("<int:pk>/", JobDetailView.as_view(), name="job-detail"),
]
