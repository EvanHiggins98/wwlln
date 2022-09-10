from TCDataProcessing.scripts.scriptEngine import run_matlab_script
from TCDataProcessing.scripts.python import trackfile
import wwlln.scripts.file_io as file_io
from TCDataCollection.models import Resource
from TCDataProcessing.models import Storm, Sensor

def P_DensityPlot(storm, resources, output_path):
    #wwlln_path, output_filename=''
    storm_name = storm.name
    sensors = Sensor.objects.all()
    for resource in resources:
        for sensor in sensors:
            dir = resource.collect(storm=storm, mission=sensor.mission, sensor=sensor)
            if not dir:
                continue
            if resource.name == 'trackfile':
                trackfile_path = file_io.create_path(dir,'trackfile.txt')
            elif resource.name == 'locations':
                wwlln_path = file_io.create_path(dir, '')
    reduced_track = trackfile.navyToReduced(trackfile_path)
    
    if not output_path:
        output_path = str(file_io.get_parent(trackfile_path))
    if not output_filename:
        output_filename = "Density_Plot.jpg"
    if not storm_name:
        storm_name = "NO_NAME"
    
    run_matlab_script('CyclonePlot_Density','r"{}", r"{}", r"{}", r"{}", r"{}"'.format(reduced_track, wwlln_path, output_path, storm_name, output_filename))