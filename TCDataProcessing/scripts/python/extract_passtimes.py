import os
import sys

from operator import itemgetter

import re

from django.conf import settings


PASSTIME_FORMAT_STR = '{}/{}/{}\t{}:{}:00\n'


def sat_image_filename_regex(mission, sensor):
    filename_regex = r'(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})\.'
    #filename_regex = r'(\d{8})\.(\d{4})\.([\w\d]+?)\.'
    return (  filename_regex
            + '(?:{}|{})'.format(mission.lower(), sensor.lower())
            + r'\..+?\.jpg')


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
                #Debug('temp_input_instances_list({})'.format(temp_input_instances_list),
                #      print_to_stdout = True)
                if (storage_path == temp_input_instances_list.path):
                    input_instances_list = temp_input_instances_list
                    break

            ### NEW: Jan. 2020
            # If the directory for the current resource is empty/non-existent, skip it.
            if (input_instances_list.files is None):
                continue
            ### NEW

            for (mission, sensors) in mission_sensor_map.items():
                #Debug('Mission({})'.format(mission), print_to_stdout = True)
                for sensor in sensors:
                    #Debug('Sensor({})'.format(sensor), print_to_stdout = True)
                    sat_passtimes = []
                    image_filename_regex = sat_image_filename_regex(mission, sensor)
                    for sat_image_filename in input_instances_list.files:
                        #Debug('sat_image_filename({})'.format(sat_image_filename), print_to_stdout = True)
                        regex_matches = re.findall(re.compile(image_filename_regex), sat_image_filename)
                        if (len(regex_matches) > 0):
                            regex_match = regex_matches[0]
                            #passtime_year  = regex_matches[0]
                            #passtime_month = regex_matches[1]
                            #passtime_day   = regex_matches[2]
                            #passtime_hour  = regex_matches[3]
                            #passtime_min   = regex_matches[4]
                            sat_passtimes.append(regex_match)
                    if (len(sat_passtimes) == 0):
                        continue
                    sat_passtimes.sort(key = itemgetter(0, 1, 2, 3, 4))
                    sensor_filename = sensor_base_filename.format(mission, sensor)
                    with open(sensor_filename, 'wt') as sensor_file:
                        for passtime in sat_passtimes:
                            sensor_file.write(PASSTIME_FORMAT_STR.format(*passtime))

    except IOError:
        print('Failed to create/open: "{}"'.format(sensor_filename))
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
        storm              = globals__['storm']
        s_prefix           = globals__['storm_filename_prefix']
        mission_sensor_map = globals__['mission_sensor_map']
        resources          = globals__['resources']
        #input_dir       = globals__[ScriptParameterName.input_dir]
        #input_instances = globals__[ScriptParameterName.input_instances]
        input_instances_lists = globals__['input_instances_lists']
        output_instances_list = globals__['output_instances_list']
        #input_dir             = input_instances_lists[0].path
        #input_instances       = input_instances_lists[0].files

        output_filename_pattern = (  s_prefix
                                   + ((r'.*_.*_Passtimes\.txt')
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

        globals__['success'] = success

    except KeyError as error:
        print('KeyError: {}'.format(error))
        error = 'Undefined required GLOBAL variable "{}"'.format(error)
        globals__['success'] = False
        globals__['error']   = error
    except NameError as error:
        print('NameError: {}'.format(error),)
        error ='Undefined required LOCAL variable "{}"'.format(error)
        globals__['success'] = False
        globals__['error']   = error
    except:
        error_type    = sys.exc_info()[0]
        error_message = sys.exc_info()[1]
        print('Unpredicted Error({}): {}'.format(error_type, error_message))
        error = 'Unexpected Error({}): "{}"'.format(error_type, error_message)
        globals__['success'] = False
        globals__['error']   = error
