from django.db import models
from django.db.models.deletion import CASCADE
from TCDataProcessing.models import Mission
import wwlln.scripts.file_io as file_io
import wwlln.scripts.url_request as url_request
import re
import urllib.error
import pathlib

# Create your models here.
class Source(models.Model):
    name = models.CharField(max_length=32)
    url_path = models.TextField()
    username = models.CharField(max_length = 64, null = True, default = None)
    password = models.CharField(max_length = 64, null = True, default = None)
    description = models.TextField()
    is_local = models.BooleanField()

class Resource(models.Model):
    source = models.ForeignKey(Source, on_delete=CASCADE)
    name = models.CharField(max_length=32)
    path = models.TextField()
    filename = models.TextField()
    description = models.TextField()
    local_path = models.TextField()
    pipeline = models.TextField()

    def collect(self, storm='', mission='', sensor='', date_time=None, force=False):
        try:
            full_url = url_request.createURL(self.source.url_path,self.path)
            formatted_url = full_url.format(Storm=storm, Mission=mission, Sensor=sensor, Year=date_time.year, Month=date_time.month, Day=date_time.day)
            formatted_path = self.local_path.format(Storm=storm, Mission=mission, Sensor=sensor, Year=date_time.year, Month=date_time.month, Day=date_time.day)
            formatted_filename = self.filename.format(Storm=storm, Mission=mission, Sensor=sensor, Year=date_time.year, Month=date_time.month, Day=date_time.day)
            filename_pat = re.compile(formatted_filename)
            list_dir = url_request.request_list_dir(formatted_url)
            if(len(list_dir)):
                resource_list = list_dir['dirs']
                last_modified = list_dir['last_modified']
                file_results=[]
                for i in range(len(resource_list)):
                    if re.match(filename_pat):
                        file_results.append({'file':resource_list[i],'last_modified':last_modified[i]})
                for file in file_results:
                    if file['last_modified']>file_io.get_last_modified_datetime(file,formatted_path):
                        file_url = url_request.createURL(formatted_path,file['file'])
                        file_data = url_request(file_url)
                        file_io.create_directory(formatted_path)
                        file_io.create_file(file,formatted_path,Data=file_data)
            return True
        except (urllib.error.URLError,OSError):
            return False
        
