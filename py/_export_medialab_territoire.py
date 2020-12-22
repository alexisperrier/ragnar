'''
takes the export files gerenated by rake tasks
    rake export:channels  --  --collection 13
    rake export:channels  --  --collection 15
    rake export:channels  --  --collection 20

    rake export:videos  --  --collection 13
    rake export:videos  --  --collection 15
    rake export:videos  --  --collection 20

    rake export:comments  --  --collection 13
    rake export:comments  --  --collection 15
    rake export:comments  --  --collection 20

- concatenate all files by object type: channels, videos, comment
- remove duplicates
- set columns & sort
- dump into csv file

'''

import pandas as pd
import csv, os, sys, re, json
import datetime
import glob

pd.options.display.max_columns = None

filedate = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
EXPORT_PATH     = "/home/alexis/ragnar/tmp/20201220/"
INPUT_PATH     = "/home/alexis/ragnar/tmp/"
# EXPORT_PATH     = "/Users/alexis/amcp/CNCDH/exports/20201201/"
# INPUT_PATH     = "/Users/alexis/amcp/rails/ragnar/tmp/"
videos_file     = f"kansatsu_territoires_videos_{filedate}.csv"
channels_file   = f"kansatsu_territoires_channels_{filedate}.csv"
comments_file   = f"kansatsu_territoires_comments_{filedate}.csv"
captions_file   = f"kansatsu_territoires_captions_{filedate}.csv"

'''
Videos
'''

files = sorted([filename for filename in glob.glob(f"{INPUT_PATH}kansatsu_*_videos_*.csv")])
df = pd.DataFrame()

for file in files:
    data = pd.read_csv(file)
    df = pd.concat([df,data])
    print(file,data.shape, df.shape)

df.drop_duplicates(subset = 'video_id', inplace = True)
df.rename(columns = {
        'channel_id_1': 'channel_id',
        'retrieved_at_1': 'retrieved_at',
        'created_at_1': 'created_at',
        'title_1': 'title',
        'channel_id_1': 'channel_id',
        'seconds':'duration_in_seconds'
    },
    inplace = True)


df = df[['channel_id','video_id', 'title', 'summary',
    'status', 'duration','duration_in_seconds',  'pubdate', 'published_at', 'retrieved_at',
'category_id','tags', 'wikitopics',
'default_audio_language', 'default_language',  'created_at' ]]

df.loc[df.category_id.isna(), 'category_id'] = -1
df['category_id'] = df.category_id.astype(int)
df['youtube_category'] = df.category_id.apply(lambda id: cat[id])
print("rm dups", df.shape)

'''
get date of last video by channel => useful for
'''
# df.sort_values(by = ['channel_id', 'pubdate'], ascending = [True,False], inplace = True)

most_recent_video = df[['channel_id', 'pubdate']].groupby(by = 'channel_id').max().reset_index().rename(columns = {'pubdate': 'most_recent_video'})

df.sort_values(by = ['channel_id', 'video_id'], ascending = [True,True], inplace = True)

print(f"exporting videos [{df.shape}] to {os.path.join(EXPORT_PATH, videos_file)}")
df.to_csv(os.path.join(EXPORT_PATH, videos_file), index = False, quoting = csv.QUOTE_ALL)


'''
Channels
'''

files = sorted([filename for filename in glob.glob(f"{INPUT_PATH}kansatsu_*_channels_*.csv")])
df = pd.DataFrame()

for file in files:
    data = pd.read_csv(file)
    df = pd.concat([df,data])
    print(file,data.shape, df.shape)

df.drop_duplicates(subset = 'channel_id', inplace = True)
df = df[['channel_id','title', 'description', 'views', 'subscribers', 'videos', 'status', 'country', 'custom_url','created_at_1', 'retrieved_at_1', 'activity_score', 'activity','lang','lang_conf']]
print("rm dups", df.shape)

df = df.merge(most_recent_video, on = 'channel_id', how = 'outer')

df.sort_values(by = 'title', ascending = True, inplace = True)
print(f"exporting channels [{df.shape}] to {os.path.join(EXPORT_PATH, channels_file)}")
df.to_csv(os.path.join(EXPORT_PATH, channels_file), index = False, quoting = csv.QUOTE_ALL)



# comments
files = sorted([filename for filename in glob.glob(f"{INPUT_PATH}kansatsu_*_comments_*.csv")])
df = pd.DataFrame()

for file in files:
    data = pd.read_csv(file)
    df = pd.concat([df,data])
    print(file,data.shape, df.shape)

df.drop_duplicates(subset = 'comment_id', inplace = True)
df.sort_values(by = ['video_id','published_at'], ascending = [True,True], inplace = True)

print(f"exporting comments [{df.shape}] to {os.path.join(EXPORT_PATH, comments_file)}")
df.to_csv(os.path.join(EXPORT_PATH, comments_file), index = False, quoting = csv.QUOTE_ALL)


# captions
df1 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_espace_media_fr_captions_20201130_225657.csv'))
df2 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_medialab__captions_20201130_224958.csv'))
df3 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_sig___anti_vax_captions_20201130_224725.csv'))

df = pd.concat([df1, df2, df3])

df.drop_duplicates(subset = 'video_id', inplace = True)
df = df[(df.status == 'acquired') & (df.wordcount > 2)]


df.sort_values(by = ['video_id'], ascending = [True], inplace = True)
df.reset_index(inplace = True, drop = True)
df = df[['video_id', 'wordcount', 'processed_at', 'caption']]
df.rename(columns = {'caption': 'text'}, inplace = True)
df['wordcount'] = df.wordcount.astype(int)

df.to_csv(os.path.join(EXPORT_PATH, captions_file), index = False, quoting = csv.QUOTE_ALL)
# ---
