from django.core.management.base import BaseCommand, CommandError
from TCDataCollection.scripts import storms
from TCDataCollection.models import Resource
from TCFrontEnd.models import Product
from django.db.models import Q
from TCDataProcessing.models import Storm
from wwlln.scripts.custom_logging import _globalLogger

"""
Command called from the command line to update one or more(?) storm(s)
Calls scrypts from the pipelines
Update source files?
"""

class Command(BaseCommand):
    help = 'Updates storm data by retrieving resources then processing pipelines associated with products'

    def add_arguments(self, parser):
        parser.add_argument('--region', type=str, nargs='?', default=None)
        parser.add_argument('--season_num', type=int, nargs='?', default=None)
        parser.add_argument('--storm_num', type=int, nargs='?', default=None)
        parser.add_argument('--find_new', type=bool, nargs='?', const=True, default=False)
        parser.add_argument('--u_all', type=bool, nargs='?', const=True, default=False)
        parser.add_argument('--u_source', type=bool, nargs='?', const=True, default=False)
        #parser.add_argument('--date_range', type=int,nargs='?',default=None)

    def handle(self, *args, **options):
        """
        Current operation if no storm info supplied:
        -update ALL storms
        TODO:
        -Change default operation to only incompleate storms
        """
        try:
            region = options['region']
            season_num = options['season_num']
            storm_num = options['storm_num']
            find_new = options['find_new']
            update_all = options['u_all']
            update_sources = options['u_source']
            
            if find_new:
                storms.find_new_storms(region, season_num, storm_num)

            if update_all:
                storm_glob = Storm.objects.all()
            else:
                if season_num is not None:
                    query = Q(season_number = season_num)
                    if region is not None:
                        query = query & Q(region = region)
                    if storm_num is not None:
                        query = query & Q(storm_number = storm_num)
                    
                    storm_glob = Storm.objects.filter(query)
                else:
                    storm_glob = Storm.objects.filter(is_complete=False)
            
            if storm_glob.count() == 0:
                _globalLogger.log_message("No storms found when attempting to update", _globalLogger._DEBUG)
                return
            
            _globalLogger.log_message("Attempting to update {storm_count} storms".format(storm_count=storm_glob.count()), _globalLogger._DEBUG)
            if update_sources:
                storms.update_storm_resources(storms=storm_glob)
            
            storms.update_storm_products(storms=storm_glob)
            
        except Exception as e:
            raise CommandError('Command Error: {}'.format(e))
