from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io
from TCDataCollection.models import Resource
from TCDataProcessing.models import Storm, Sensor
from TCFrontEnd.models import Product

def P_StormCenteredTrack(storm, resources, products_IN, output_path, output_filename):
    reduced_track = None
    AE_path = None
    storm_name = storm.name

    for product in products_IN:
        if product.name == 'reduced trackfile':
            reduced_track = product.get_full_storage_path(storm)
    
    sensors = Sensor.objects.all()
    for resource in resources:
        for sensor in sensors:
            dir = resource.collect(storm, sensor.mission, sensor)
            if resource.name == 'AEFiles' and dir:
                AE_path = dir
    
    if not output_path:
        output_path = str(file_io.get_parent(reduced_track))
    
    if not output_filename:
        output_filename = 'Storm_Centered_Locations.txt'
    
    output_path = file_io.create_path(output_path, output_filename)
    run_matlab_script('StormCenteredLocations','r"{}", r"{}", r"{}"'.format(reduced_track, AE_path, output_path))
    
# example:
# from TCDataProcessing.pipelines import StormCenteredTrack as sct
# sct.P_StormCenteredTrack(r'E:\Users\MetaTek\Documents\Projs\wwlln\wwlln\data\Rai\trackfile.txt',
#                           r'E:\Users\MetaTek\Documents\Projs\wwlln\wwlln\data\Rai')

