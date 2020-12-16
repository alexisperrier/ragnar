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
pd.options.display.max_columns = None

filedate = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
EXPORT_PATH     = "/Users/alexis/amcp/CNCDH/exports/20201201/"
INPUT_PATH     = "/Users/alexis/amcp/rails/ragnar/tmp/"
videos_file     = f"kansatsu_territoires_videos_{filedate}.csv"
channels_file   = f"kansatsu_territoires_channels_{filedate}.csv"
comments_file   = f"kansatsu_territoires_comments_{filedate}.csv"
captions_file   = f"kansatsu_territoires_captions_{filedate}.csv"

# channels
df1 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_espace_media_fr_channels_20201130_184039.csv'))
df2 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_medialab__channels_20201130_184035.csv'))
df3 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_sig___anti_vax_channels_20201130_184036.csv'))

df = pd.concat([df1, df2, df3])
df.drop_duplicates(subset = 'channel_id', inplace = True)
df = df[['channel_id','title', 'description', 'views', 'subscribers', 'videos', 'status', 'country', 'custom_url','created_at_1', 'retrieved_at_1', 'activity_score', 'activity','lang','lang_conf']]

df.sort_values(by = 'title', ascending = True, inplace = True)
print(f"exporting channels [{df.shape}] to {os.path.join(EXPORT_PATH, channels_file)}")
df.to_csv(os.path.join(EXPORT_PATH, channels_file), index = False, quoting = csv.QUOTE_ALL)


# videos
df1 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_medialab__videos_20201201_063345.csv'))

df2 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_sig___anti_vax_videos_20201201_063901.csv'))
df3 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_espace_media_fr_videos_20201201_112810.csv'))

df = pd.concat([df1, df2, df3])
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


df = df[[
'channel_id','video_id', 'title', 'summary',
'status', 'views',
'duration','duration_in_seconds',  'pubdate', 'published_at', 'retrieved_at',
'category_id','tags', 'wikitopics',
'default_audio_language', 'default_language',  'created_at' ]]

df.loc[df.category_id.isna(), 'category_id'] = -1
df['category_id'] = df.category_id.astype(int)
df['youtube_category'] = df.category_id.apply(lambda id: cat[id])




df.sort_values(by = ['channel_id', 'video_id'], ascending = [True,True], inplace = True)

print(f"exporting videos [{df.shape}] to {os.path.join(EXPORT_PATH, videos_file)}")
df.to_csv(os.path.join(EXPORT_PATH, videos_file), index = False, quoting = csv.QUOTE_ALL)


# comments
df1 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_espace_media_fr_comments_20201130_223933.csv'))
df2 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_medialab__comments_20201130_220525.csv'))
df3 = pd.read_csv(os.path.join(INPUT_PATH,'kansatsu_sig___anti_vax_comments_20201130_214033.csv'))
df = pd.concat([df1, df2, df3])

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
