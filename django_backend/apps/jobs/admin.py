from django.contrib import admin

from apps.jobs.models import Job


@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "company", "category", "status", "created_at")
    search_fields = ("title", "company", "category", "location")
    list_filter = ("status", "category")
