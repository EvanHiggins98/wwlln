import matlab.engine
import sys
from wwlln.scripts.custom_logging import _globalLogger

_MATLAB_ENGINE_PATH = ""
_MATLAB_SCRIPTS_PATH = "TCDataProcessing/scripts/matlab"
_PYTHON_SCRIPTS_PATH = "TCDataProcessing/scripts/python"

def script_engine_setup():
    sys.path.append(_MATLAB_ENGINE_PATH)

def run_script(script_name, function_name="", parameters=""):
    if(script_name[-1]=='m'):
        return run_matlab_script(script_name+function_name,parameters)
    return run_python_script(script_name, function_name,parameters)

def run_matlab_script(function_name,parameters='nargout=0'):
    _globalLogger.log_message("Attempting to run MATLAB scrypt: {scrypt_str}".format(scrypt_str=function_name), _globalLogger._INFO)
    eng = matlab.engine.start_matlab()
    eng.cd(_MATLAB_SCRIPTS_PATH,nargout=0)
    return eval("eng." + function_name+"("+parameters+")",{},{'eng':eng})

def run_python_script(script_name, function_name,parameters=''):
    _globalLogger.log_message("Attempting to run PYTHON scrypt: {scrypt_str}".format(scrypt_str=function_name), _globalLogger._INFO)
    exec("import "+_PYTHON_SCRIPTS_PATH+script_name)
    return eval(script_name+"."+function_name+"("+parameters+")")
