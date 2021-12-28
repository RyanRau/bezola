import re
import json
import requests
import traceback
from bs4 import BeautifulSoup
from urllib.parse import quote

#region Exception Lists
ARTIST_EXCEPTIONS = {
    'N.W.A.': 'N.W.A',
    'The Ponderosa Twins Plus One': 'Ponderosa Twins Plus One'
}
#endregion


#region Object Classes
class SampleData:
    def __init__(self, samples, sampled_by, isError=False) -> None:
        self.samples = samples
        self.sampled_by = sampled_by

class Song:
    def __init__(self, track, artist, year, albumURL) -> None:
        self.track = track
        self.artist = artist
        self.year = year
        self.albumURL = albumURL

#endregion


#region Scraper
class WhoSampledScraper:
    BASE_URL = 'https://www.whosampled.com'
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36',
    }


    def __init__(self, artist, track) -> None:
        self.URL = self.build_url(artist, track)
        
    def build_url(self, artist, track) -> str:
        if artist in ARTIST_EXCEPTIONS:
            artist = ARTIST_EXCEPTIONS[artist]
        
        # TODO: Can probably be cleaned up/optimized; regex?
        # Clean track in cases such as 'track - remastered', 'track (feat. artist)'
        track = track.lower()
        dirty_identifiers = ['-', 'remaster', 'remastered', 'feat', 'remix', '(with', 'ft.', 'radio edit']
        if any(dirty in track for dirty in dirty_identifiers):
            track_split = track.split(' ')
            dirty_indexes = [i for i in range(len(track_split)) if any(dirty in track_split[i] for dirty in dirty_identifiers)]
            track = ' '.join(track_split[:dirty_indexes[0]])

        url = '{}/{}/{}/'.format(self.BASE_URL, artist.replace(' ', '-'), track.replace(' ', '-'))
        url = quote(url, safe='/:?=&()')
        
        print(url)
        return url


    def get_all_samples(self) -> SampleData:
        '''
        Returns:
            (samples, sampled by): returns tuple of songs which the requested song samples along with songs which sample it
        '''
        return SampleData(self.get_samples(), self.get_samples(sampled_by=True))


    def get_samples(self, sampled_by=False, use_suffix=True) -> list: 
        '''
        Defaultly gets songs which requested song samples

        Args:
            sampled_by: set to true if you want songs which samples the requested song (default=False)
        Returns:
            songs: List of Song objects
        '''
        url_suffix = ('', ('samples/', 'sampled/')[sampled_by])[use_suffix]
        section_str = ('contains samples', 'was sampled')[sampled_by]
        
        try:
            page = requests.get('{}{}'.format(self.URL, url_suffix), headers=self.HEADERS)

            if page.status_code == 404 and use_suffix == True:
                return self.get_samples(sampled_by=sampled_by, use_suffix=False)

            soup = BeautifulSoup(page.content, 'html.parser')

            section = None
            for t in soup.find_all('span', class_='section-header-title'):
                if section_str in t.contents[0].lower():
                    section = t.parent.parent
                    continue

            if section is None:
                return []

            samples = self.get_songs_from_section(section)
            
            return samples
        except:
            traceback.print_exc()
            return []
        

    def get_songs_from_section(self, section) -> list:
        '''
        Parses out sample entry html to song objects

        Args:
            section: bs4 section which contains sample entries to be parsed out
        Returns:
            songs: List of Song objects parsed from sample entries
        '''
        
        songs = []
        errors = []
        for song in section.find_all('div', class_='sampleEntry'):
            try:
                details = song.find_all('div', class_='trackDetails')[0]
                img = song.find_all('img')[0]['src']

                songs.append(Song(
                    track=details.find_all('a', class_='trackName')[0].contents[0],
                    artist=details.find_all('span', class_='trackArtist')[0].find_all('a')[0].contents[0],
                    year=re.findall(r"[0-9]{4,7}", details.find_all('span', class_='trackArtist')[0].contents[-1])[0],
                    albumURL=self.BASE_URL + img
                ))
            except:
                traceback.print_exc()
                errors.append(song)
                break
        
        return songs
#endregion


#region Static methods
def ping(): # Used as sanity check when used in swifts PythonKit
    print("pong")


def get_known(): # Used as sanity check when used in swifts PythonKit
    return get_data('Kanye West', 'I Wonder')


def obj_dict(obj):
    return obj.__dict__


def get_data(artist, track):
    scraper = WhoSampledScraper(artist, track)
    
    result = scraper.get_all_samples()
    json_result = json.dumps(result, default=obj_dict)
    # print(json_result)

    return json_result
#endregion


if __name__=="__main__":
    # Special cases that need extra handling
    get_data('Labi Siffre','I Got The... - 2006 Remaster')
    get_data("N.W.A", "Straight Outta Compton")

    # get_data('Tears-For-Fears','Everybody-Wants-To-Rule-The-World')
    # get_data("Macklemore", "Can't Hold Us")
    # get_data('Modjo', 'Lady (Hear Me Tonight)')
