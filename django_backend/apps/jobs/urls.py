from django.urls import path

from apps.jobs.views import JobDetailView, JobListCreateView, MyJobsView

urlpatterns = [
    path("", JobListCreateView.as_view(), name="job-list-create"),
    path("mine/", MyJobsView.as_view(), name="my-jobs"),
    path("<int:pk>/", JobDetailView.as_view(), name="job-detail"),
]
