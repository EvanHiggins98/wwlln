import os
import sys

from operator import itemgetter

import backend.regex as regex

from backend.debug import Debug
from script.utilities import ScriptParameterName, ScriptError

from django.conf import settings


def sat_image_filename_regex(satellite_mission):
    filename_regex = r'(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})\.'
    #filename_regex = r'(\d{8})\.(\d{4})\.([\w\d]+?)\.'
    return (filename_regex + satellite_mission + r'\..+?\.jpg')


# Updates the track records for the given storm.
#def extract_passtimes(storm, passtimes_filename, satellite_names):
def extract_passtimes(storm,
                      resources,
                      input_instances_lists,
                      output_dir,
                      output_filename_pattern,
                      mission_sensor_map):
    try:
        sensor_base_filename = os.path.join(output_dir, output_filename_pattern)

        for resource in resources:
            storage_path = resource.get_storage_path(storm)
            input_instances_list = None
            for temp_input_instances_list in input_instances_lists:
                if (storage_path == temp_input_instances_list.path):
                    input_instances_list = temp_input_instances_list
                    break
            name = resource.name.upper()
            # [ 0] YYYYMMDD
            # [ 1] HHMM
            # [ 2] Satellite Name
            #filename_regex = r'(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})\.'
            if (name == 'SSMIS'):
                mission = name
                sensors = mission_sensor_map[mission]
            else:
                for (temp_mission, temp_sensors) in mission_sensor_map.items():
                    if (name in temp_sensors):
                        mission = temp_mission
                        sensors = temp_sensors
                        break
            for sensor in sensors:
                if (name == 'SSMIS'):
                    satellite_mission = sensor
                else:
                    satellite_mission = mission

                #sat_passtimes = [(sat_image_filename[0], sat_image_filename[1], sat_image_filename[2])
                #                 for sat_image_filename in input_instances_list.files
                #                 if (regex.find(satellite_image_filename(satellite_mission), sat_image_filename) is not None)]
                sat_passtimes = []
                image_filename_regex = sat_image_filename_regex(satellite_mission.lower())
                for sat_image_filename in input_instances_list.files:
                    regex_matches = regex.find_all(image_filename_regex, sat_image_filename)
                    if (len(regex_matches) > 0):
                        regex_match = regex_matches[0]
                        #passtime_year  = regex_matches[0]
                        #passtime_month = regex_matches[1]
                        #passtime_day   = regex_matches[2]
                        #passtime_hour  = regex_matches[3]
                        #passtime_min   = regex_matches[4]
                        sat_passtimes.append((regex_match[0],
                                              regex_match[1],
                                              regex_match[2],
                                              regex_match[3],
                                              regex_match[4]))
                if (len(sat_passtimes) == 0):
                    continue
                sat_passtimes.sort(key = itemgetter(0, 1, 2, 3, 4))
                sensor_filename = sensor_base_filename.format(mission, sensor)
                with open(sensor_filename, 'wt') as sensor_file:
                    for passtime in sat_passtimes:
                        sensor_file.write('{}/{}/{}\t{}:{}:00\n'
                                          .format(passtime[0],
                                                  passtime[1],
                                                  passtime[2],
                                                  passtime[3],
                                                  passtime[4]))

    except IOError:
        Debug('Failed to create/open: "{}"'.format(sensor_filename))
        return False

    #passtimes_filename = os.path.join(input_dir, passtimes_filename)
    #Debug('Extracting relevant passtimes for {} from file: {}.'.format(storm, passtimes_filename),
    #      print_to_stdout = True)
    #try:
    #    with open(passtimes_filename, 'rt') as passtimes_file:
    #        # Extract each record of this storm from the track file.
    #        # [ 0] YYYY/MM/DD
    #        # [ 1] HH:MM:SS
    #        # [ 2] Satellite Name
    #        # [ 3] ???
    #        passtimes = [(passtime[0], passtime[1], passtime[2].replace('-', ''), passtime[3])
    #                     for passtime in regex.find_all('(\d+\/\d+\/\d+) *'
    #                                                    '(\d+:\d+:\d+) *'
    #                                                    '(\w+(?:\-[\w\d]+)?) *'
    #                                                    '(\d+)',
    #                                                    passtimes_file.read())]
    #        sensor_base_filename = os.path.join(output_dir, output_filename_pattern)
    #        for (mission, sensors) in mission_sensor_map.items():
    #            if (mission == 'SSMIS'):
    #                for sensor in sensors:
    #                    sensor_filename = sensor_base_filename.format(mission, sensor)
    #                    sat_passtimes = [(passtime[0], passtime[1], passtime[3])
    #                                      for passtime in passtimes
    #                                      if sensor in passtime[2]]
    #                    if (len(sat_passtimes) == 0):
    #                        continue
    #                    with open(sensor_filename, 'wt') as sensor_file:
    #                        for passtime in sat_passtimes:
    #                            sensor_file.write('{}\t{}\t{}\n'
    #                                              .format(passtime[0], passtime[1], passtime[2]))
    #            else:
    #                sensor_filename = sensor_base_filename.format(mission, sensors[0])
    #                sat_passtimes = [(passtime[0], passtime[1], passtime[3])
    #                                  for passtime in passtimes
    #                                  if mission in passtime[2]]
    #                if (len(sat_passtimes) == 0):
    #                    continue
    #                with open(sensor_filename, 'wt') as sensor_file:
    #                    for passtime in sat_passtimes:
    #                        sensor_file.write('{}\t{}\t{}\n'
    #                                          .format(passtime[0], passtime[1], passtime[2]))
    #        #        #
    #        #for satellite in satellite_names:
    #        #    passtimes_filename = satellite_base_filename.format(satellite)
    #        #    sat_passtimes = [(passtime[0], passtime[1], passtime[3])
    #        #                      for passtime in passtimes
    #        #                      if satellite in passtime[2]]
    #        #    if (len(sat_passtimes) == 0):
    #        #        continue
    #        #    with open(passtimes_filename, 'wt') as satellite_file:
    #        #        for passtime in sat_passtimes:
    #        #            satellite_file.write('{}\t{}\t{}\n'.format(passtime[0],
    #        #                                                       passtime[1],
    #        #                                                       passtime[2]))
    #except IOError:
    #    Debug('Failed to create/open: "{}"'.format(passtimes_filename))
    #    return False

    return True


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm              = globals__[ScriptParameterName.storm]
        s_prefix           = globals__[ScriptParameterName.storm_filename_prefix]
        mission_sensor_map = globals__[ScriptParameterName.mission_sensor_map]
        resources          = globals__[ScriptParameterName.resources]
        #input_dir       = globals__[ScriptParameterName.input_dir]
        #input_instances = globals__[ScriptParameterName.input_instances]
        input_instances_lists = globals__[ScriptParameterName.input_instances_lists]
        output_instances_list = globals__[ScriptParameterName.output_instances_list]
        #input_dir             = input_instances_lists[0].path
        #input_instances       = input_instances_lists[0].files

        output_filename_pattern = (  s_prefix
                                   + (settings.PATHS.PASSTIMES_BASE_FILENAME
                                      .replace('.*', '{}')
                                      .replace('\.', '.')))

        #passtimes = None
        #if ('passtimes.txt.part' in input_instances):
        #    passtimes = 'passtimes.txt.part'
        #elif ('passtimes_old.txt.part' in input_instances):
        #    passtimes = 'passtimes_old.txt.part'
        #else:
        #    raise ScriptError('No known passtimes file found for {Storm}'.format(Storm = storm))

        success = extract_passtimes(storm,
                                    resources,
                                    input_instances_lists,
                                    output_instances_list.path,
                                    output_filename_pattern,
                                    mission_sensor_map)

        globals__[ScriptParameterName.success] = success

    except ScriptError as error:
        Debug('ScriptError: {}'.format(error), print_to_stdout = True)
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except KeyError as error:
        Debug('KeyError: {}'.format(error), print_to_stdout = True)
        error = ScriptError('Undefined required GLOBAL variable "{}"'.format(error))
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
