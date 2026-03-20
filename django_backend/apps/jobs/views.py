from django.db.models import Q
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.jobs.models import Job
from apps.jobs.serializers import JobSerializer
from apps.users.models import UserProfile


class JobListCreateView(generics.ListCreateAPIView):
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Job.objects.select_related("posted_by").all()

        search = self.request.query_params.get("search", "").strip()
        category = self.request.query_params.get("category", "").strip()
        status = self.request.query_params.get("status", "").strip()
        location = self.request.query_params.get("location", "").strip()

        if search:
            queryset = queryset.filter(
                Q(title__icontains=search)
                | Q(description__icontains=search)
                | Q(company__icontains=search)
                | Q(requirements__icontains=search)
            )
        if category:
            queryset = queryset.filter(category__iexact=category)
        if status:
            queryset = queryset.filter(status__iexact=status)
        if location:
            queryset = queryset.filter(location__icontains=location)

        return queryset

    def perform_create(self, serializer):
        uid = getattr(self.request, "firebase_user", {}).get("uid")
        email = getattr(self.request, "firebase_user", {}).get("email", "")
        profile, _ = UserProfile.objects.get_or_create(firebase_uid=uid, defaults={"email": email})
        serializer.save(posted_by=profile)


class JobDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Job.objects.select_related("posted_by").all()
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]


class MyJobsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        uid = getattr(request, "firebase_user", {}).get("uid")
        jobs = Job.objects.select_related("posted_by").filter(posted_by__firebase_uid=uid)
        serializer = JobSerializer(jobs, many=True)
        return Response(serializer.data)
