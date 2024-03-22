from datetime import datetime
import re


def is_date(date, format):
    """Function exposed as a keyword to check whether the string can be interpreted as a date of given format
    :param date: string to check for date
    :param format: date format
    """
    try:
        datetime.strptime(date, format)
        return True
    except ValueError:
        return False


def parse_ngsild_date(date_string):
    """Function used in checks to assert if a received date is compliant with the NGSI-LD format
    :param date_string: string to check for date
    """
    try:
        # timestamp with milliseconds separated by a comma (v1.3+)
        match = re.match(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{1,6}Z", date_string)
        if match:
            return datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S,%fZ")

        # timestamp with milliseconds separated by a dot (v1.4+)
        match = re.match(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,6}Z", date_string)
        if match:
            return datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S.%fZ")

        # timestamp without milliseconds
        match = re.match(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", date_string)
        if match:
            return datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%SZ")

        # unknown timestamp format
        return None
    except ValueError:
        return None
