# HarmScoringDatasets

We had 2 separate approaches for scraping and downloading the datapoints that we needed to build our datasets as explained in the thesis. Hence, here you will find 2 folders pertaining to each of the platforms. The third folder contains all the R code that was used to then visualise and analyse the data. The last folder contains all the labelled datasets that were used for analysis.  

Tiktok:
Scraping
We configured the TikTok Api by David Teather to scrape the comments. After all the comments were scraped we compiled the outputs into one large file to serve as our dataset. We also downloaded the videos for future reference. 

For Instagram 
First we downloaded all the profiles that we were interested in and then it fetched the comments from the posts of those user profiles. Lastly, we downloaded the posts.
Note that in order to scrape it was necessary to be logged in to an account or else it was not possible to download the comments. 

We also used some python code to break up the datasets into batches which we were then able to give to ChatGPT to label for us based on our scoring mechanism.


