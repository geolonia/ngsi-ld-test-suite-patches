import datetime


def is_date(date, format):
    """Function exposed as a keyword to check whether the string can be interpreted as a date of given format
    :param date: string to check for date
    :param format: date format
    """
    try:
        datetime.datetime.strptime(date, format)
        return True
    except ValueError:
        return False
