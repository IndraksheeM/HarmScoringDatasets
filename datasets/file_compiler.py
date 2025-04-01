import pandas as pd
import glob, os
from pathlib import Path
import json


filenames = [i for i in os.listdir("/Users/indraksheem/Bachelorarbeit data/Instagram raw data/comments") if i.endswith(".json")]

data = []
 
for currentfile in filenames:
    with open(f"/Users/indraksheem/Bachelorarbeit data/Instagram raw data/comments/{currentfile}", 'r') as f:
        tmp = json.load(f)
    for i in tmp:
        if i is not None:
            i['postId'] = currentfile.replace('_comments.json', '')
            data.append(i)
df = pd.DataFrame(data)  
df.to_csv("/Users/indraksheem/Bachelorarbeit data/Instagram raw data/comments as csv/comments_compiled.csv")



'''
insta_json_filepath = "/Users/indraksheem/Bachelorarbeit data/Instagram raw data/comments/*.json"
insta_comments_files = glob.glob(insta_json_filepath)


for filename in insta_comments_files:
    currentfile = pd.read_json(filename)
    outputfilename = (filename + ".csv")
    print(filename)
    csvpath = Path("/Users/indraksheem/Bachelorarbeit data/Instagram raw data/comments as csv")
    csvpath.mkdir(parents=True, exist_ok=True)
    currentfile.to_csv(csvpath / outputfilename)








print(data)
compiled_instagram_data = "/Users/indraksheem/Bachelorarbeit data/instagram_compiled_comments.csv"

df = pd.concat([pd.read_json(filename) for filename in insta_comments_files])
'''

