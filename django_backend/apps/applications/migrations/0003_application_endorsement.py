import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('applications', '0002_initial'),
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='application',
            name='lecturer_endorsed',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='application',
            name='endorsed_by',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='endorsed_applications',
                to='users.userprofile',
            ),
        ),
    ]
