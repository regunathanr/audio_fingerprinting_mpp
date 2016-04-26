
import java.io.*;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.IOUtils;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.NLineInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;

public class ConvertAudioToSequenceFileHadoop {
    public static class AudioToSequenceMapper extends Mapper<LongWritable,Text,Text, Text> { 
       
        @Override
	public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
	    String imgName = value.toString();
	    FileSystem fs = FileSystem.get(context.getConfiguration());

	    FSDataInputStream in = null;
	    in = fs.open(new Path(imgName));
	    byte[] buffer = new byte[in.available()];
	    
	    in.readFully(0,buffer,0,in.available());
            //context.write(value, new BytesWritable(buffer));

		context.write(value, buffer.toString());		
            // Ideally I would want a try-catch-finally block here 
	    // since I want to know if there is a problem reading the file. 
	    // But till I figure out logging, I am going to keep this ugly bit of code.
	    IOUtils.closeStream(in);
	}
    }
 
   public static void main(String[] args) throws Exception{
	System.out.println("Entering Main");
	Job job = Job.getInstance(new Configuration());
	job.setJarByClass(ConvertAudioToSequenceFileHadoop.class);
	job.setMapperClass(AudioToSequenceMapper.class);

	job.setOutputKeyClass(Text.class);
	job.setOutputValueClass(Text.class);

	job.setOutputFormatClass(TextOutputFormat.class);
	job.setInputFormatClass(NLineInputFormat.class);
      	//NLineInputFormat.setNumLinesPerSplit(job, 2039);//uncomment this for the full caltech 256 img list
	NLineInputFormat.setNumLinesPerSplit(job,113);

        String inputFileName = args[0];
	System.out.println("Input file name is " + inputFileName);

	String outputFileName = args[1];
	System.out.println("Output file name is " + outputFileName);

	FileInputFormat.addInputPath(job, new Path(inputFileName));
	FileOutputFormat.setOutputPath(job, new Path(outputFileName));
	boolean result = job.waitForCompletion(true);
	System.exit(result ? 0 : 1);
   }           
}