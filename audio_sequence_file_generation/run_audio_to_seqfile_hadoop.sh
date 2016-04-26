hadoop fs -copyFromLocal ./mp3_files/audio_file_list.txt /user/radhar5/audio/audio_file_list_mp3.txt

hadoop jar convert_audio_to_seqfile_hadoop.jar ConvertAudioToSequenceFileHadoop "/user/radhar5/audio/audio_file_list_mp3.txt" "/user/radhar5/audio/audio_SequenceFile_mp3"
hadoop jar convert_audio_to_seqfile_hadoop.jar ConvertAudioToSequenceFileHadoop "/user/radhar5/audio/audio_file_list_ashcut.txt" "/user/radhar5/audio/audio_SequenceFile_ashcutm4a"

hadoop jar convert_audio_to_seqfile_hadoop.jar ConvertAudioToSequenceFileHadoop "/user/radhar5/audio/audio_file_list_mp3_audacity.txt" "/user/radhar5/audio/audio_SequenceFile_audacity"
hadoop jar convert_audio_to_seqfile_hadoop.jar ConvertAudioToSequenceFileHadoop "/user/radhar5/audio/audio_file_list_vlccmd.txt" "/user/radhar5/audio/audio_SequenceFile_vlccmd"



hadoop fs -copyToLocal /user/radhar5/audio/audio_SequenceFile/part-r-00000 audio_seq_file.csv
hadoop fs -copyToLocal /user/radhar5/audio/audio_SequenceFile_ashcutm4a/part-r-00000 audio_seq_file_ashcutm4a.csv
hadoop fs -copyToLocal /user/radhar5/audio/audio_SequenceFile_audacity/part-r-00000 audio_seq_file_audacity.csv
hadoop fs -copyToLocal /user/radhar5/audio/audio_SequenceFile_vlccmd/part-r-00000 audio_seq_file_vlccmd.csv


scp audio_seq_file.csv radhar5@10.68.128.135:/home/radhar5/audio_seq/

for file in /Users/regunathanradhakrishnan/Google Drive/audio_fing/songs/Top75wavStereo44p1_m4a/*.mp3; do /Applications/VLC.app/Contents/MacOS/VLC -I dummy "$file" --sout="#transcode{acodec=mp3,vcodec=dummy}:standard{access=file,mux=raw,dst=\"$(echo "$file" | sed 's/\.[^\.]*$/.mp3/')\"}" vlc://quit; done

/Applications/VLC.app/Contents/MacOS/VLC ../Top75wavStereo44p1_m4a/Ashley_Tisdale-_Its_Alright,_Its_OK.mp3 --sout=#transcode'{acodec=mp3,vcodec=dummy}:standard{access=file,mux=raw,dst="/Users/regunathanradhakrishnan/ashley_vlc_cmd.mp3"}' vlc://quit

import os
filenames =next(os.walk('/Users/regunathanradhakrishnan/Google Drive/audio_fing/songs/Top75wavStereo44p1_m4a/'))[2]

for fn in filenames:
	if(fn.find('.mp3') != -1):
		#print(fn)
		fn_out = fn + 'vlc_cmd.mp3'
		cmd_val = "/Applications/VLC.app/Contents/MacOS/VLC %s --sout=#transcode'{acodec=mp3,vcodec=dummy}:standard{access=file,mux=raw,dst=%s}' vlc://quit" % (fn,fn_out)
		print(cmd_val)


import os
filenames =next(os.walk('/Users/regunathanradhakrishnan/Google Drive/audio_fing/songs/Top75wavStereo44p1_m4a/'))[2]

for fn in filenames:
	if(fn.find('mp3vlc_cmd.mp3') != -1):
		#print(fn)
		#fn_out = fn + 'vlc_cmd.mp3'
		cmd_val = "/user/radhar5/audio/%s" % (fn)
		print(cmd_val)

drop function if exists audiofp.extract_audiofing(text,text,int);
create or replace function audiofp.extract_audiofing(input_table_name text,output_table_name text,start_ind int)
returns text
as
$$

    sql = """
          select 
	       aud_name
          from
	     {input_table} 
	     where aud_name NOT like '%Beyonce-_Halo.mp3vlc_cmd.mp3%'
	      and aud_name NOT like '%Black_Eyed_Peas-_Boom_Boom_Pow%'
	      and aud_name NOT like '%Black_Eyed_Peas-_I_Gotta_Feeling%'
	      and aud_name NOT like '%Green_Day-_21_Guns%'
	      and aud_name NOT like '%Katy_Perry-_Hot_N_Cold%'
	      and aud_name NOT like '%Kings_Of_Leon-_Sex_On_Fire%'
	      and aud_name NOT like '%Lily_Allen-_The_Fear%'
	      and aud_name NOT like '%Linkin_Park-_New_Divide%'
	      and aud_name NOT like '%Pitbull-_I_Know_You_Want_Me%'
             order by 1
          """.format(input_table = input_table_name)
    result = plpy.execute(sql)
    aud_fnames = [r['aud_name'] for r in result]
    

    for i in range(start_ind,len(aud_fnames)):
        if(i==0):
            sql = """
                 drop table if exists {output_table}
                 """.format(output_table = output_table_name);
            plpy.execute(sql)
            sql = """
                 create table {output_test_table1} as
                 (
                     select
             		 aud_name,
             		(fing_descriptors).*
				      from
				      ( select
				           aud_name,
				           audiofp.fing_extract_plpy(audio) as fing_descriptors
				       from
				            {input_table}
				       where aud_name like '%{audiofilename}%'
				      ) as foo
                 ) distributed randomly
                 """.format(output_test_table1 = output_table_name,
                            input_table = input_table_name,
                            audiofilename = aud_fnames[i]
                            )
            plpy.info(sql)
            plpy.execute(sql)
        else:
            sql = """
                  insert into {output_test_table2}
                  (
                      select
             		 aud_name,
             		(fing_descriptors).*
				      from
				      ( select
				           aud_name,
				           audiofp.fing_extract_plpy(audio) as fing_descriptors
				       from
				            {input_table2}
				       where aud_name like '%{audiofilename2}%'
				      ) as foo
                  )
                  """.format(output_test_table2 = output_table_name,
                            input_table2 = input_table_name,
                            audiofilename2 = aud_fnames[i]
                            )
            plpy.info(sql)
            plpy.execute(sql)
    return('DONE')
$$ language plpythonu;

select audiofp.extract_audiofing('audiofp.training_audio','audiofp.training_fing_descriptors_vlcmp3',0)



