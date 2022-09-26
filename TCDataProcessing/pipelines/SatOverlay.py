from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io
from TCDataCollection.models import Resource
from TCDataProcessing.models import Storm, Sensor
from TCFrontEnd.models import Product

def P_SatOverlay(storm, resources, products_IN, output_path, output_filename):
    reduced_track = None
    wwlln_path = None
    storm_name = storm.name

    for product in products_IN:
        if product.name == 'reduced trackfile':
            reduced_track = product.get_full_storage_path(storm)
        elif product.name == 'reduced wwlln locations':
            wwlln_path = product.get_full_storage_path(storm)
    #TODO: ADD DT'S CODE
    pass