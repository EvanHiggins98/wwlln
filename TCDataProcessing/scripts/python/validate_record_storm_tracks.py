import os
import sys
import datetime

from django.utils import timezone

import backend.regex as regex
from backend.debug import Debug, DebugFunctionArgs
from script.utilities import ScriptError, ScriptParameterName
from storm.models import StormTrack


# Updates the track records for the given storm.
def validate_record_storm_tracks(storm, trackfile_filename):
    DebugFunctionArgs(print_to_stdout = False)
    if (not os.path.isfile(trackfile_filename)):
        Debug('Could not find trackfile: {}'.format(trackfile_filename), print_to_stdout = True)
        return False
    with open(trackfile_filename, 'rt') as track_records:
        Debug('Successfully opened the trackfile', print_to_stdout = False)
        # Extract each record of this storm from the track file.
        # [ 0] NNE -> N = zero padded storm number, E = extra ID character?
        # [ 1] Name
        # [ 2] Year
        # [ 3] Month
        # [ 4] Day
        # [ 5] Hour
        # [ 6] Minute
        # [ 7] Latitude
        # [ 8] N/S designation
        # [ 9] Longitude
        # [10] E/W designation
        # [11] Region name
        # [12] Wind Speed
        # [13] Pressure
        tracks = regex.find_all('(\d{2}.)\s+(\w+(?:-\w+)?)\s+(\d{2})(\d{2})(\d{2})\s+(\d{2})'
                                '(\d{2})\s+(\d+\.\d+)(\w)\s+(\d+\.\d+)(\w)\s+(\w+)\s+(\d+)\s+(\d+)',
                                track_records.read())
    Debug('Finished reading the trackfile', print_to_stdout = False)
    date_start   = timezone.now().date()
    date_end     = datetime.date(year = 1, month = 1, day = 1)
    storm_tracks = storm.stormtrack_set.all()
    # Loop through each track we found
    for track in tracks:
        wind_speed = int(track[12])
        pressure   = int(track[13])
        # Center the coordinates about the intersection of The Prime
        # Meridian and the Equator, with the northern and eastern
        # hemispheres being positive valued and the southern and western
        # hemispheres being negatively valued with respect to this
        # interseciton point.
        lat = float(track[7])
        lon = float(track[9])
        if (track[ 8] == 'S'):
            lat = -lat
        if (track[10] == 'W'):
            lon = -lon
        year = int(track[2])
        # If the century portion of the year is not there, add it.
        if (year < 2000):
            year += 2000
        # Extract the datetime info for the track record
        time = timezone.datetime(year   = year,
                                 month  = int(track[3]),
                                 day    = int(track[4]),
                                 hour   = int(track[5]),
                                 minute = int(track[6]))
        # Convert the timestamp to a timezone-aware datetime to please Django.
        time = timezone.make_aware(time)

        # Get the date of the track record
        track_record_date = time.date()
        # If this track record is more recent than the last known final
        # record for this storm, update that.
        if (date_end < track_record_date):
            date_end = track_record_date
        # Otherwise, check if the loaded track record predates the currently
        # known start date for the storm, and if it does update that.
        elif (date_start > track_record_date):
            date_start = track_record_date
        test_track = StormTrack(time       = time,
                                latitude   = lat,
                                longitude  = lon,
                                wind_speed = wind_speed,
                                pressure   = pressure)
        if (not storm_tracks.filter(time       = test_track.time,
                                    latitude   = test_track.latitude,
                                    longitude  = test_track.longitude,
                                    wind_speed = test_track.wind_speed,
                                    pressure   = test_track.pressure).exists()):
            Debug('Found a track in the trackfile that isn\'t in the database',
                  print_to_stdout = False)
            raise ScriptError('For Storm "{Storm}", found track in file '
                              '"{File}" with data: '
                              'Time({Track.time}) | '
                              'Latitude({Track.latitude}) | '
                              'Longitude({Track.longitude}) | '
                              'WindSpeed({Track.wind_speed}) | '
                              'Pressure({Track.pressure}) '
                              'that did not have a corresponding entry in the '
                              'StormTrack database'
                              .format(Storm = storm, File = trackfile_filename, Track = test_track))
    Debug('All tracks in the trackfile were entered into the StormTrack database.',
          print_to_stdout = False)

    success = ((storm.date_start == date_start) and (storm.date_end == date_end))

    Debug('Storm date range saved in Storm database: {} - {}\n'
          'Storm date range detected during testing: {} - {}\n'
          'Final result of validation: {}'
          .format(storm.date_start, storm.date_end, date_start, date_end, success),
          print_to_stdout = False)

    return success


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        Debug('Start {}'.format(__file__), print_to_stdout = False)
        #
        #storm     = globals__[ScriptParameterName.storm]
        #trackfile = globals__[ScriptParameterName.storm_trackfile]
        #
        #success = validate_record_storm_tracks(storm, trackfile)
        storm           = globals__[ScriptParameterName.storm]
        #input_dir       = globals__[ScriptParameterName.input_dir]
        #input_instances = globals__[ScriptParameterName.input_instances]
        input_instances_lists = globals__[ScriptParameterName.input_instances_lists]
        input_dir             = input_instances_lists[0].path
        input_instances       = input_instances_lists[0].files

        output_instances_list = globals__[ScriptParameterName.output_instances_list]
        output_dir            = output_instances_list.path
        output_instances      = output_instances_list.files

        Debug('Loaded global parameters:\n{}\n{}\n'.format(storm, output_dir, input_instances),
              print_to_stdout = False)

        if (len(input_instances) > 1):
            raise ScriptError('Expected only 1 input file for recording Storm tracks, but we '
                              'receieved the following {} files: {}\n'
                              .format(len(input_instances), '\n'.join(input_instances)))

        success = validate_record_storm_tracks(storm, os.path.join(output_dir, input_instances[0]))
        Debug('Validated the script: {}'.format('Success' if success else 'Failure'),
              print_to_stdout = False)

        globals__[ScriptParameterName.success] = success
        Debug('Completed script, returning now...', print_to_stdout = False)

    except ScriptError as error:
        Debug('ScriptError: {}'.format(error), print_to_stdout = True)
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except KeyError as error:
        Debug('KeyError: {}'.format(error), print_to_stdout = True)
        error = ScriptError('Undefined required GLOBAL variable "{}"'
                            .format(error))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except NameError as error:
        Debug('NameError: {}'.format(error), print_to_stdout = True)
        error = ScriptError('Undefined required LOCAL variable "{}"'.format(error))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except:
        error_type    = sys.exc_info()[0]
        error_message = sys.exc_info()[1]
        Debug('Unpredicted Error({}): {}'.format(error_type, error_message), print_to_stdout = True)
        error = ScriptError('Unexpected Error({}): "{}"'.format(error_type, error_message))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
