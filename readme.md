# bezola

MacOS status bar app which will show you the songs which the current song playing on Spotify samples along with the songs which sample the currently playing song.

<div float="left">
<img src="misc/samples.png" width="300"/>
<img src="misc/sampled_by.png" width="300"/>
</div>

Additionally, if you connect your Spotify account you'll be able to add the related tracks to your queue. Only tracks available on Spotify will allow display the option to add to queue.

<img src="misc/add_to_queue.png" width="300"/>

Data is scraped from WhoSampled

### Running
Xcode uses the system's instance of python when executing the WhoSampled scraper, therefore make sure the required libraries are installed. The necessary libraries can be found in [requirements.txt](misc/requirements.txt)
