# Generated manually on 2026-03-20

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('jobs', '0002_job_deleted_at_job_deleted_by_job_is_deleted'),
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='SavedJob',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('saved_at', models.DateTimeField(auto_now_add=True)),
                ('job', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='saved_by', to='jobs.job')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='saved_jobs', to='users.userprofile')),
            ],
            options={
                'ordering': ['-saved_at'],
                'unique_together': {('user', 'job')},
            },
        ),
    ]
