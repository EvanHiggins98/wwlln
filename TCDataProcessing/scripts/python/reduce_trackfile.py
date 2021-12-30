import os
import sys

#import backend.file_io as file_io

#from django.conf import settings

from backend.debug import Debug
from script.utilities import ScriptError, ScriptParameterName
from storm.models import StormTrack


# Take the track records that were put into the StormTrack table for the given
# storm and put them into a trackfile so that we have a trackfile with only the
# data we want and in the format we want it.
def create_reduced_trackfile(storm, trackfile_path):
    if (storm.stormtrack_set.count() == 0):
        return
    Debug('Creating trackfile for: {}'.format(storm), print_to_stdout = True)
    #file_io.safe_create_directory(storage_path)
    #trackfile_filename = settings.PATHS.get_storm_trackfile_filename(storm)
    #trackfile_path = os.path.join(storage_path, trackfile_filename)
    try:
        with open(trackfile_path, 'wt') as output_file:
            tracks = StormTrack.objects.filter(storm_id = storm.id).order_by('time')
            for track in tracks:
                output_file.write('{date_time.year}\t{date_time.month}\t'
                                  '{date_time.day}\t{date_time.hour}\t'
                                  '{TLat}\t{TLon}\t{TPress}\t{TWind}\t0\n'
                                  .format(date_time = track.time,
                                          TLat      = track.latitude,
                                          TLon      = track.longitude,
                                          TPress    = track.pressure,
                                          TWind     = track.wind_speed))
    except IOError:
        Debug('Failed to create/open: "{}"'.format(trackfile_path))


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm           = globals__[ScriptParameterName.storm]
        #storm_trackfile = globals__[ScriptParameterName.storm_trackfile]
        #output_dir   = globals__[ScriptParameterName.output_dir]
        output_path     = globals__[ScriptParameterName.output_instances_list].path
        storm_trackfile = globals__[ScriptParameterName.output_regex]
        storm_trackfile = storm_trackfile.replace('\\.', '.')
        storm_trackfile = os.path.join(output_path, storm_trackfile)

        create_reduced_trackfile(storm, storm_trackfile)

    except ScriptError as error:
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except KeyError as error:
        error = ScriptError('Undefined required GLOBAL variable "{}"'
                            .format(error))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except NameError as error:
        error = ScriptError('Undefined required LOCAL variable "{}"'
                            .format(error))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except:
        error_type    = sys.exc_info()[0]
        error_message = sys.exc_info()[1]
        Debug('Unpredicted Error({}): {}'.format(error_type, error_message), print_to_stdout = True)
        error = ScriptError('Unexpected Error({}): "{}"'.format(error_type, error_message))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
