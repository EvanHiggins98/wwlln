import datetime
#import os
import sys

import backend.file_io as file_io
import backend.regex   as regex
import backend.utilities as utils

from data.models import Resource
from backend.debug import Debug
from script.utilities import ScriptParameterName, ScriptError


# Updates the track records for the given storm.
def storm_duration(storm, resource):
    path   = resource.get_source_path(storm)
    file   = resource.get_source_instances_list(storm)
    if (len(file) == 0):
        return datetime.timedelta(0)
    file   = resource.get_source_instances_list(storm)[0]
    url    = file_io.path_join(path, file, is_local = False)
    tracks = regex.find_all('(\d{2}.)\s+(\w+(?:-\w+)?)\s+(\d{2})'
                            '(\d{2})(\d{2})\s+(\d{2})'
                            '(\d{2})\s+(\d+\.\d+)(\w)\s+(\d+\.\d+)(\w)'
                            '\s+(\w+)\s+(\d+)\s+(\d+)',
                            file_io.request_url_contents(url, 'text', 'plain'))
    default_date_range = utils.default_storm_date_range()

    date_start = default_date_range['date_start']
    date_end   = default_date_range['date_end']

    # Loop through each track we found
    for track in tracks:
        year = int(track[2])
        # If the century portion of the year is not there, add it.
        if (year < 2000):
            year += 2000
        # Extract the datetime info for the track record
        track_record_date = datetime.datetime(year   = year,
                                              month  = int(track[3]),
                                              day    = int(track[4]),
                                              hour   = int(track[5]),
                                              minute = int(track[6])).date()

        # If this track record is more recent than the last known final record
        # for this storm, update that.
        if (date_end < track_record_date):
            date_end = track_record_date
        # Otherwise, check if the loaded track record predates the currently
        # known start date for the storm, and if it does update that.
        elif (date_start > track_record_date):
            date_start = track_record_date

    return (date_end - date_start)


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm    = globals__[ScriptParameterName.storm]
        resource = Resource.objects.get(name = 'trackfile')
        globals__['duration'] = datetime.timedelta(0)
        globals__['duration'] = storm_duration(storm, resource)

        globals__[ScriptParameterName.success] = True

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
        Debug('Unpredicted Error({}): {}'
              .format(error_type, error_message), print_to_stdout = True)
        error = ScriptError('Unexpected Error({}): "{}"'.format(error_type,
                                                                error_message))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
