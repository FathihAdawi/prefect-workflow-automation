import pandas as pd
from prefect import task,flow
from prefect.deployments.runner import DockerImage
from sqlalchemy import text
from prefect_sqlalchemy import SqlAlchemyConnector
from .packages import (del_data_table,get_data_table)

@task(version='v1.0.0',cache_policy=None)
def extract_data(query: str, block_name: str) -> pd.DataFrame:
    db_connector = SqlAlchemyConnector.load(block_name, validate=False) 
    with db_connector.get_connection() as engine:
        df = pd.read_sql(query,engine)
        print(df)
        print(df.dtypes)
    db_connector.close()
    return df

@task(version='v1.0.0',cache_policy=None)
def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    # NOTE: Transform data if needed, for example: change data type, rename column, etc.
    
    return df
    
@task(version='v1.0.0',cache_policy=None)
def load_data(df: pd.DataFrame, query_delete: str, block_name: str, table_insert: str) -> None:
    with SqlAlchemyConnector.load(block_name) as connection:
        engine = connection.get_engine()
        cursor = engine.connect()
        
        cursor.execute(text(query_delete))
        
        df.to_sql(
            name=table_insert,
            con=engine, 
            if_exists='append', 
            index=False
            )
        
        cursor.commit()
        cursor.close()
    print(f"Dataframe successfully inserted into table {table_insert}")

@flow(log_prints=True,version='v1.0.0',cache_result_in_memory=False)
def main_l1_table() -> None:
    """
        NOTE: Get data records full from Table MsBlokAtribut on SIN
    """
    df_ext = extract_data(
        block_name='sql-block',
        query=get_data_table()
    )
    
    #
    # df_tf = transform_data(
    #     df=df_ext
    # )
    
    """
        NOTE: Delete and Insert records full into Table L1_Table on PostgreSQL
    """
    load_data(
        block_name='postgre-block',        
        df=df_ext,
        
        # NOTE: If you want to transform data, just comment the code above and change df=df_ext to df=df_tf
        # df=df_tf,
        query_delete=del_data_table(),
        table_insert='L1_Table'
    )

