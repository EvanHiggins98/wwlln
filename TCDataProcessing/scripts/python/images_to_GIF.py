import os
import re
import sys

from django.conf import settings

from backend.debug import Debug
from script.utilities import ScriptError, ScriptParameterName


################################################################################
## @fn def create_gif_script_header(product, storm):
#
#  @brief
#
#  @param
#
#  @return
#    None
################################################################################
def create_gif_script_header(output_name, input_path, output_path = None):
    Debug('Writing the JPEGtoGIF script header for GIF: {}'.format(output_name))
    if (output_path is None):
        output_path = input_path

    regex_str = re.compile(r'.*\.(?:jpg|jpeg|jpe|jif|jfif|jfi)$')

    input_images = [image
                    for image in os.listdir(input_path)
                    if (re.search(regex_str, image) is not None)]
    input_images.sort()
    Debug('Converting the following images to a GIF:\n{}'
          .format('    \n'.join([image for image in input_images])))

    # Attempt to create or open the JPEGtoGIFheader.m file.
    script_header_filename = 'JPEGtoGIFheader.m'
    try:
        # Create the filename/file path as per the host system.
        script_header_filename = os.path.join(settings.PATHS.MATLAB_SCRIPTS,
                                              script_header_filename)
        # Create/open the file.
        Debug('Creating/opening: "{}"'.format(script_header_filename))
        # Write the contents of the JPEGtoGIFheader.m file.
        with open(script_header_filename, 'wt') as header:
            header.write('jpegInputFiles = {{{}}};\n\n'
                         .format(',\n'.join(["'{}'".format(jpeg)
                                             for jpeg in input_images])))
            header.write("gifOutputFilename = '{}.gif';\n\n"
                         .format(output_name))
            header.write("cd('{}');".format(output_path))
    except IOError:
        Debug('Failed to create/open: "{}"'.format(script_header_filename))


if (__name__ == '__main__'):
    globals__ = globals()

    try:
        #output_dir  = globals__[ScriptParameterName.output_dir]
        output_dir  = globals__[ScriptParameterName.output_instances_list].path
        product     = globals__[ScriptParameterName.product]
        output_name = globals__[ScriptParameterName.output_regex]

        output_name = output_name.replace('.*', product.title)
        output_name = output_name.replace(' ', '_')

        ##### March, 2017 -- Connor Bracy
        # Currently, JPEG to GIF assumes the input files are in the same
        # directory that the output file should be in. There is a thought to
        # change this in the future by making the GIFS a separate product, that
        # way they could be defined to use a subset of the files in a certain
        # location (via the Resource regex for the Product) and they could be
        # placed into a new folder, but this would require adding a concept
        # along the lines of ProductGroup which groups together a set of
        # products to be displayed on the website so that the GIFs could be
        # associated with and placed in the same separator as their source
        # files. This wouldn't be a terrible amount of effort to do, but it
        # seems unnecessary at this point and it will take more time than I
        # have to spare.
        #####
        create_gif_script_header(output_name, output_dir, output_dir)

    except ScriptError as error:
        globals__[ScriptParameterName.success] = False
        globals__[ScriptParameterName.error]   = error
    except NameError as error:
        error = ScriptError('Undefined required variable "{}"'.format(error))
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
