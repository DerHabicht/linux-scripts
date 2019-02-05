#!/bin/bash

# Pop project name off the arguments list
proj_name=$1
shift

# Basic .gitignore file
read -d '' python_gitignore <<EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*\$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/
EOF

# README.md template
read -d '' readme <<EOF
# Project Title

One Paragraph of project description goes here

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

\`\`\`
Give examples
\`\`\`

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

\`\`\`
Give the example
\`\`\`

And repeat

\`\`\`
until finished
\`\`\`

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

\`\`\`
Give an example
\`\`\`

### And coding style tests

Explain what these tests test and why

\`\`\`
Give an example
\`\`\`

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
EOF

# Start script
read -d '' bash_init <<EOF
#!/bin/bash

SOURCE="\${BASH_SOURCE[0]}"
while [ -h "\$SOURCE" ]; do
    DIR="\$( cd -P "\$( dirname "\$SOURCE" )" >/dev/null && pwd )"
    SOURCE="\$(readlink "\$SOURCE")"
    [[ \$SOURCE != /* ]] && SOURCE="\$DIR/\$SOURCE"
done
DIR="\$( cd -P "\$( dirname "\$SOURCE" )" >/dev/null && pwd )"

source activate $proj_name
python \$DIR/main.py "\$@"
source deactivate
EOF

# main.py module
read -d '' main <<EOF
"""[PROJECT NAME]

Usage:
    $proj_name

Options:
    -h --help               Show this screen.
    --version               Show version.
"""
import os
import yaml
from docopt import docopt

CONFIG_PATH = f'{os.getenv("HOME")}/.config/$proj_name'
VERSION = '[PROJECT NAME] 0.1.0'
DEFAULT_CONFIG = '''
---
version: 0.1.0
...
'''


def initial_config():
    """Initialize a configuration file.

    If \$HOME/.config/$proj_name/config.yml does not already exist, this
    function will set up a minimal working config file. The default config will
    then be parsed and a config dictionary will be returned for the rest of the
    program to utilize.

    :return: a configuration dictionary based on initial setup
    """

    config = yaml.load(DEFAULT_CONFIG)
    with open(f'{CONFIG_PATH}/config.yml', 'w') as cfile:
        cfile.write(DEFAULT_CONFIG)
    print(f'Configuration file written to {CONFIG_PATH}/config.yml')

    return config


def router(arguments):
    """Command router

    Routes the arguments from the command line.

    :param arguments:  docopt arguments dictionary
    """
    pass


if __name__ == '__main__':
    # Parse configuration file
    os.makedirs(CONFIG_PATH, exist_ok=True)
    try:
        with open(f'{CONFIG_PATH}/config.yml', 'r') as cfile:
            config = yaml.load(cfile)
    except FileNotFoundError:
        config = initial_config()

    # Parse arguments
    arguments = docopt(__doc__, version=VERSION)

    router(arguments)
EOF


# Create project directory
mkdir $proj_name
cd $proj_name

# Set up Conda
conda create docopt yaml "$@" -n $proj_name
source activate $proj_name
conda env export > environment.yml
source deactivate

# Create additional files
echo "$python_gitignore" > .gitignore
echo "$readme" > README.md
echo "$main" > main.py
echo "$bash_init" > $proj_name.sh
chmod +x $proj_name.sh

# Initialize Git
git init
git add environment.yml .gitignore README.md main.py $proj_name.sh
git commit -m "Initial commit"
