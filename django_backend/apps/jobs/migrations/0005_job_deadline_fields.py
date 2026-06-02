from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("jobs", "0004_job_recruiter_contact_fields"),
    ]

    operations = [
        migrations.AddField(
            model_name="job",
            name="application_deadline",
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="job",
            name="deadline_reminder_sent_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
