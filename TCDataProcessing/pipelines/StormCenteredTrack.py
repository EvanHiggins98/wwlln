from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io

def P_StormCenteredTrack(trackfile_path,wwlln_path):
    reduced_track = trackfile.navyToReduced(trackfile_path, reduced_track)
    run_matlab_script('StormCenteredLocations.StormCenteredLocations','{}, {}'.format(reduced_track,wwlln_path))
    