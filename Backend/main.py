# first build docker image: docker build -t backend-commission-compass
# then create container: docker run -it --name backend-cc-container ./[DIRECTORY OF THE PYTHON FILE]

# to run: docker start -ai backend-cc-container
from zai import ZaiClient

print("Hello World")