import datetime

from django.db import models
from django.db.models import Q, F

_REGIONS_NEW = ['AL',  'CP',   'EP',   'IO', 'SH',   'WP', 'LS']

# Create your models here.
class Storm(models.Model):
    storm_number = models.IntegerField()
    name = models.CharField(max_length=32, null=True)
    region = models.CharField(max_length=50)
    season_number = models.IntegerField()
    date_start = models.DateField(null=True)
    date_end = models.DateField(null=True)
    is_complete = models.BooleanField(default=False)
    last_modified = models.DateTimeField()

    def __str__(self):
        return('{Storm.season_number}{Storm.region}{Storm.storm_number:02d}{name}'
                .format(Storm=self,name=' '+(self.name if self.name else '')))

    @staticmethod
    def get_season_range():
        storms       = Storm.valid_objects().order_by('season_number')
        season_begin = storms[0].season_number
        season_end   = storms[storms.count() - 1].season_number
        return list(range(season_begin, (season_end + 1)))

    @staticmethod
    def storms_by_year_and_region(storm_set = None):
        regions = _REGIONS_NEW
        storms = [(str(year),
                   [(region,
                     Storm.storms_in_year_and_region(year, region, storm_set))
                    for region in regions])
                  for year in reversed(range(Storm.storms_date_start().year,
                                           (Storm.storms_date_end().year + 1)))]
        return Storm.remove_empty_storm_groups(storms)

    @staticmethod
    def storms_in_year_and_region(year, region, storms = None):
        date_start = datetime.date(year = year,       month = 1, day = 1)
        date_end   = datetime.date(year = (year + 1), month = 1, day = 1)
        if (storms is None):
            storms = Storm.valid_objects()
        return (storms.filter(region = region)
                       .exclude(  Q(date_end__lt    = date_start)
                                | Q(date_start__gte = date_end))
                        .order_by('name'))
    @staticmethod
    def storms_date_start():
        result = Storm.valid_objects().order_by('date_start')
        if not result:
            return datetime.date(2009,1,1)
        return result[0].date_start

    @staticmethod
    def storms_date_end():
        result = Storm.valid_objects().order_by('-date_start')
        if not result:
            return datetime.date.today()
        return result[0].date_end

    @staticmethod
    def valid_objects():
        return Storm.objects.exclude(Q(date_start__isnull=True)|
                                    (Q(date_end__isnull=True)&Q(is_complete=True))|
                                    (Q(date_end__isnull=False)&Q(is_complete=False)))
                                    #won't allow comparison between isnull and non True/False literal
                                    #Q(date_end__isnull=F('is_complete'))

    @staticmethod
    def remove_empty_storm_groups(storms):
        for year in storms:
            for i_region in reversed(list(enumerate(year[1]))):
                i      = i_region[0]
                region = i_region[1]
                if (len(region[1]) == 0):
                    del year[1][i]
        for i_year in reversed(list(enumerate(storms))):
            i    = i_year[0]
            year = i_year[1]
            if (len(year[1]) == 0):
                del storms[i]
        return storms

    @staticmethod
    def storms_search_by_year_and_region(search_string):
        if (search_string.isdigit()):
            search_value = int(search_string)
            storm_filter = (  Q(season_number__contains = search_value)
                            | Q(storm_number__contains  = search_value)
                            | Q(date_start__contains    = search_value)
                            | Q(date_end__contains      = search_value))
        else:
            storm_filter = (  Q(region__contains = search_string.upper())
                            | Q(name__contains   = search_string.title()))

        storms = Storm.valid_objects().filter(storm_filter)

        return { 'storm_count': storms.count(),
                 'storms': Storm.storms_by_year_and_region(storms) }

class Mission(models.Model):
    # Stores the letter identifier for a data collection mission.
    name = models.CharField(max_length = 8)

    def __str__(self):
        return ('Mission: {Mission.name}'.format(Mission = self))


class Sensor(models.Model):
    mission = models.ForeignKey(Mission, on_delete = models.CASCADE)
    name    = models.CharField(max_length = 8)

    def __str__(self):
        return ('Mission: {Sensor.mission} | Sensor: {Sensor.name}'.format(Sensor = self))
