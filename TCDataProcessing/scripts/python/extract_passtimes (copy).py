import os
import sys

import backend.regex as regex

from backend.debug import Debug
from script.utilities import ScriptParameterName, ScriptError

from django.conf import settings


# Updates the track records for the given storm.
#def extract_passtimes(storm, passtimes_filename, satellite_names):
def extract_passtimes(storm,
                      input_dir,
                      output_dir,
                      passtimes_filename,
                      output_filename_pattern,
                      mission_sensor_map):
    passtimes_filename = os.path.join(input_dir, passtimes_filename)
    Debug('Extracting relevant passtimes for {} from file: {}.'
          .format(storm, passtimes_filename),
          print_to_stdout = True)
    try:
        with open(passtimes_filename, 'rt') as passtimes_file:
            # Extract each record of this storm from the track file.
            # [ 0] YYYY/MM/DD
            # [ 1] HH:MM:SS
            # [ 2] Satellite Name
            # [ 3] ???
            passtimes = [(passtime[0],
                          passtime[1],
                          passtime[2].replace('-', ''),
                          passtime[3])
                         for passtime in regex.find_all('(\d+\/\d+\/\d+) *'
                                                        '(\d+:\d+:\d+) *'
                                                        '(\w+(?:\-[\w\d]+)?) *'
                                                        '(\d+)',
                                                        passtimes_file.read())]
            sensor_base_filename = os.path.join(output_dir,
                                                output_filename_pattern)
            for (mission, sensors) in mission_sensor_map.items():
                if (mission == 'SSMIS'):
                    for sensor in sensors:
                        sensor_filename = sensor_base_filename.format(mission,
                                                                         sensor)
                        sat_passtimes = [(passtime[0], passtime[1], passtime[3])
                                          for passtime in passtimes
                                          if sensor in passtime[2]]
                        if (len(sat_passtimes) == 0):
                            continue
                        with open(sensor_filename, 'wt') as sensor_file:
                            for passtime in sat_passtimes:
                                sensor_file.write('{}\t{}\t{}\n'
                                                  .format(passtime[0],
                                                          passtime[1],
                                                          passtime[2]))
                else:
                    sensor_filename = sensor_base_filename.format(mission,
                                                                  sensors[0])
                    sat_passtimes = [(passtime[0], passtime[1], passtime[3])
                                      for passtime in passtimes
                                      if mission in passtime[2]]
                    if (len(sat_passtimes) == 0):
                        continue
                    with open(sensor_filename, 'wt') as sensor_file:
                        for passtime in sat_passtimes:
                            sensor_file.write('{}\t{}\t{}\n'
                                              .format(passtime[0],
                                                      passtime[1],
                                                      passtime[2]))
            #        #
            #for satellite in satellite_names:
            #    passtimes_filename = satellite_base_filename.format(satellite)
            #    sat_passtimes = [(passtime[0], passtime[1], passtime[3])
            #                      for passtime in passtimes
            #                      if satellite in passtime[2]]
            #    if (len(sat_passtimes) == 0):
            #        continue
            #    with open(passtimes_filename, 'wt') as satellite_file:
            #        for passtime in sat_passtimes:
            #            satellite_file.write('{}\t{}\t{}\n'.format(passtime[0],
            #                                                       passtime[1],
            #                                                       passtime[2]))
    except IOError:
        Debug('Failed to create/open: "{}"'.format(passtimes_filename))
        return False

    return True


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm              = globals__[ScriptParameterName.storm]
        s_prefix           = globals__[
            ScriptParameterName.storm_filename_prefix]
        mission_sensor_map = globals__[ScriptParameterName.mission_sensor_map]
        input_dir          = globals__[ScriptParameterName.input_dir]
        input_instances    = globals__[ScriptParameterName.input_instances]

        output_filename_pattern = (  s_prefix
                                   + (settings.PATHS.PASSTIMES_BASE_FILENAME
                                      .replace('.*', '{}')
                                      .replace('\.', '.')))

        passtimes = None
        if ('passtimes.txt.part' in input_instances):
            passtimes = 'passtimes.txt.part'
        elif ('passtimes_old.txt.part' in input_instances):
            passtimes = 'passtimes_old.txt.part'
        else:
            raise ScriptError('No known passtimes file found for {Storm}'
                              .format(Storm = storm))

        success = extract_passtimes(storm,
                                    input_dir,
                                    input_dir,
                                    passtimes,
                                    output_filename_pattern,
                                    mission_sensor_map)

        globals__[ScriptParameterName.success] = success

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
