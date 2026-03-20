from django.contrib import admin

from apps.users.models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("id", "firebase_uid", "email", "role", "created_at")
    search_fields = ("firebase_uid", "email", "full_name")
    list_filter = ("role",)
