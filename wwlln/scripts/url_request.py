import urllib.request
import re
import datetime

_URL_REQUEST_TIMEOUT_S = 20
date_time_re_patterns = ['\\d{2}-.{3}-\\d{4} \\d{2}:\\d{2}',
                    '\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}']

date_time_parse_patterns = ['%d-%b-%Y %H:%M',
                    '%Y-%m-%d %H:%M']

def request_url_contents(url, username='',password = '',decode=False,decoder='utf-8'):
    pass_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    pass_mgr.add_password(None,url,username,password)
    authHandler = urllib.request.HTTPBasicAuthHandler(pass_mgr)
    opener = urllib.request.build_opener(authHandler)
    with opener.open(url, timeout=_URL_REQUEST_TIMEOUT_S) as result:
        result_info = result.info()
        content = result.read()
        content_string = content.decode(decoder)
        if(result_info.get_content_maintype()=='text' and result_info.get_content_subtype()=='html'):
            pattern = re.compile(r'(?<=\<title\>).*?(?=\<\/title\>)')
            if(pattern.search(content_string).group(0)=='oops!'):
                return None
        if decode:
            return content_string
        return content

def request_list_dir(url, username='', password=''):
    href_pattern = re.compile(r'(?<=\<a href\=\")(?P<dir>.*?)(?=\"\>(?P=dir)\<\/a\>)')
    last_modified_pattern = re.compile('(?:'+')|(?:'.join(date_time_re_patterns)+')')
    contents = request_url_contents(url,username,password,decode=True)
    if(not contents):
        return None
    last_modified = last_modified_pattern.findall(contents)
    for i in range(len(last_modified)):
        dt = last_modified[i]
        date_time_parse_string = ''
        for j in range(len(date_time_re_patterns)):
            if(re.compile(date_time_re_patterns[j]).match(dt)):
                date_time_parse_string = date_time_parse_patterns[j]
                last_modified[i] = datetime.datetime.strptime(dt,date_time_parse_string)
    return ({'dirs': re.findall(href_pattern,contents),
            'last_modified': last_modified
            })

def createURL(*urls):
    urls=list(urls)
    for i in range(len(urls)):
            urls[i]=urls[i].strip('\\/')
    return '/'.join(urls)
    