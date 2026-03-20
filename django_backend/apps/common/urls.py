from django.urls import path

from apps.common.views import DashboardStatsView, HealthCheckView

urlpatterns = [
    path("health/", HealthCheckView.as_view(), name="health"),
    path("stats/", DashboardStatsView.as_view(), name="dashboard-stats"),
]
