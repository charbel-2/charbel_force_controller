# Use the official ROS 2 Humble image based on Ubuntu 22.04
FROM ros:humble-ros-base-jammy

# ROS2 distribution
ARG ROS_DISTRO=humble

# workspace directory
ARG WS_DIR=/root/ros_workspaces/ros2/charbel_force_control_ws 

# load image name from outside
ARG IMAGE=charbel_force_control

# set as root
USER root

# Use "bash" as replacement for "sh"
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh
SHELL ["/bin/bash", "-c"]

# Copy the project files into the container
WORKDIR /root

### -------------------------------- ###
###   Install dependencies           ###
### -------------------------------- ###

RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt-get install -y software-properties-common
RUN add-apt-repository universe

# run the script to install dependencies (python3 + ros2 + system)
COPY ./scripts/ /root/utils/scripts/
COPY ./images/${IMAGE}/dependencies/ /root/utils/images/${IMAGE}/dependencies/

RUN chmod +x /root/utils/scripts/install_dependencies.sh && \
    /root/utils/scripts/install_dependencies.sh -i ${IMAGE}
    
COPY ./scripts/install_libfranka.sh /root/utils/scripts/

RUN chmod +x /root/utils/scripts/install_libfranka.sh && \
    /root/utils/scripts/install_libfranka.sh

ENV CMAKE_PREFIX_PATH=/usr/local:${CMAKE_PREFIX_PATH}
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
    
# Copy the MuJoCo install script
COPY ./scripts/install_mujoco.sh /root/utils/scripts/install_mujoco.sh

RUN chmod +x /root/utils/scripts/install_mujoco.sh && \
    /root/utils/scripts/install_mujoco.sh
    
COPY ./scripts/bashrc_extras.sh /root/utils/scripts/

RUN cat /root/utils/scripts/bashrc_extras.sh >> ~/.bashrc

ENV MUJOCO_PATH=/root/mujoco/mujoco-3.2.0
ENV LD_LIBRARY_PATH=${MUJOCO_PATH}/lib:${MUJOCO_PATH}/bin:${LD_LIBRARY_PATH}
    
#RUN cd /root/utils && ./scripts/install_dependencies.sh -i ${IMAGE}

RUN sudo apt-get update

### -------------------------------- ###

# Create the workspace
RUN mkdir ${WS_DIR}/src -p && cd ${WS_DIR}/src

### ------------------------------------------------------------- ###
### Use SSH build secret to clone the repositories and submodules ###
### ------------------------------------------------------------- ###

# Mount the SSH socket within the same RUN instruction to clone the repository
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR ${WS_DIR}/src

# Clone all the necessary repositories and update all the submodules
# CHANGE TO MY OWN REPO
RUN --mount=type=ssh git clone https://github.com/charbel-2/controller_setup.git

### ------------------------------------------------------------- ###


### -------------------------------- ###
###      Set cyclonedds instead of fastrtps (that sometimes seems in conflict with Docker)     ###
### -------------------------------- ###
RUN sudo apt install ros-humble-rmw-cyclonedds-cpp -y
RUN echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> ~/.bashrc


### -------------------------------- ###
###      Set ROS DOMAIN ID (to communicate with real rbkairos)     ###
### -------------------------------- ###
# RUN echo 'export ROS_DOMAIN_ID=40' >> ~/.bashrc
### -------------------------------- ###


### -------------------------------- ###
###   Install Workspace tools        ###
### -------------------------------- ###

#WORKDIR /root/utils/

#RUN --mount=type=ssh git clone https://github.com/charbel-2/controller_setup.git

#RUN --mount=type=ssh cd controller_setup && colcon build
#RUN cd controller_setup 

### --------------------------------------- ###

# source ROS2 environment
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
# ADD WHAT I NEED IN THE BASHRC FOR MULTI MACHINES

# Install missing dependencies and build workspace
WORKDIR ${WS_DIR}
    
#RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    #rosdep install -r --from-paths src -i -y && \
    #colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
