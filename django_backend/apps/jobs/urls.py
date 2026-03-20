from django.urls import path

from apps.jobs.views import (
    JobDetailView,
    JobListCreateView,
    JobRestoreView,
    MyJobsView,
    SavedJobDeleteView,
    SavedJobListView,
)

urlpatterns = [
    path("", JobListCreateView.as_view(), name="job-list-create"),
    path("mine/", MyJobsView.as_view(), name="my-jobs"),
    path("saved/", SavedJobListView.as_view(), name="saved-jobs"),
    path("saved/<int:job_id>/", SavedJobDeleteView.as_view(), name="saved-job-delete"),
    path("<int:pk>/restore/", JobRestoreView.as_view(), name="job-restore"),
    path("<int:pk>/", JobDetailView.as_view(), name="job-detail"),
]
