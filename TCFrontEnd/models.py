from django.db import models

# Create your models here.
class Product(models.Model):
    name = models.CharField(max_length=32)
    title = models.CharField(max_length=64)
    description = models.TextField()
    path = models.TextField()
    _is_public = models.BooleanField(default=False)
