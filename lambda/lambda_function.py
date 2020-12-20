from rw_csv.rw_ops import parse_csv

def lambda_handler(event, context):
    parse_csv(event)
