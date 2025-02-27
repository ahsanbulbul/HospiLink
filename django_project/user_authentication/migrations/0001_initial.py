# Generated by Django 5.1.3 on 2024-11-10 19:31

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('username', models.CharField(max_length=255)),
                ('password_hash', models.TextField()),
                ('user_type', models.CharField(max_length=255)),
                ('security_question', models.TextField()),
                ('security_answer_hash', models.TextField()),
            ],
        ),
    ]
