import logging

"""
TODO

-add custom flags eg: automation, data collection, display, etc
-remove trailing log file text
"""

"""
NONE         (-1) - Used to Disable Printing

-VVV LEVELS USED BY PYTHON LOGGING VVV-
ALL (NOTSET) ( 0) - Used to Print all messages
DEBUG        (10) - Used to print messages to debug an application.
INFO         (20) - Used to print general messages such as affirmations, confirmations, and success messages.
WARNING      (30) - Used to report warnings, unexpected events due to inputs, indications for some problems that might arise in the future, etc.
ERROR        (40) - Used to alert about serious problems that most probably will not stop the application from running.
CRITICAL     (50) - Used to alert about critical issues that can harm the user data, expose the user data, hinder security, stop some service, or maybe end the application itself.
"""

class CustomLogger:
    _NONE     = -1
    _ALL      = logging.NOTSET
    _DEBUG    = logging.DEBUG
    _INFO     = logging.INFO
    _WARNING  = logging.WARNING
    _ERROR    = logging.ERROR
    _CRITICAL = logging.CRITICAL

    def __init__(self, _printLevel : int = _ALL, _printToConsole : bool = True, _printToFile : bool = True, _logFileName : str = "wwlln.log", _logTime : bool = True):
        self.printLevel : int = _printLevel
        self.printToConsole : bool = _printToConsole
        self.printToFile : bool = _printToFile
        self.logFilePath : str = "./wwlln/logs/" + _logFileName
        self.logTime : bool = _logTime
        
        if self.printToFile:
            print("Logging To File/Console ENABLED")
            self.__logging_setup_file()
        elif self.printToConsole:
            print("Logging to Console ENABLED")
            self.__logging_setup_nofile()
        else:
            print("Warning: Logging DISABLED")
        
        self.log_message("BEGIN LOG", self._INFO)
    
    """
    Change rollover period to happen at midnight?
    """
    def __logging_setup_file(self):
        # set up logging to file
        logging.basicConfig(level=self.printLevel,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='[%d/%b/%Y %H:%M:%S]',
                    filename=self.logFilePath,
                    filemode='w')
        handler = logging.handlers.TimedRotatingFileHandler(self.logFilePath, when='H', interval=1, backupCount=23)
        logging.getLogger('').addHandler(handler)

        if self.printToConsole:
            # define a Handler which writes [LEVEL] messages or higher to the sys.stderr
            console = logging.StreamHandler()
            console.setLevel(self.printLevel)
            # set a format which is simpler for console use
            formatter = logging.Formatter(fmt='%(asctime)s %(name)-12s %(levelname)-8s %(message)s', datefmt='[%d/%b/%Y %H:%M:%S]',)
            # tell the handler to use this format
            console.setFormatter(formatter)
            # add the handler to the root logger
            logging.getLogger('').addHandler(console)
    
    def __logging_setup_nofile(self):
        logging.basicConfig(level=self.printLevel,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='[%d/%b/%Y %H:%M:%S]',)
    
    """
    special flags to be implimented later
    """
    def log_message(self, message : str, priorityLevel : int = _DEBUG, special=None):
        if self.printLevel < self._ALL or priorityLevel < self._NONE:
            return
        if priorityLevel == self._ALL:
            priorityLevel = self.DEBUG
        
        logging.log(priorityLevel, message)
        
        
    


_globalLogger = CustomLogger()

"""
Example call:

from wwlln.scripts.custom_logging import _globalLogger

_globalLogger.log_message("Requesting to view storm #{Storm}".format(Storm=storm), _globalLogger._DEBUG)
"""