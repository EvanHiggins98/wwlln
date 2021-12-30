import os
import script.python.record_storm_tracks as record_storm_tracks

from data.models  import Resource
from storm.models import Storm

from django.test import TestCase


class RecordTracksTestCase(TestCase):
    # Load a set of sample Storms into the test database along with the current
    # set of source/resources.
    fixtures = ['storm.json', 'source.json', 'resource.json']

    @classmethod
    def setUpTestData(cls):
        cls.storm = Storm.objects.all()[0]
        cls.resource = Resource.objects.get(filename_regex = 'trackfile.txt')
        cls.storage_path = cls.resource.get_storage_path(cls.storm)

    def record_tracks(self):
        print('')
        trackfile = os.path.join(self.storage_path,
                                 self.resource.filename_regex)
        record_storm_tracks.record_storm_tracks(self.storm, trackfile)
        tracks = self.storm.stormtrack_set.all()
        with open(trackfile, 'rt') as f:
            # Print out a copy of each track record, one from the trackfile and
            # the other from the record in the database, so that they can be
            # visually compared to be consistent.
            i = 0
            for (i, track) in enumerate(f):
                print('Trackfile:   {}'
                      'Trackrecord: {Track.time} {Track.latitude} '
                                   '{Track.longitude} {Track.wind_speed} '
                                   '{Track.pressure}\n'
                      .format(track, Track = tracks[i]))
            # Make sure there are the same number of track records in the
            # trackfile as there are track records loaded into the database.
            self.assertEqual(len(tracks), (i + 1))

    def create_reduced_trackfile(self):
        record_storm_tracks.create_reduced_trackfile(self.storm,
                                                     self.storage_path)
        reduced_track = os.path.join(self.storage_path,
                                     '{}_track.txt'.format(self.storm.name))
        self.assertTrue(os.path.isfile(reduced_track))

    def test_trackfile(self):
        self.record_tracks()
        self.create_reduced_trackfile()
