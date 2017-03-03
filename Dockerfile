FROM ros:indigo
MAINTAINER Erez Karpas

# Install needed libraries
RUN apt-get update
RUN apt-get install -y software-properties-common build-essential git-core g++ vim asciidoc doxygen \
  libmagic-dev libssl-dev libavahi-client-dev libsqlite3-dev libxml++2.6-2 libxml++2.6-dev \
  libdaemon-dev liblua5.1-0-dev libtolua++5.1-dev \
  libboost-dev libdc1394-22-dev libbluetooth-dev libbullet-dev libelf-dev \
  libjpeg-dev libtiff4-dev libjpeg8-dev libjpeg-turbo8-dev libpng12-dev libpcl-1.7-all-dev \
  libopencv-dev libopencv-objdetect-dev libopencv-highgui-dev libopencv-calib3d-dev \
  libopencv-features2d-dev libopencv-legacy-dev libopencv-contrib-dev \
  librrd-dev graphviz libgraphviz-dev flite1-dev libasound2-dev \
  robot-player-dev libplayerc3.0-dev libcgal-dev \
  libgl1-mesa-dev freeglut3-dev libsdl1.2-dev liburg0-dev \
  libgtkmm-3.0-dev libcairomm-1.0-dev libgconfmm-2.6-dev \
  libprotobuf-dev libprotoc-dev protobuf-compiler \
  mongodb-dev mongodb-server ccache libncurses5-dev libmicrohttpd-dev libyaml-cpp-dev \
  libxmlrpc-c++8-dev emacs24 gazebo5 gazebo5-plugin-base libgazebo5-dev \
  ros-indigo-desktop ros-indigo-move-base wget python-rosinstall \
  git-core python-argparse python-wstool python-vcstools python-rosdep \
  flex ros-indigo-mongodb-store ros-indigo-tf2-bullet freeglut3-dev \
  ros-indigo-tf2-geometry-msgs

# Install the CLIPS library
RUN add-apt-repository -y ppa:timn/clips
RUN apt-get update
RUN apt-get install -y libclipsmm-dev

# Install g++-4.9
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install -y g++-4.9

# Make sure we have ROS set up
RUN /bin/bash -c "source /opt/ros/indigo/setup.bash"

# Crate our working directory
RUN mkdir /home/rcll
WORKDIR /home/rcll

# Setup the ROS packages needed to build fawkes
WORKDIR /home/rcll
RUN mkdir -p ros_fawkes_ws/src
WORKDIR /home/rcll/ros_fawkes_ws/src
RUN /bin/bash -c ". /opt/ros/indigo/setup.bash; catkin_init_workspace /home/rcll/ros_fawkes_ws/src"
RUN wstool init .
RUN wstool merge https://raw.githubusercontent.com/karpase/ros-rcll_rosinstall/master/ros_fawkes.rosintall
RUN wstool update
WORKDIR /home/rcll/ros_fawkes_ws
RUN /bin/bash -c ". /opt/ros/indigo/setup.bash; cd /home/rcll/ros_fawkes_ws; catkin_make"
RUN /bin/bash -c "source /home/rcll/ros_fawkes_ws/devel/setup.bash"

# Setup fawkes
WORKDIR /home/rcll
RUN wget https://files.fawkesrobotics.org/releases/fawkes-robotino-2015.tar.bz2
RUN bunzip2 fawkes-robotino-2015.tar.bz2
RUN tar -xvf fawkes-robotino-2015.tar                  
WORKDIR /home/rcll/fawkes-robotino
RUN make clean all gui

# Setup the ROSPlan/RCLL interface packages
WORKDIR /home/rcll
RUN mkdir -p rosplan_ws/src
WORKDIR /home/rcll/rosplan_ws/src
RUN /bin/bash -c ". /home/rcll/ros_fawkes_ws/devel/setup.bash; catkin_init_workspace /home/rcll/rosplan_ws/src"
RUN wstool init .
RUN wstool merge https://raw.githubusercontent.com/karpase/ros-rcll_rosinstall/master/rcll_rosplan.rosinstall
RUN wstool update
WORKDIR /home/rcll/rosplan_ws
RUN /bin/bash -c ". /opt/ros/indigo/setup.bash; /home/rcll/rosplan_ws; CC=gcc-4.9 CXX=g++-4.9 CFLAGS=-std=c++1y CXXFLAGS=-std=c++1y catkin_make"




