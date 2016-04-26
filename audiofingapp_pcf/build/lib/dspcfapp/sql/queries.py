
"""
Your SQL code goes here (model building, scoring, visualization)
Srivatsan Ramanujam <vatsan.cs@utexas.edu>, June-2015
"""
def fetch_sample_data_for_heatmap(input_schema, input_table):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        input_table (str): The table in the input_schema containing data from the wells
        Outputs:
        ========
        A sql code block        
    """
    #You can write a query to fetch data from input_table, in input_schema
    sql = """
        select
            machine - 1 as id,
            hod-1 as hour,
            random() as prob
        from
            generate_series(1, 15) as machine,
            generate_series(1, 24) as hod;
    """
    return sql

def extract_fing_url(input_schema,sndcld_url):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        sndcld_url (str): soundcloud url where test clip is available
        Outputs:
        ========
        A sql code block        
    """
    sql = """
    copy (select
             'test'::text as aud_name,
             (fing_descriptors).*
      from
      ( select
           
            {input_schema}.extract_fing_from_soundcloud_url('{sndcld_url}') as fing_descriptors
       
      ) as foo) to '/home/gpadmin/test_output1.csv' with CSV
    """.format(input_schema=input_schema,
               sndcld_url=sndcld_url
               )
    return sql

def drop_fing_testtable(input_schema):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        
        ========
        A sql code block        
    """
    sql = """
    drop table if exists {input_schema}.testing_fing_descriptors_sndcld
    """.format(input_schema=input_schema
               
               )
    return sql

def create_fing_testtable(input_schema):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        
        ========
        A sql code block        
    """
    sql = """
    create table {input_schema}.testing_fing_descriptors_sndcld 
    (aud_name text,
    time_offset float, fing_val text) distributed randomly
    """.format(input_schema=input_schema
               
               )
    return sql

def copy_load(input_schema):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        
        ========
        A sql code block        
    """
    sql = """
    copy {input_schema}.testing_fing_descriptors_sndcld from '/home/gpadmin/test_output1.csv' DELIMITER ',' CSV
    """.format(input_schema=input_schema
               
               )
    return sql

def perform_fing_matching(input_schema):
    """
        Inputs:
        =======
        input_schema (str): The schema containing the input table
        
        ========
        A sql code block        
    """
    sql = """
    select db_aud,time_diff,count(*)
    from
    (
    select
          t1.*,
          t2.aud_name db_aud,
          t2.time_offset db_off,
          round(cast((t2.time_offset-t1.time_offset)*(2048.0/44100) as numeric),2) time_diff
    from
    (
    (select
          * 
    from
        {input_schema}.testing_fing_descriptors_sndcld

    )t1
    inner join
    (
    select
          * 
    from
        {input_schema}.training_fing_descriptors_vlcmp3
    )t2
    on(t1.fing_val=t2.fing_val)
    )
    )as foo group by 1,2 order by 3 desc limit 12
    """.format(input_schema=input_schema
               
               )
    return sql