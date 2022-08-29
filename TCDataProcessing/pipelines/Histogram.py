from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io

def P_Histogram(trackfile_path, wwlln_path, output_path='', output_filename='', storm_name=''):
    reduced_track = trackfile.navyToReduced(trackfile_path)
    
    if not output_path:
        output_path = str(file_io.get_parent(trackfile_path))
    if not output_filename:
        output_filename = "Histogram.jpg"
    if not storm_name:
        storm_name = "NO_NAME"
    
    run_matlab_script('CycloneHistogram','r"{}", r"{}", r"{}", r"{}", r"{}"'.format(reduced_track, wwlln_path, storm_name, output_path, output_filename))