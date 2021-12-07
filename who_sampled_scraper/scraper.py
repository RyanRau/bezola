import re
import json
import requests
from bs4 import BeautifulSoup

#region Classes
class SampleData:
    def __init__(self, samples, sampled_by) -> None:
        self.samples = samples
        self.sampled_by = sampled_by


class Song:
    def __init__(self, track, artist, year) -> None:
        self.track = track
        self.artist = artist
        self.year = year


class WhoSampledScraper:
    BASE_URL = 'https://www.whosampled.com'
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36',
    }


    def __init__(self, artist, song) -> None:
        url = self.build_url(artist, song)
        print(url)
        page = requests.get(url, headers=self.HEADERS)

        # Add checking 

        self.soup = BeautifulSoup(page.content, 'html.parser')


    def build_url(self, artist, song) -> str:
        return '{}/{}/{}/'.format(self.BASE_URL, artist.replace(' ', '-'), song.replace(' ', '-'))


    def get_all_samples(self) -> list:
        '''
        Returns:
            (samples, sampled by): returns tuple of songs which the requested song samples along with songs which sample it
        '''
        return SampleData(self.get_samples(), self.get_samples(sampled_by=True))


    def get_samples(self, sampled_by=False) -> list: 
        '''
        Defaultly gets songs which requested song samples

        Args:
            sampled_by: set to true if you want songs which samples the requested song (default=False)
        Returns:
            songs: List of Song objects
        '''

        section_str = ('contains samples', 'was sampled')[sampled_by]

        section = None
        for t in self.soup.find_all('span', class_='section-header-title'):
            if section_str in t.contents[0].lower():
                section = t.parent.parent
                continue

        if section is None:
            return []

        samples = self.get_songs_from_section(section)
        
        return samples


    def get_songs_from_section(self, section) -> list:
        '''
        Parses out sample entry html to song objects

        Args:
            section: bs4 section which containes sample entries to be parsed out
        Returns:
            songs: List of Song objects parsed from sample entries
        '''
        
        songs = []
        for song in section.find_all('div', class_='sampleEntry'):
            details = song.find_all('div', class_='trackDetails')[0]

            songs.append(Song(
                track=details.find_all('a', class_='trackName')[0].contents[0],
                artist=details.find_all('span', class_='trackArtist')[0].find_all('a')[0].contents[0],
                year=re.findall(r"[0-9]{4,7}", details.find_all('span', class_='trackArtist')[0].contents[2])[0]
            ))
        
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
    print(json_result)

    return json_result
#endregion

# get_data('Modjo', 'Lady (Hear Me Tonight)')