import yt_dlp
import os
import re
from typing import Optional, Dict, Any
from datetime import datetime

# Note: example usage from repository taken as main code here for downloading, path names were then changed

class TikTokDownloader:
    def __init__(self, save_path: str = 'tiktok_videos'):
        """
        Initialize TikTok downloader with configurable save path
        
        Args:
            save_path (str): Directory where videos will be saved
        """
        self.save_path = save_path
        self.create_save_directory()
    
    def create_save_directory(self) -> None:
        """Create the save directory if it doesn't exist"""
        if not os.path.exists(self.save_path):
            os.makedirs(self.save_path)
    
    @staticmethod
    def validate_url(url: str) -> bool:
        """
        Validate if the provided URL is a TikTok URL
        
        Args:
            url (str): URL to validate
            
        Returns:
            bool: True if valid, False otherwise
        """
        tiktok_pattern = r'https?://((?:vm|vt|www)\.)?tiktok\.com/.*'
        return bool(re.match(tiktok_pattern, url))
    
    @staticmethod
    def progress_hook(d: Dict[str, Any]) -> None:
        """
        Hook to display download progress
        
        Args:
            d (Dict[str, Any]): Progress information dictionary
        """
        if d['status'] == 'downloading':
            progress = d.get('_percent_str', 'N/A')
            speed = d.get('_speed_str', 'N/A')
            eta = d.get('_eta_str', 'N/A')
            print(f"Downloading: {progress} at {speed} ETA: {eta}", end='\r')
        elif d['status'] == 'finished':
            print("\nDownload completed, finalizing...")
    
    def get_filename(self, video_url: str, custom_name: Optional[str] = None) -> str:
        """
        Generate filename for the video
        
        Args:
            video_url (str): Video URL
            custom_name (Optional[str]): Custom name for the video file
            
        Returns:
            str: Generated filename
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        if custom_name:
            return f"{custom_name}_{timestamp}.mp4"
        return f"tiktok_{timestamp}.mp4"
    
    def download_video(self, video_url: str, custom_name: Optional[str] = None) -> Optional[str]:
        """
        Download TikTok video
        
        Args:
            video_url (str): URL of the TikTok video
            custom_name (Optional[str]): Custom name for the video file
            
        Returns:
            Optional[str]: Path to downloaded file if successful, None otherwise
        """
        if not self.validate_url(video_url):
            print("Error: Invalid TikTok URL")
            return None

        filename = self.get_filename(video_url, custom_name)
        output_path = os.path.join(self.save_path, filename)
        
        ydl_opts = {
            'outtmpl': output_path,
            'format': 'best',
            'noplaylist': True,
            'quiet': False,
            'progress_hooks': [self.progress_hook],
            'cookiesfrombrowser': ('chrome',),  # Use Chrome cookies for authentication
            'extractor_args': {'tiktok': {'webpage_download': True}},
            'http_headers': {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
        }

        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([video_url])
                print(f"\nVideo successfully downloaded: {output_path}")
                return output_path
                
        except yt_dlp.utils.DownloadError as e:
            print(f"Error downloading video: {str(e)}")
        except Exception as e:
            print(f"An unexpected error occurred: {str(e)}")
        
        return None

# Example usage
if __name__ == "__main__":
    downloader = TikTokDownloader(save_path='downloaded_tiktoks')

    ''' 
    video_url = "https://www.tiktok.com/@zachking/video/6768504823336815877"
    
    # Basic usage
    downloader.download_video(video_url)
    
    # With custom filename
    downloader.download_video(video_url, custom_name="zach_king_magic")

    # Custom save location and filename
    downloader = TikTokDownloader(save_path='my_tiktoks')
    downloader.download_video(video_url, custom_name="dance_video")
    '''


# Download multiple videos (first 15 that i have already scraped)
'''

urls = [
    "https://www.tiktok.com/@charsamanthaa/video/7455467603121982766",
    "https://www.tiktok.com/@charsamanthaa/video/7460685845910310190",
    "https://www.tiktok.com/@thekaitrumpgolfer/video/7459491278120832302",
    "https://www.tiktok.com/@aleyahaleysha/photo/7375596642311064878", #FYI: links with photos cannot be downloaded!!!!!
    "https://www.tiktok.com/@ryley/video/7444646879003954465",
    "https://www.tiktok.com/@islacrawford_/video/7455329177831607560",
    "https://www.tiktok.com/@regenacore/video/7440927679739678007",
    "https://www.tiktok.com/@mariamshem/video/7430529039443479840",
    "https://www.tiktok.com/@janelthebear/video/7460562387368676641",
    "https://www.tiktok.com/@janelthebear/video/7440525188451618081",
    "https://www.tiktok.com/@charlotte__martel/video/7458850831199112481",
    "https://www.tiktok.com/@charlotte__martel/video/7450960343909535008",
    "https://www.tiktok.com/@hannahkoumakis/video/7458753529302289672",
    "https://www.tiktok.com/@peytonliveslife/video/7460997559021030698",
    "https://www.tiktok.com/@peytonliveslife/video/7459506825734409514"
]

'''

urls = ["https://vt.tiktok.com/ZSM9RNPre/",
        "https://vt.tiktok.com/ZSM9R27xp/", 
        "https://vt.tiktok.com/ZSM9Rduck/",
        "https://vt.tiktok.com/ZSM9R1oRY/",
        "https://vt.tiktok.com/ZSM9dos8s/",
        "https://vt.tiktok.com/ZSM9RR88S/",
        "https://vt.tiktok.com/ZSM9RUESu/",
        "https://vt.tiktok.com/ZSM9RJWXk/",
        "https://vt.tiktok.com/ZSM9Rreao/"]


for url in urls:
    downloader.download_video(url, custom_name="forgotten")


#video_id = 7455467603121982766 #1
#video_id = 7460685845910310190 #2
#video_id = 7459491278120832302 #3 
#video_id = 7375596642311064878 #4 
#video_id = 7444646879003954465 #5
#video_id = 7455329177831607560 #6
#video_id = 7440927679739678007 #7
#video_id = 7430529039443479840 #8
#video_id = 7460562387368676641 #9
#video_id = 7440525188451618081 #10 
#video_id = 7458850831199112481 #11
#video_id = 7450960343909535008 #12
#video_id = 7458753529302289672 #13
#video_id = 7460997559021030698 #14
#video_id = 7459506825734409514 #15