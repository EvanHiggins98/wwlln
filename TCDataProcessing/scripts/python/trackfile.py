from django.utils  import timezone
import wwlln.scripts.file_io as file_io
import re
from operator import attrgetter

class TrackEntry:
    def __init__(self, 
                id = 'NNE',
                name = '',
                time = timezone.datetime(year   = 2000,
                                        month  = 1,
                                        day    = 1,
                                        hour   = 0,
                                        minute = 0,
                                        tzinfo = timezone.utc),
                lat = 0,
                lon = 0,
                region = '',
                wind = 0,
                press = 0):  
            self.id = id
            self.name = name
            self.time = time
            self.lat = lat
            self.lon = lon
            self.region = region
            self.press = press
            self.wind = wind

    def __repr__(self):
        return 'TrackEntry()'
    
    def __str__(self):
        return ('{id}\t{name}\t{time.year}\t{time.month}\t'
                '{time.day}\t{time.hour}\t{lat}\t{lon}\t{press}\t{wind}\n'
                .format(id = self.id, name = self.name, time = self.time,
                        lat = self.lat, lon = self.lon, region = self.region, 
                        press = self.press ,wind = self.wind))

    def __eq__(self, __o: object) -> bool:
        if isinstance(__o, self.__class__):
            return (self.id == __o.id and
                    self.name == __o.name and
                    self.time == __o.time and
                    self.lat == __o.lat and
                    self.lon == __o.lon and
                    self.region == __o.region and
                    self.press == __o.press and
                    self.wind == __o.wind)
    
    def __key(self):
        return (self.id, self.name, self.time, self.lat,  self.lon,
                 self.region, self.press, self.wind)

    def __hash__(self):
        return hash(self.__key())

class TrackFile:
    def __init__(self, tracks=[]):
        self.tracks = list(dict.fromkeys(tracks))
    
    def add(self, track):
        if isinstance(track,TrackEntry) and not track in self.tracks:
            self.tracks.insert(0,track)
        elif isinstance(track, list):
            if isinstance(track[0],TrackEntry):
                for entry in list:
                    self.add(entry)
            else:
                raise ValueError('Unable to append list of given track types')
        else:
            raise ValueError('Unable to append track of given type')

    def parseNavyTrackFile(self, path=''):
        if path:
            #start file input
            try:
                with open(path, 'rt') as track_records:
                    navy_trackfile_re = re.compile('(\d{2}.)\s+(\w+(?:-\w+)?)\s+(\d{2})(\d{2})'
                                            '(\d{2})\s+(\d{2})(\d{2})\s+(\d+\.\d+)(\w)'
                                            '\s+(\d+\.\d+)(\w)\s+(\w+)\s+(\d+)\s+(\d+)')
                    track_records = re.findall(navy_trackfile_re, track_records.read())
            except IOError:
                print('Failed to create/open: "{}"'.format(path))
                return False
            #end file input
            for track in track_records:
                year = max(int(track[2]),2000+int(track[2]))
                time = timezone.datetime(year   = year,
                                    month  = int(track[3]),
                                    day    = int(track[4]),
                                    hour   = int(track[5]),
                                    minute = int(track[6]),
                                    tzinfo=timezone.utc)
                
                wind_speed = int(track[12])
                pressure   = int(track[13])
                lat = float(track[7])
                lon = float(track[9])
                if (track[ 8] == 'S'):
                    lat = -lat
                if (track[10] == 'W'):
                    lon = -lon
                newTrack = TrackEntry(track[0],track[1],time,lat,lon,track[11],wind_speed,pressure)
                self.add(newTrack)
                
            return self
        else:
            raise ValueError('No navy track file given')
    
    def toReducedTrackFile(self, output_path=''):
        try:
            with open(output_path, 'wt') as output:
                for track in self.tracks:
                    output.write('{date_time.year}\t{date_time.month}\t'
                                  '{date_time.day}\t{date_time.hour}\t'
                                  '{TLat}\t{TLon}\t{TPress}\t{TWind}\t0\n'
                                  .format(date_time = track.time,
                                          TLat      = track.lat,
                                          TLon      = track.lon,
                                          TPress    = track.press,
                                          TWind     = track.wind))
            return self
        except IOError:
            print('Failed to create/open: "{}"'.format(output_path))
    
    def get_start_date(self):
        return min(self.tracks, key=attrgetter('time')).time
    
    def get_end_date(self):
        return max(self.tracks, key=attrgetter('time')).time
    
    def get_time_frame(self):
        return (self.get_start_date,self.get_end_date)
    
    def get_storm_num(self):
        return int(self.tracks[0].id[2])
    
    def get_storm_name(self):
        return self.tracks[0].name
        
def navyToReduced(input_path, output_path=''):
    trackfile = TrackFile()
    if not output_path:
        output_path = input_path[:input_path.rfind('.')] + "_reduced.txt"
    trackfile.parseNavyTrackFile(input_path).toReducedTrackFile(output_path)
    return output_path

    