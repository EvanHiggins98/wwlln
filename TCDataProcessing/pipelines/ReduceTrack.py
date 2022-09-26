from TCDataProcessing.scripts.scriptEngine import run_python_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io
from TCDataCollection.models import Resource
from TCDataProcessing.models import Storm, Sensor
from TCFrontEnd.models import Product

def P_DensityPlot(storm, resources, products_IN, output_path, output_filename):
    navy_track = None
    
    sensors = Sensor.objects.all()
    for resource in resources:
        for sensor in sensors:
            dir = resource.collect(storm, sensor.mission, sensor)
            if resource.name == 'trackfile' and dir:
                navy_track = dir
    
    if output_filename is None:
        output_filename = "trackfile_reduced.txt"
    if output_path is None:
        output_path = str(file_io.get_parent(reduced_track))
    
    file_io.create_path(output_path, output_filename)
    reduced_track = trackfile.navyToReduced(navy_track, output_path)