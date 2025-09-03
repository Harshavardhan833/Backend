import os
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()

class Command(BaseCommand):
    help = 'Ensures a superuser exists with credentials from environment variables.'

    def handle(self, *args, **kwargs):
        username = os.environ.get('SUPERUSER_USERNAME')
        email = os.environ.get('SUPERUSER_EMAIL')
        password = os.environ.get('SUPERUSER_PASSWORD')

        if not all([username, email, password]):
            self.stdout.write(self.style.ERROR('Missing superuser environment variables. Skipping.'))
            return

        user = User.objects.filter(username=username).first()
        if not user:
            user = User.objects.filter(email=email).first()

        if user:
            # If user exists, update their password to be sure it's correct
            user.set_password(password)
            user.is_superuser = True
            user.is_staff = True
            user.save()
            self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" already existed. Password has been updated.'))
        else:
            # If user does not exist, create them
            User.objects.create_superuser(username=username, email=email, password=password)
            self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" created successfully!'))
