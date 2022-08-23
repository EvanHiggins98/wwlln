from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io

def P_StormCenteredTrack(trackfile_path, wwlln_path, output_path=''):
    reduced_track = trackfile.navyToReduced(trackfile_path)
    if not output_path:
        output_path = str(file_io.get_parent(trackfile_path)) + r"\\Storm_Centered_Locations.txt"
    run_matlab_script('StormCenteredLocations','r"{}", r"{}", r"{}"'.format(reduced_track,wwlln_path,output_path))
    
# example:
# from TCDataProcessing.pipelines import StormCenteredTrack as sct
# sct.P_StormCenteredTrack(r'E:\Users\MetaTek\Documents\Projs\wwlln\wwlln\data\Rai\trackfile.txt',
#                           r'E:\Users\MetaTek\Documents\Projs\wwlln\wwlln\data\Rai')

