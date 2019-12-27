# Dockerfile
# specify the builder ("builder" can be any tag)
FROM mcr.microsoft.com/windows/servercore:ltsc2016 as builder 

# set the environment information
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.0


# create and set the working directory
RUN mkdir "C:/app"
WORKDIR "C:/app"

# install git and delete the install file
COPY "Git-2.23.0-64-bit.exe" git.exe
RUN git.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
RUN del git.exe

# install node and delete the install file
COPY "node-v12.13.0-x64.msi" node.msi
### Optionally, the installer could be downloaded as follows (not recommended)
# Invoke-WebRequest $('https://nodejs.org/dist/v{0}/node-v{0}-x64.msi' -f $env:NODE_VERSION) -OutFile 'node.msi'
RUN msiexec.exe /q /i node.msi
RUN del node.msi

# install node and delete the install file
COPY "python-2.7.amd64.msi" python.msi
RUN msiexec.exe /q /i python.msi
RUN del python.msi

# falling back to the npm http registry overcomes some issues with proxy servers
RUN npm config set strict-ssl false
RUN npm config set registry https://registry.npmjs.org/
RUN npm config set python "C:/Python27/python.exe"
WORKDIR "C:/app"

# here is where the app directory (including package.json and index.js files) is copied
COPY . "C:/app"

# Install dependencies

RUN npm install --global --production windows-build-tools --vs2015
RUN npm config set msvs_version 2015 -–global
RUN npm install --global node-gyp
