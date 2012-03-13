#!/usr/bin/env python
"""Downloads and unpacks the Github archives for a project's submodules"""
import optparse
import os
import ConfigParser
import re
import StringIO
import urlparse
import urllib
import zipfile

path = os.path

def main():
    p = optparse.OptionParser()
    p.add_option('--recursive', '-r', default=True)
    options, arguments = p.parse_args()

    if len(arguments)== 1 and path.exists(path.abspath(arguments[0])):
        handle_module_file(arguments[0])
    else:
        print "No file specified"
        p.print_help()

def handle_module_file(pathToFile):
    #os.chdir(path.dirname(pathToFile))
    with open(pathToFile, 'r') as moduleFile:
        print "Fetching submodules in {0}".format(pathToFile)
        os.chdir(path.dirname(path.abspath(pathToFile)))
        moduleSafeFile = StringIO.StringIO(
                re.sub('\t|    ', '', moduleFile.read()))

        submodules = ConfigParser.SafeConfigParser()
        submodules.readfp(moduleSafeFile)
        for module in submodules.sections():
            handle_module(dict(submodules.items(module)))

def handle_module(module):
    """Looks at a submodule's local and remote location,
    then download the github tarball for the remote and expand it to the
    local"""
    url = download_from_git(module['url'])
    name = path.basename(module['path'])
    print '  Fetching {0} from "{1}"'.format(name, url)
    zipball, hdrs = urllib.urlretrieve(url)
    print "    download of {0} finished.".format(name)
    package = zipfile.ZipFile(zipball)
    extract_package_to_location(package, module['path'])


def download_from_git(url):
    """Returns the zipball location on master for a Github repo URL"""
    parsed = urlparse.urlparse(url)
    return urlparse.urljoin(url, parsed.path.split('.')[0] + '/zipball/master')

def extract_package_to_location(package, path):
    print package.namelist()



if __name__ == '__main__':
    main()
