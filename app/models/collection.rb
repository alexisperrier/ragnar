class Collection < ApplicationRecord
    belongs_to :user
    has_many :collection_items
    has_many :videos, through: :collection_items
    has_many :channels, through: :collection_items

    has_one_attached :csvfile


    def self.extract_items(filename)
        df = Rover.read_csv filename

        # check channel_id and video_id in columns

        has_channels = df.vector_names.include? 'channel_id'
        has_videos   = df.vector_names.include? 'video_id'

        if has_channels
            # channel_ids = df['channel_id'].to_a.sort
            channel_ids = df['channel_id'].map{|id| id.to_s}.to_a.sort
            # format
            channel_ids = channel_ids.filter{|id| id if (id.length == 24) && id[0..1] == 'UC'  }

            # duplicates
            channel_ids = channel_ids.uniq

        end

        if has_videos
            video_ids = df['video_id'].map{|id| id.to_s}.to_a.sort
            # video_ids = df['video_id'].to_a.sort
            # format
            video_ids = video_ids.filter{|id| id if (id.length == 11) }

            # duplicates
            video_ids = video_ids.uniq
        end
        return channel_ids, video_ids

    end



    def self.validate_upload(filename)
        # filename = 'data/collection_test.csv'
        df = Rover.read_csv filename

        # check channel_id and video_id in columns

        errors   = []
        warnings = []
        messages = []
        messages.append("- the file has #{df.shape[0]} rows and #{df.shape[1]} column(s)  ")
        messages.append("- the file columns are #{df.vector_names} ")

        if df.shape[0] == 0
            errors.append("The file has no rows")
        end
        if df.shape[1] == 0
            errors.append("The file has no columns")
        end


        has_channels = df.vector_names.include? 'channel_id'
        has_videos   = df.vector_names.include? 'video_id'

        if not has_channels and not has_videos
            errors.append("The columns of the file do not include channel_id or video_id")
        end

        if has_channels

            # channel_ids = df['channel_id'].to_a.sort
            channel_ids = df['channel_id'].map{|id| id.to_s}.to_a.sort
            # check format of channel_id
            format = channel_ids.map{|id|  (id.length == 24) && id[0..1] == 'UC'  }
            if format.count(true) == df.shape[0]
                messages.append("All channel ids are properly formatted")
            else
                errors.append("Out of #{df.shape[0]} channel ids, #{df.shape[0] - format.count(true)} are not properl formatted. <br />-channel_id has 24 characters<br />- channel_id starts with UC")
                channel_ids = channel_ids.filter{|id| id if (id.length == 24) && id[0..1] == 'UC'  }
            end

            # duplicates
            channel_counts = channel_ids.group_by(&:itself).transform_values(&:count)
            dups = channel_counts.filter{|k,v| k if v > 1}.map{|k,v| k}
            if not dups.empty?
                warnings.append("These channel_ids are present more than once: #{dups}")
                channel_ids = channel_ids.uniq
            end

            # check existence of channels
            channels = Channel.joins(:pipeline).where(:channel_id => channel_ids).preload(:pipeline)
            messages.append("- #{channels.count} channels already exists, #{df['channel_id'].to_a.size -  channels.count } will be created")
            status = channels.map{|c| c.pipeline.status}.group_by(&:itself).transform_values(&:count)
            messages.append("- Status of known channels: #{status}")

        end

        if has_videos

            video_ids = df['video_id'].map{|id| id.to_s}.to_a.sort
            # video_ids = df['video_id'].to_a.sort
            
            # check format of video_id
            format = video_ids.map{|id|  (id.length == 11) }
            if format.count(true) == df.shape[0]
                messages.append("All video ids are properly formatted")
            else
                errors.append("Out of #{df.shape[0]} video ids, #{format.count(true)} are not properl formatted. \n -video_id has 11 characters")
                video_ids = video_ids.filter{|id| id if (id.length == 24) && id[0..1] == 'UC'  }
            end

            # duplicates
            video_counts = video_ids.group_by(&:itself).transform_values(&:count)
            dups = video_counts.filter{|k,v| k if v > 1}.map{|k,v| k}
            if not dups.empty?
                warnings.append("These video_ids are present more than once: #{dups}")
                video_ids = video_ids.uniq
            end

            # check existence of videos
            videos = Channel.joins(:pipeline).where(:video_id => video_ids).preload(:pipeline)
            messages.append("- #{videos.count} videos already exists, #{df['video_id'].to_a.size -  videos.count } will be created")
            status = videos.map{|c| c.pipeline.status}.group_by(&:itself).transform_values(&:count)
            messages.append("- Status of known videos: #{status}")

        end
        return messages, warnings, errors

    end

end
