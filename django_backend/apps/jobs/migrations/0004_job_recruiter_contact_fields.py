from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('jobs', '0003_savedjob'),
    ]

    operations = [
        migrations.AddField(
            model_name='job',
            name='recruiter_contact_name',
            field=models.CharField(blank=True, max_length=200),
        ),
        migrations.AddField(
            model_name='job',
            name='recruiter_contact_email',
            field=models.EmailField(blank=True, max_length=254),
        ),
        migrations.AddField(
            model_name='job',
            name='recruiter_contact_phone',
            field=models.CharField(blank=True, max_length=50),
        ),
        migrations.AddField(
            model_name='job',
            name='recruiter_contact_company',
            field=models.CharField(blank=True, max_length=200),
        ),
    ]
