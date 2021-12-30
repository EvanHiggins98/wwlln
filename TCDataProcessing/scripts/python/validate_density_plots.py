import sys

import backend.file_io as file_io
from backend.debug import Debug
from script.utilities import ScriptError, ScriptParameterName


# Updates the track records for the given storm.
def validate_density_plots(storm, output_dir, output_regex):
    storage_instances = file_io.listdir(output_dir,
                                        regex_pattern       = output_regex,
                                        include_empty_files = False)
    # Count the number of days this Storm existed in. Add one to account for
    # the start day.
    storm_days_count = ((storm.date_end - storm.date_start).days + 1)

    return (len(storage_instances) == storm_days_count)


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        storm        = globals__[ScriptParameterName.storm]
        #output_dir   = globals__[ScriptParameterName.output_dir]
        output_dir   = globals__[ScriptParameterName.output_instances_list].path
        output_regex = globals__[ScriptParameterName.output_regex]
        #Debug('Loaded global parameters:\n{}\n{}\n'
        #      .format(storm, output_dir, output_regex), print_to_stdout = False)

        success = validate_density_plots(storm, output_dir, output_regex)
        #Debug('Validated the script: {}'
        #      .format('Success' if success else 'Failure'),
        #      print_to_stdout = False)

        globals__[ScriptParameterName.success] = success
        #Debug('Completed script, returning now...', print_to_stdout = False)

    except ScriptError as error:
        Debug('ScriptError: '.format(error), print_to_stdout = True)
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except KeyError as error:
        Debug('KeyError: '.format(error), print_to_stdout = True)
        error = ScriptError('Undefined required GLOBAL variable "{}"'
                            .format(error))
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except NameError as error:
        Debug('NameError: '.format(error), print_to_stdout = True)
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
