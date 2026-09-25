# Importa as Bibliotecas e define uma constante do caminho da pasta raw

from pathlib import Path
import pandas as pd


FOLDER_RAW = Path("../data/raw")
FOLDER_PROCESSED = Path("../data/processed")

def extract_raw_data() -> dict[str, pd.DataFrame]:
    """
    Lê os arquivos CSV da pasta raw e retorna um dicionário de DataFrames.

    Returns
    -------
    dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames correspondentes aos arquivos
        CSV da pasta raw.
    """

    files = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv"
    }

    dfs = {
    name: pd.read_csv(FOLDER_RAW / file)
    for name, file in files.items()
    }

    return dfs


def extract_processed_data() -> dict[str, pd.DataFrame]:
    """
    Lê os arquivos CSV da pasta processed e retorna um dicionário de DataFrames.

    Returns
    -------
    dict[str, pd.DataFrame]
        Dicionário contendo os DataFrames correspondentes aos arquivos
        CSV da pasta processed.
    """

    files = {
    "customers": "customers.csv",
    "orders": "orders.csv",
    "order_items": "order_items.csv",
    "products": "products.csv",
    "sellers": "sellers.csv"
    }

    dfs = {
    name: pd.read_csv(FOLDER_PROCESSED / file)
    for name, file in files.items()
    }

    return dfs