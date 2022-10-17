from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io
from TCDataCollection.models import Resource
from TCDataProcessing.models import Storm, Sensor
from TCFrontEnd.models import Product

def P_DensityPlot(storm, resources, products_IN, output_path, output_filename):
    reduced_track = None
    wwlln_path = None
    storm_name = storm.name

    for product in products_IN:
        if product.name == 'reduced_trackfile':
            reduced_track = product.get_full_storage_path(storm)
        elif product.name == 'reduced_w_locations':
            wwlln_path = product.get_full_storage_path(storm)
    
    if not output_path:
        output_path = str(file_io.get_parent(reduced_track))
    if not output_filename:
        output_filename = "Density_Plot.jpg"
    if not storm_name:
        storm_name = "NO_NAME"
    
    run_matlab_script('CyclonePlot_Density','r"{}", r"{}", r"{}", r"{}", r"{}"'.format(reduced_track, wwlln_path, output_path, storm_name, output_filename))