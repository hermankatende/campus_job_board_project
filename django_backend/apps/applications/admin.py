from django.contrib import admin

from apps.applications.models import Application


@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ("id", "job", "applicant", "status", "created_at")
    search_fields = ("job__title", "applicant__full_name", "applicant__email")
    list_filter = ("status",)
