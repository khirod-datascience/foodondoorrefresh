# Generated by Django 5.1.7 on 2025-04-25 09:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('auth_app', '0006_remove_vendor_phone_alter_vendor_contact_number_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='vendor',
            name='phone',
            field=models.CharField(blank=True, max_length=15, null=True),
        ),
    ]
