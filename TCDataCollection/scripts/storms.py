import datetime
import re
import resource
from wwlln.scripts.file_io import create_path
from wwlln.scripts.url_request import request_list_dir
from TCDataCollection.models import Source, Resource
from TCDataProcessing.models import Storm, Mission, Sensor
from TCDataProcessing.models import Sensor
from TCDataProcessing.scripts.python.trackfile import TrackFile
from TCFrontEnd.models import Product


_REGIONS_OLD = [ 'ATL', 'CPAC', 'EPAC', 'IO', 'SHEM', 'WPAC']

_REGIONS_NEW = [ 'AL', 'CP','EP', 'IO', 'LS', 'SH','WP']

def find_navy_storms(region=None, season_num=None):
    stormsFound = []
    if(not isinstance(region,list)):
        region = [region]
    if(not isinstance(season_num,list)):
        season_num = [season_num]
    for r in region:
        for s in season_num:
            url = ('https://www.nrlmry.navy.mil/TC/tc{Season}/{Region}/'
                .format(Season = s, Region = r))
            list_dir = request_list_dir(url)
            if(list_dir):
                stormsFound += list_dir['dirs']
    return stormsFound


def find_new_storms(region=None, season_num=None,storm_num=None, date_range=None):
    if(region==None):
        region = _REGIONS_NEW
    if(not isinstance(region,list)):
        region = [region]
    if(season_num==None):
        season_num = datetime.datetime.now().year
    old_storms = Storm.objects.all()
    navy_storms = find_navy_storms(region, season_num if season_num>2000 else season_num+2000)
    storm_re = re.compile(r'[a-zA-z]{2}\d{6}')
    for storm in navy_storms:
        re_result = storm_re.search(storm) 
        if re_result:
            storm_result = re_result.group(0)
            storm_id = int(storm_result[2:4])
            if (not storm_num and storm_id<90) or storm_id==storm_num:
                storm_region = storm_result[0:2]
                storm_season = int(storm_result[-2:])
                cur_storm = Storm(
                    storm_number = storm_id,
                    region = storm_region,
                    season_number = storm_season,
                    last_modified = datetime.datetime.min
                )
                if(not old_storms.filter(storm_number = cur_storm.storm_number).exists()):
                    cur_storm.save()
        else:
            print('invalid listdir entry found: {} with attempted regex string: {}'.format(storm,r'[a-zA-z]{2}\d{6}'))

def update_storm_info(storm,dir):
    track = TrackFile()
    track.parseNavyTrackFile(create_path(dir,'trackfile.txt'))
    storm_name = track.get_storm_name()
    if storm_name:
        storm.name = storm_name.capitalize()
    storm.date_start = track.get_start_date()
    storm.date_end = track.get_end_date()
    storm.save()

def update_storm_resources(storms=None, resources=None):
    if not resources:
        resources = Resource.objects.all()
    elif not isinstance(resources,list):
        resources = [resources]
    if not storms:
        storms = Storm.objects.filter(is_complete=False)
    elif not isinstance(storms,list):
        storms = [storms]
    sensors = Sensor.objects.all()
    for resource in resources:
        for storm in storms:
            for sensor in sensors:
                dir = resource.collect(storm=storm,mission=sensor.mission,sensor=sensor,date_time=datetime.datetime.now())
                if resource.name == 'trackfile' and dir:
                    update_storm_info(storm,dir)

def update_storm_products(storms=None, products=None):
    if not products:
        products = Product.objects.all()
    elif not isinstance(products,list):
        products = [products]
    if not storms:
        storms = Storm.objects.filter(is_complete=False)
    elif not isinstance(storms,list):
        storms = [storms]
    
    