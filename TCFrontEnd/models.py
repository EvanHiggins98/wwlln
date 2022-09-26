from django.db import models
import wwlln.scripts.file_io as file_io
import datetime

# Create your models here.
class Product(models.Model):
    name = models.CharField(max_length=32)
    title = models.CharField(max_length=64)
    description = models.TextField()
    path = models.TextField()
    _is_public = models.BooleanField(default=False)
    pipeline = models.TextField(null=True)

    STATIC_PRODUCT_PATH = file_io.create_path('data','processed_data')
    STATIC_PIPELINE_PATH = file_io.create_path('TCDataProcessing', 'pipelines')
    STATIC_ROOT = file_io.create_path('static')

    def __str__(self):
        return ('{Product.name} | {Product.title}'.format(Product=self))

    def is_public(self):
        return self._is_public

    def get_storage_path(self, storm = None, date_time = None):
        if(storm is None):
            return self.path
        if(storm.season_number is None):
            return self.path
        if (date_time is None):
            date_time = datetime.datetime.now()
        return file_io.create_path(self.STATIC_PRODUCT_PATH, str(storm.season_number), storm.region, str(storm.storm_number), self.path)

    def get_relative_storage_path(self, storm = None, date_time = None):
        if(storm is None):
            return self.path
        if(storm.season_number is None):
            return self.path
        if (date_time is None):
            date_time = datetime.datetime.now()
        return file_io.create_path(self.STATIC_ROOT, self.STATIC_PRODUCT_PATH, str(storm.season_number), storm.region, str(storm.storm_number), self.path)

    def get_full_storage_path(self, storm = None, date_time = None):
        if(storm is None):
            return self.path
        if(storm.season_number is None):
            return self.path
        if (date_time is None):
            date_time = datetime.datetime.now()
        return file_io.create_path(file_io.ROOT_PATH, self.STATIC_ROOT, self.STATIC_PRODUCT_PATH, str(storm.season_number), storm.region, str(storm.storm_number), self.path)

    def create(self, storm, resources):
        prodList = Product.objects.exclude(name = self.name)
        parameters = 'r"{}", r"{}", r"{}", '.format(storm, resources, prodList)
        parameters += 'r"{}"'.format(self.get_full_storage_path(storm))

        exec("import " + self.STATIC_PIPELINE_PATH + self.pipeline)
        return eval(self.pipeline+".P_"+self.pipeline+"("+parameters+")")
