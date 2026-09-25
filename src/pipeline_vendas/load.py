import pandas as pd
from pathlib import Path
import sqlite3


FOLDER_PROCESSED = Path("../data/processed")
DATABASE = Path("../data/database/sales.db")
SQL_SCHEMA = Path("../sql/create_tables.sql")


def load_processed_data(dfs: dict[str, pd.DataFrame]) -> None:
    """
    Exporta os DataFrames processados para arquivos CSV na pasta processed.

    Parameters
    ----------
    dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames a serem exportados.
    """

    for name, df in dfs.items():
        file = (FOLDER_PROCESSED / name).with_suffix(".csv")

        if file.is_file():
            print(f"O arquivo {file} já existe.")
        else:
            df.to_csv(file, index=False)
            print(f"O arquivo {file} foi carregado com sucesso!")


def create_database() -> None:
    """Cria as tabelas do banco de dados a partir do schema SQL."""

    with sqlite3.connect(DATABASE) as connection:
        with open(SQL_SCHEMA, "r", encoding="utf-8") as file:
            sql = file.read()

        connection.executescript(sql)


def load_data(dfs: dict[str, pd.DataFrame]) -> None:
    """
    Carrega os DataFrames nas tabelas correspondentes do banco de dados.

    Parameters
    ----------
    dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames a serem carregados.
    """

    with sqlite3.connect(DATABASE) as connection:
        for name, df in dfs.items():
            df.to_sql(
                name=name,
                con=connection,
                if_exists="append",
                index=False,
                chunksize=20000,
                method="multi"
            )


def run_load(dfs: dict[str, pd.DataFrame]) -> None:
    """
    Cria o banco de dados e realiza a carga dos dados caso ele não exista.

    Parameters
    ----------
    dfs : dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames a serem carregados.
    """

    if DATABASE.is_file():
        print("O banco de dados já existe. A carga não foi realizada.")

    else:
        create_database()
        load_data(dfs)