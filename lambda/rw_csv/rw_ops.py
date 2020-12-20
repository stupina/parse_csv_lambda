import os
import sqlalchemy

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from boto3 import client

s3_client = client('s3')


def get_rds_connection():
    rds_host = os.environ.get('db_host')
    rds_port = os.environ.get('db_port')
    user = os.environ.get('db_username')
    password = os.environ.get('db_password')
    db_name = os.environ.get('db_name')

    db_config = 'postgres://{}:{}@{}:{}/{}'.format(
        user,
        password,
        rds_host,
        rds_port,
        db_name,

    )
    engine = sqlalchemy.create_engine(db_config)



    conn = engine.connect()

    return conn


def read_csv_from_s3(event):
    data = event['Records'][0]['s3']
    bucket_name = data['bucket']['name']
    file_name = data['object']['key']
    obj = s3_client.get_object(
        Bucket=bucket_name,
        Key=file_name,
    )
    df = pd.read_csv(obj['Body'])
    return df


def filter_df(df):
    max_pop_size = int(os.environ.get('max_pop_size'))
    min_pop_size = int(os.environ.get('min_pop_size'))

    new_df = df.query(
        'population > @min_pop_size and population < @max_pop_size'
    )

    return new_df


def write_df_to_s3(df):
    table = pa.Table.from_pandas(df)
    writer = pa.BufferOutputStream()
    pq.write_table(table, writer)
    body = bytes(writer.getvalue())

    s3_client.put_object(
        Body=body,
        Bucket=os.environ.get('bucket'),
        Key=os.environ.get('key'),
    )


def write_df_to_db(df):
    conn = get_rds_connection()
    df.to_sql('countries', conn, if_exists='replace')


def parse_csv(event):
    df = read_csv_from_s3(event)
    df = filter_df(df)
    write_df_to_db(df)
    write_df_to_s3(df)
