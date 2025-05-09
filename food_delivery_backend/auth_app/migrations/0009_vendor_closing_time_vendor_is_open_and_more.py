# Generated by Django 5.2 on 2025-04-27 11:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('auth_app', '0008_alter_order_customer'),
    ]

    operations = [
        migrations.AddField(
            model_name='vendor',
            name='closing_time',
            field=models.TimeField(blank=True, help_text='Closing time (optional)', null=True),
        ),
        migrations.AddField(
            model_name='vendor',
            name='is_open',
            field=models.BooleanField(default=True, help_text='Is the restaurant currently open?'),
        ),
        migrations.AddField(
            model_name='vendor',
            name='opening_time',
            field=models.TimeField(blank=True, help_text='Opening time (optional)', null=True),
        ),
    ]
