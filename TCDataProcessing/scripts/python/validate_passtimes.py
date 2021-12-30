import os
import sys

import backend.file_io                 as file_io
import backend.regex                   as regex
import script.python.extract_passtimes as extract_passtimes_script

from backend.debug import Debug
from script.utilities import ScriptParameterName, ScriptError

from django.conf import settings


## Updates the track records for the given storm.
#def validate_extract_passtimes(storm_filename_prefix, storage_dir, mission_sensor_map):
#    output_filename_pattern = (storm_filename_prefix + settings.PATHS.PASSTIMES_BASE_FILENAME)
#    passtime_files = file_io.listdir(storage_dir,
#                                     regex_pattern       = output_filename_pattern,
#                                     include_empty_files = False)
#    output_filename_pattern = output_filename_pattern.replace('.*', '{}').replace(r'\.', '.')
#    if (passtime_files == 0):
#        raise ScriptError('No extracted (non-empty) passtime files were found.')
#
#    not_found_satellites = []
#    total_sensor_count   = 0
#    for (mission, sensors) in mission_sensor_map.items():
#        total_sensor_count = (total_sensor_count + len(sensors))
#        for sensor in sensors:
#            if (output_filename_pattern.format(mission, sensor) not in passtime_files):
#                not_found_satellites.append('{} => {}'.format(mission, sensor))
#
#    if (len(not_found_satellites) == total_sensor_count):
#        raise ScriptError('No passtimes were found for the given storm!')
#    elif (len(not_found_satellites) != 0):
#        Debug('WARNING: the following satellites did not have a passtimes file:\n{}'
#              .format('\n'.join(not_found_satellites)),
#              print_to_stdout = True)
#
#    return True

# Updates the track records for the given storm.
def validate_extract_passtimes(storm,
                               storm_filename_prefix,
                               product_passtimes,
                               mission_sensor_map):
    # Create the regex pattern that the passtimes product files follow.
    output_filename_pattern = (  storm_filename_prefix
                               + settings.PATHS.PASSTIMES_BASE_FILENAME)
    # Get a list of all the passtimes for the given storm.
    passtime_files = file_io.listdir(product_passtimes.get_storage_path(storm = storm),
                                     regex_pattern       = output_filename_pattern,
                                     include_empty_files = False)
    # If we have no passtimes files, we already know there is a problem.
    if (passtime_files == 0):
        raise ScriptError('No extracted (non-empty) passtime files were found.')
    # Convert the regex pattern to a format string.
    output_filename_pattern = output_filename_pattern.replace('.*', '{}').replace(r'\.', '.')

    #####Debug('for sat_resource in product_passtimes.resources:', print_to_stdout = True)
    # Get a list of all the satellite images used to generate the passtimes.
    sat_images = []
    for sat_resource in product_passtimes.resources.all():
        sat_images += sat_resource.get_storage_instances_list(storm = storm)

    #####Debug('for (mission, sensors) in mission_sensor_map.items():', print_to_stdout = True)
    passtime_format_str = extract_passtimes_script.PASSTIME_FORMAT_STR
    # Create a list to track all sensors whose data is not found.
    not_found_satellites = []
    for (mission, sensors) in mission_sensor_map.items():
        #####Debug('for sensor in sensors:', print_to_stdout = True)
        for sensor in sensors:
            miss_sens_passtime_file = output_filename_pattern.format(mission, sensor)
            if (miss_sens_passtime_file not in passtime_files):
                not_found_satellites.append('{} => {}'.format(mission, sensor))
            else:
                # Pull the passtimes from the current mission-sensor passtimes file.
                stored_passtimes = []
                with open(os.path.join(product_passtimes.get_storage_path(storm = storm), miss_sens_passtime_file), 'rt') as passtime_file:
                    stored_passtimes = passtime_file.readlines()
                # Get the pattern of passtimes as they are written in the
                # satellite image filenames.
                sat_image_passtimes_pattern = extract_passtimes_script.sat_image_filename_regex(mission, sensor)
                # Iterate through the satellite images for the given storm.
                #####Debug('for sat_image in sat_images:', print_to_stdout = True)
                for sat_image in sat_images:
                    # Attempt to find the passtime for the current image,
                    # succeeding if the image is from the current mission-sensor.
                    regex_matches = regex.find_all(sat_image_passtimes_pattern, sat_image)
                    # If we got a match, the current image is from the current mission-sensor.
                    if (len(regex_matches) > 0):
                        # If the passtime extracted from the current image does
                        # not match any entry in the current passtimes file, we
                        # know this passtimes file wasn't created successfully.
                        if (       passtime_format_str.format(*(regex_matches[0]))
                            not in stored_passtimes):
                            raise ScriptError('The following passtime did not '
                                              'have a corresponding entry in '
                                              'passtimes file "{}": {}'
                                              .format(miss_sens_passtime_file,
                                                      regex_matches[0]))

    return True


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm                 = globals__[ScriptParameterName.storm]
        storm_filename_prefix = globals__[ScriptParameterName.storm_filename_prefix]
        mission_sensor_map    = globals__[ScriptParameterName.mission_sensor_map]
        product_passtimes     = globals__[ScriptParameterName.product]
        #storage_dir        = globals__[ScriptParameterName.input_dir]
        #input_instances    = globals__[ScriptParameterName.input_instances]
        input_instances_lists = globals__[ScriptParameterName.input_instances_lists]
        output_instances_list = globals__[ScriptParameterName.output_instances_list]
        #storage_dir           = globals__[ScriptParameterName.input_dir]
        #input_instances       = globals__[ScriptParameterName.input_instances]

        #storage_dir     = input_instances_lists[0].path
        #input_instances = input_instances_lists[0].files

        #passtimes = None
        #if ('passtimes.txt' in input_instances):
        #    passtimes = 'passtimes.txt'
        #elif ('passtimes_old.txt' in input_instances):
        #    passtimes = 'passtimes_old.txt'
        #else:
        #    raise ScriptError('No known passtimes file found for {Storm}'.format(Storm = storm))

        success = validate_extract_passtimes(storm,
                                             storm_filename_prefix,
                                             product_passtimes,
                                             mission_sensor_map)

        globals__[ScriptParameterName.success] = success

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
