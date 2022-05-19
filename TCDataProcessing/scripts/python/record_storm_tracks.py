import os
import sys

import re

from django.utils  import timezone


# Updates the track records for the given storm.
def record_storm_tracks(storm, trackfile_filename):
    print('Copying track records for {} to the database.'.format(storm))
    try:
        with open(trackfile_filename, 'rt') as track_records:
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
            tracks = re.findall(re.compile('(\d{2}.)\s+(\w+(?:-\w+)?)\s+(\d{2})(\d{2})'
                                    '(\d{2})\s+(\d{2})(\d{2})\s+(\d+\.\d+)(\w)'
                                    '\s+(\d+\.\d+)(\w)\s+(\w+)\s+(\d+)\s+(\d+)'),
                                    track_records.read())
    except IOError:
        print('Failed to create/open: "{}"'.format(trackfile_filename))
        return False

    # The Navy edits their track files (removing/modifying some tracks in
    # addition to adding new ones) due to better data resulting from processing
    # on the existing data. We always want to use the most up-to-date data as
    # it is the most accurate so each time we record the storm tracks into the
    # database, do so with a fresh start.
    #storm.reset_database_data()

    # Loop through each track we found
    for track in tracks:
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

        # The Navy often duplicates lines in the trackfile so if this timestamp
        # already exists in the database, move to the next one.
        #if (storm.stormtrack_set.filter(time = time).exists()):
            #continue

        wind_speed = int(track[12])
        pressure   = int(track[13])
        # Center the coordinates about the intersection of The Prime Meridian
        # and the Equator, with the northern and eastern hemispheres being
        # positive valued and the southern and western hemispheres being
        # negatively valued with respect to this interseciton point.
        lat = float(track[7])
        lon = float(track[9])
        if (track[ 8] == 'S'):
            lat = -lat
        if (track[10] == 'W'):
            lon = -lon

        # Get the date of the track record
        track_record_date = time.date()
        # If this track record is more recent than the last known final record
        # for this storm, update that.
        if (storm.date_end < track_record_date):
            storm.date_end = track_record_date
        # Otherwise, check if the loaded track record predates the currently
        # known start date for the storm, and if it does update that.
        elif (storm.date_start > track_record_date):
            storm.date_start = track_record_date

        # storm.stormtrack_set.create(time       = time,
        #                             latitude   = lat,
        #                             longitude  = lon,
        #                             wind_speed = wind_speed,
        #                             pressure   = pressure)
    # End: Forall (track records)

    storm.save()

    return True


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm           = globals__['storm']
        #input_dir       = globals__[ScriptParameterName.input_dir]
        #input_instances = globals__[ScriptParameterName.input_instances]
        input_instances_lists = globals__['input_instances_lists']
        input_dir             = input_instances_lists[0].path
        input_instances       = input_instances_lists[0].files

        if (len(input_instances) > 1):
            print('Expected only 1 input file for recording Storm tracks, but we '
                              'receieved the following {} files: {}\n'
                              .format(len(input_instances), '\n'.join(input_instances)))
            raise

        success = record_storm_tracks(storm, os.path.join(input_dir, input_instances[0]))

        globals__[success] = success

    except KeyError as error:
        print('KeyError: {}'.format(error))
        error = KeyError('Undefined required GLOBAL variable "{}"'.format(error))
        globals__['success'] = False
        globals__[error]   = error
    except NameError as error:
        print('NameError: {}'.format(error))
        error = NameError('Undefined required LOCAL variable "{}"'.format(error))
        globals__['success'] = False
        globals__[error]   = error
    except:
        error_type    = sys.exc_info()[0]
        error_message = sys.exc_info()[1]
        print('Unpredicted Error({}): {}'.format(error_type, error_message))
        error = ('Unexpected Error({}): "{}"'.format(error_type, error_message))
        globals__['success'] = False
        globals__[error]   = error
