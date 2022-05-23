from django.core.management.base import BaseCommand, CommandError
from TCDataCollection.scripts import storms
from TCDataCollection.models import Resource
from TCFrontEnd.models import Product

class Command(BaseCommand):
    help = 'Updates storm data by retrieving resources then processing pipelines associated with products'

    def add_arguments(self, parser):
        parser.add_argument('--region',type=str,nargs='?',default=None)
        parser.add_argument('--season_num', type=int,nargs='?',default=None)
        parser.add_argument('--storm_num', type=int,nargs='?',default=None)
        #parser.add_argument('--date_range', type=int,nargs='?',default=None)

    def handle(self, *args, **options):
        try:
            region = options['region']
            season_num = options['season_num']
            storm_num = options['storm_num']
            #date_range = options['date_range']
            storms.find_new_storms(region,season_num,storm_num)
            storms.update_storms()
            #for prod in Product.objects.all():
                #prod.create()
        except:
            raise CommandError('Command Error')
