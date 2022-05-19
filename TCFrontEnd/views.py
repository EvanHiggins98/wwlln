from django.db.models import Q
from django.http import Http404
from django.shortcuts import get_object_or_404, render

from TCFrontEnd.models import Product
from TCDataProcessing.models import Storm

_REGIONS_NEW = ['AL',  'CP',   'EP',   'IO', 'SH',   'WP', 'LS']

def index(request):
    return render(request, 'TCFrontend/index.html', {'storms': Storm})

def view_storm(request, season_num, region, storm_num):
    storm = get_object_or_404(Storm,
                              season_number = season_num,
                              region        = region,
                              storm_number  = storm_num)
    #products = Product.objects.filter(resource__source__per_storm = True)
    products = [product
                for product in Product.objects.all()
                if (product.is_public())]
    context = { 'storm':         storm,
                    #'scripts':       Script.objects.all(),
                    'products':      products,
                    'season_number': season_num,
                    'region':        region,
                    'season_list':   Storm.get_season_range(),
                    'region_list':   _REGIONS_NEW }
    return render(request,'TCFrontEnd/storm_view.html',context)


def view_storm_group(request, season_num, region = None):
    query = Q(season_number = season_num)
    if (region is not None):
        query = (query & Q(region = region))

    # print(query, file = sys.stderr)

    season_list = Storm.get_season_range()
    region_list = _REGIONS_NEW

    storms = Storm.objects.filter(query)
    storm_count = storms.count()
    if (storm_count == 0):
        if (region is not None):
            if ((int(season_num) in season_list) and (region in region_list)):
                return render(request,
                              'storms/no_storms_found.html',
                              { 'error_string': ('Season: {} - Region: {}'
                                                 .format(season_num, region)) })
        else:
            raise Http404('<h1>Page not found</h1>')

    return render(request,
                  'storms/index_storm_group.html',
                  { 'storm_count':   storm_count,
                    'storms':        Storm.storms_by_year_and_region(storms),
                    'season_number': season_num,
                    'region':        region,
                    'season_list':   season_list,
                    'region_list':   region_list })


def search_view(request):
    search_string = request.GET.get('SearchInputBox')
    search_storms = Storm.storms_search_by_year_and_region(search_string)
    return render(request,
                  'storms/search_view.html',
                  { 'search_string': search_string,
                    'storm_count':   search_storms['storm_count'],
                    'storms':        search_storms['storms']})

