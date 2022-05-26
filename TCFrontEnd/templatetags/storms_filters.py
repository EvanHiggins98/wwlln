import os
import re
import sys

import wwlln.scripts.file_io as file_io

from django import template
from django.conf import settings


register = template.Library()


@register.filter()
def mylower(value):
    return value.lower()


@register.simple_tag(name='get_images')
def get_images(storm, script):
    image_dir = os.path.join(storm.local_subdir_processed_data(),
                             str(script.id))
    if (os.path.isdir(image_dir)):
        return os.listdir(image_dir)['dirs']
    else:
        return None


def get_image_columns(images):
    num_cols_per_row  = 12

    images_per_row_xs = 2
    images_per_row_sm = 3
    images_per_row_md = 6
    images_per_row_lg = 12

    image_count = len(images)

    if (image_count < images_per_row_md):
        images_per_row_md = images_per_row_sm
        images_per_row_lg = images_per_row_sm
    elif (image_count < images_per_row_lg):
        images_per_row_lg = images_per_row_md

    return ('col-xs-{xs} col-sm-{sm} col-md-{md} col-lg-{lg}'
            .format(xs = int(num_cols_per_row / images_per_row_xs),
                    sm = int(num_cols_per_row / images_per_row_sm),
                    md = int(num_cols_per_row / images_per_row_md),
                    lg = int(num_cols_per_row / images_per_row_lg)))


@register.inclusion_tag('TCFrontEnd/script_panel.html', name='script_panel')
def script_panel(storm, script):
    # Get the directory for the given script's output for the given storm.
    image_dir = os.path.join(storm.local_subdir_processed_data(),
                             script.source_subdir)
    NO_DISPLAY = { 'has_images': False }
    # Make sure the directory exists.
    if (os.path.isdir(image_dir)):
        # Compile the pattern to look for GIF images.
        gif_pattern = re.compile(r'.*\.gif')
        # Declare a list for storing any GIF or other images separately.
        gifs   = []
        images = []
        # Get the list of images in the directory.
        image_list = os.listdir(image_dir)['dirs']
        if (len(image_list) == 0):
            return NO_DISPLAY
        image_list.sort()
        # Loop through each image in the directory.
        for image in image_list:
            # Get the path to the image.
            image_path = os.path.join(settings.PATHS.REL_PROCESSED_DATA,
                                      storm.local_subdir(),
                                      script.source_subdir,
                                      image)

            # Add the image to the proper list.
            if (gif_pattern.fullmatch(image) is None):
                images.append(image_path)
            else:
                gifs.append(image_path)
        # Pass the image info to the template fragment to be rendered and
        # returned to the calling template.
        return { 'has_images': True,
                 'panel_id':   ('collapse-group-{}'.format(script.id)),
                 'script':     script,
                 'gifs':       gifs,
                 'images':     images,
                 'columns':    get_image_columns(images) }
    # If the directory doesn't exist, render nothing.
    else:
        return NO_DISPLAY


@register.inclusion_tag('TCFrontEnd/product_panel.html', name='product_panel')
def product_panel(storm, product):
    product_dir = product.get_relative_storage_path(storm)
    NO_DISPLAY = { 'has_images': False }
    # Make sure the directory exists.
    print(product_dir)
    if (os.path.isdir(product_dir)):
        ## Compile the pattern to look for GIF images.
        #gif_pattern = re.compile(r'.*\.gif')
        ## Declare a list for storing any GIF or other products separately.
        #gifs   = []
        #images = []
        ## Get the list of image instances in the directory.
        #image_list = os.listdir(product_dir)
        ## Most images are named according to a date/time scheme so sort them
        ## by name to give them some sort of organization.
        #image_list.sort()
        #rel_product_path = os.path.join(settings.PATHS.REL_PROCESSED_DATA,
        #                                storm.local_subdir(),
        #                                product.storage_subdir)
        ## Loop through each image in the directory.
        #for image in image_list:
        #    # Get the path to the image.
        #    image_path = os.path.join(rel_product_path, image)
        #    # Add the image to the proper list.
        #    # TODO: add filtering to make sure there are only image products
        #    #       loaded into the images list (i.e. no .txt, .mat, etc. files)
        #    if (gif_pattern.fullmatch(image) is None):
        #        images.append(image_path)
        #    else:
        #        gifs.append(image_path)
        images = file_io.listdir(product_dir)['dirs']
        gifs   = file_io.listdir(product_dir, r'.*\.gif$')['dirs']
        # If we have more than one GIF, just include them in the total set of
        # images to show.
        if (len(gifs) > 1):
            gifs = []
        # Otherwise, if we have one or no GIF's, remove it from the rest of the
        # images so that it can be put in the panel tab.
        else:
            images = list(set(images) - set(gifs))
        # Most images are named according to a date/time scheme so sort them
        # by name to give them some sort of organization.
        images.sort()
        rel_product_path = product.get_storage_path(storm = storm)
        # rel_product_path = os.path.join(settings.PATHS.REL_PROCESSED_DATA,
        #                                 storm.local_subdir(),
        #                                 product.storage_subdir)
        
        images = [file_io.create_path(rel_product_path, image.name) for image in images]
        gifs   = [file_io.create_path(rel_product_path, gif.name)   for gif   in gifs]

        # If we didn't find any images, return NO_DISPLAY.
        if ((len(gifs) == 0) and (len(images) == 0)):
            return NO_DISPLAY
        # Pass the image info to the template fragment to be rendered and
        # returned to the calling template.
        return { 'has_images': True,
                 'panel_id':   ('collapse-group-{}'.format(product.id)),
                 'product':    product,
                 'gifs':       gifs,
                 'images':     images,
                 'columns':    get_image_columns(images) }
    # If the directory doesn't exist, render nothing.
    else:
        return NO_DISPLAY


@register.inclusion_tag('storms/product_carousel.html', name='product_carousel')
def product_carousel(storm, product):
    product_dir = product.get_storage_path(storm)
    NO_DISPLAY = { 'has_images': False }
    # Make sure the directory exists.a
    if (os.path.isdir(product_dir)):
        # Compile the pattern to look for GIF images.
        gif_pattern = re.compile(r'.*\.gif')
        # Declare a list for storing any GIF or other products separately.
        gifs   = []
        images = []
        # Get the list of image instances in the directory.
        image_list = os.listdir(product_dir)['dirs']
        # Most images are named according to a date/time scheme so sort them
        # by name to give them some sort of organization.
        image_list.sort()
        rel_product_path = os.path.join(settings.PATHS.REL_PROCESSED_DATA,
                                        storm.local_subdir(),
                                        product.storage_subdir)
        # Loop through each image in the directory.
        for image in image_list:
            # Get the path to the image.
            image_path = os.path.join(rel_product_path, image)
            # Add the image to the proper list.
            # TODO: add filtering to make sure there are only image products
            #       loaded into the images list (i.e. no .txt, .mat, etc. files)
            if (gif_pattern.fullmatch(image) is None):
                images.append(image_path)
            else:
                gifs.append(image_path)
        # If we didn't find any images, return NO_DISPLAY.
        if ((len(gifs) == 0) and (len(images) == 0)):
            return NO_DISPLAY
        for i in images:
            print(i, file=sys.stderr)
        # Pass the image info to the template fragment to be rendered and
        # returned to the calling template.
        return { 'has_images': True,
                 'panel_id':   ('collapse-group-{}'.format(product.id)),
                 'product':    product,
                 'gifs':       gifs,
                 'images':     images,
                 'columns':    get_image_columns(images) }
    # If the directory doesn't exist, render nothing.
    else:
        return NO_DISPLAY
