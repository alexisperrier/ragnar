'''
export_territoire\


- all:
    - cleanup columns
    - missing values as '' or 0
- videos: merge with stats
- channel: merge with stats
- captions: add video title, channel title, channel_id
- comments: add video title, channel title, channel_id
- cocomentators: comm, video, channel
- colab: load, explore, count

'''
import pandas as pd
import csv, os, sys, re, json
import datetime
import glob

pd.options.display.max_columns = None

filedate    = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')

if False:
    EXPORT_PATH = "/home/alexis/ragnar/tmp/20201222/"
    INPUT_PATH  = "/home/alexis/ragnar/tmp/"

if True:
    EXPORT_PATH     = "/Users/alexis/amcp/rails/ragnar/tmp//20201222/"
    INPUT_PATH     = "/Users/alexis/amcp/rails/ragnar/tmp/"

input_files = {
    'captions':'kansatsu_captions_20201221_183218.csv',
    'channels':'kansatsu_channels_20201221_183218.csv',
    'channels_stats':'kansatsu_channels_stats_20201221_183218.csv',
    'comments':'kansatsu_comments_20201221_183218.csv',
    'videos':'kansatsu_videos_20201221_183218.csv',
    'videos_stats':'kansatsu_videos_stats_20201221_183218.csv',
}

output_files = {
    'videos': f"cncdh_videos_{filedate}.csv",
    'channels': f"cncdh_channels_{filedate}.csv",
    'captions': f"cncdh_captions_{filedate}.csv",
}

youtube_categories = { -1: '',
1: 'Film & Animation',
2: 'Autos & Vehicles',
10: 'Music',
15: 'Pets & Animals',
17: 'Sports',
18: 'Short Movies',
19: 'Travel & Events',
20: 'Gaming',
21: 'Videoblogging',
22: 'People & Blogs',
23: 'Comedy',
24: 'Entertainment',
25: 'News & Politics',
26: 'Howto & Style',
27: 'Education',
28: 'Science & Technology',
29: 'Nonprofits & Activism',
30: 'Movies',
31: 'Anime/Animation',
32: 'Action/Adventure',
33: 'Classics',
34: 'Comedy',
35: 'Documentary',
36: 'Drama',
37: 'Family',
38: 'Foreign',
39: 'Horror',
40: 'Sci-Fi/Fantasy',
41: 'Thriller',
42: 'Shorts',
43: 'Shows',
44: 'Trailers'}

if __name__ == "__main__":
    '''
        Channels & channels_stats
    '''
    columns = ['channel_id','title', 'description', 'status', 'country', 'custom_url','created_at',
        'retrieved_at', 'origin','activity_score', 'activity','lang','lang_conf']
    channels = pd.read_csv(input_files['channels'])[columns]

    # channels_stats
    columns = ['channel_id', 'views', 'subscribers', 'videos', 'retrieved_at']
    stats = pd.read_csv(input_files['channels_stats'])[columns]
    stats.rename(columns = {'retrieved_at': 'stats_retrieved_at'}, inplace = True)
    # merge
    channels = channels.merge(stats, on = 'channel_id', how = 'outer')

    # missing values
    channels.fillna(value = {
        'title':'', 'description':'', 'status':'', 'country':'', 'custom_url':'','created_at':'',
        'retrieved_at':'', 'origin':'','activity_score':0, 'activity':'','lang':'','lang_conf':0,
        'views':-1, 'subscribers':-1, 'videos':-1, 'stats_retrieved_at':''
        },
        inplace = True)

    # save
    channels.to_csv(os.path.join(EXPORT_PATH, output_files['channels']), index = False, quoting = csv.QUOTE_ALL)

    '''
        Videos & videos_stats
    '''
    columns = ['video_id', 'channel_id','status', 'title', 'summary',
               'category_id', 'duration', 'seconds',
               'published_at',  'pubdate','retrieved_at',
               'tags', 'wikitopics', 'origin',
               'default_audio_language', 'default_language' ]
    videos = pd.read_csv(input_files['videos'])[columns]
    videos.rename(columns = {'seconds': 'duration_in_seconds'}, inplace = True)


    # stats
    stats = pd.read_csv(input_files['videos_stats'])
    stats.rename(columns = {'video-id': 'video_id'}, inplace = True)
    stats.fillna(value={'views': -1}, inplace = True)
    stats['views'] = stats.views.astype(int)

    # merge
    videos = videos.merge(stats, on = 'video_id', how = 'outer')

    # category
    videos.loc[videos.category_id.isna(), 'category_id'] = -1
    videos['category_id'] = videos.category_id.astype(int)
    videos['youtube_category'] = videos.category_id.apply(lambda id: youtube_categories[id])

    # fillna
    videos.fillna(value = {
        'status':'', 'title':'', 'summary':'', 'category_id':0,
        'duration':'', 'duration_in_seconds':0, 'published_at':'', 'pubdate':'',
        'retrieved_at':'', 'tags':'', 'wikitopics':'', 'origin':'',
        'default_audio_language':'', 'default_language':'','views':-1
    }, inplace = True)

    videos['duration_in_seconds'] = videos.views.astype(int)
    videos['views'] = videos.views.astype(int)

    videos.to_csv(os.path.join(EXPORT_PATH, output_files['videos']), index = False, quoting = csv.QUOTE_ALL)

    '''
        Captions
        - captions: add video title, channel title, channel_id
    '''
    columns = ['video_id', 'status', 'wordcount', 'processed_at', 'caption_type', 'caption']
    captions = pd.read_csv(input_files['captions'])[columns]
    captions = captions[(captions.status == 'acquired') & (captions.wordcount > 2)].copy()
    captions.reset_index(inplace = True, drop = True)

    captions['wordcount'] = captions.wordcount.astype(int)
    # add channel_id
    video2channel = dict(videos[['video_id','channel_id']].values)
    captions['channel_id'] = captions.video_id.apply(lambda id : video2channel[id])
    # order columns, rm status
    columns = ['video_id','channel_id', 'wordcount', 'processed_at', 'caption_type', 'caption']
    captions = captions[columns]
    captions.to_csv(os.path.join(EXPORT_PATH, output_files['captions']), index = False, quoting = csv.QUOTE_ALL)

    '''
        Comments
        - comments: add channel_id
    '''





# ----
