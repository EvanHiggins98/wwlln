import datetime
from wwlln.scripts.file_io import createPath
from wwlln.scripts.url_request import request_list_dir
from TCDataCollection.models import Source, Resource
from TCDataProcessing.models import Storm, Mission, Sensor
import re
from TCDataProcessing.models import Sensor
from copy import deepcopy
import datetime

_REGIONS_OLD = [ 'ATL', 'CPAC', 'EPAC', 'IO', 'SHEM', 'WPAC']

_REGIONS_NEW = [ 'AL', 'CP','EP', 'IO', 'LS', 'SH','WP']

def find_navy_storms(region=None, season_num=None):
    stormsFound = []
    if(not isinstance(region,list)):
        region = list(region)
    if(not isinstance(season_num,list)):
        season_num = [season_num]
    for r in region:
        for s in season_num:
            url = ('http://www.nrlmry.navy.mil/TC/tc{Season}/{Region}/'
                .format(Season = s, Region = r))
            list_dir = request_list_dir(url)
            if(list_dir):
                stormsFound += list_dir['dirs']
    return stormsFound


def find_new_storms(region=None, season_num=None,storm_num=None, date_range=None):
    if(region==None):
        region = _REGIONS_NEW
    if(not isinstance(region,list)):
        region = list({region})
    if(season_num==None):
        season_num = datetime.datetime.now().year
    old_storms = Storm.objects.all()
    navy_storms = find_navy_storms(region, season_num)
    storm_re = re.compile(r'[a-zA-z]{2}\d{2}')
    for storm in navy_storms:
        storm_id = storm_re.search(storm).group(0)
        cur_storm = Storm(
            storm_number = storm_id[2:],
            region = storm_id[:2],
            last_modified = datetime.datetime.min
        )
        if(not old_storms.filter(storm_number = cur_storm.storm_number).exists()):
            cur_storm.save()

def update_storms():
    resources = Resource.objects.all()
    storms = Storm.objects.all()
    missions = Mission.objects.all()
    sensors = Sensor.objects.all()
    for resource in resources:
        for storm in storms:
            for mission in missions:
                for sensor in sensors:
                    resource.collect(storm=storm,mission=mission,sensor=sensor,date_time=datetime.datetime.now())