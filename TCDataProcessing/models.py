from django.db import models
from django.db.models import Q

_REGIONS_NEW = ['AL',  'CP',   'EP',   'IO', 'SH',   'WP', 'LS']

# Create your models here.
class Storm(models.Model):
    storm_number = models.IntegerField()
    name = models.CharField(max_length=32, null=True)
    region = models.CharField(max_length=50)
    season_number = models.IntegerField(null=True)
    date_start = models.DateField(null=True)
    date_end = models.DateField(null=True)
    is_complete = models.BooleanField(default=False)
    last_modified = models.DateTimeField()

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


class Sensor(models.Model):
    mission = models.ForeignKey(Mission, on_delete = models.CASCADE)
    name    = models.CharField(max_length = 8)
