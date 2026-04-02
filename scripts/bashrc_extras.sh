# MuJoCo 3.2.0
export MUJOCO_HOME="$HOME/mujoco/mujoco-3.2.0"

export PATH="$MUJOCO_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$MUJOCO_HOME/bin:${LD_LIBRARY_PATH-}"
export LD_LIBRARY_PATH="$MUJOCO_HOME/bin:$MUJOCO_HOME/lib:${LD_LIBRARY_PATH-}"

export MUJOCO_MODEL_PATH="$HOME/simulation_ws/src"

alias sim_panda='simulate "$MUJOCO_MODEL_PATH/franka_panda/panda.xml"'
alias sim_panda_scene='simulate "$MUJOCO_MODEL_PATH/franka_panda/scene.xml"'
alias sim_panda_scene_withcube='simulate "$MUJOCO_MODEL_PATH/franka_panda/mjx_single_cube.xml"'

# Plotjuggler
alias plotjuggler='/opt/ros/humble/lib/plotjuggler/plotjuggler &'

# Quick ROS-2 bridge launch for that same scene
alias ros2_mj_panda_scene='ros2 run mujoco_ros2 mujoco_node \
  "$MUJOCO_MODEL_PATH/franka_panda/panda_nohand_ros2.xml" \
  --ros-args \
    -p joint_state_topic_name:=/joint_states \
    -p joint_command_topic_name:=/joint_commands \
    -p control_mode:=POSITION \
    -p simulation_frequency:=1000 \
    -p visualisation_frequency:=60'
    
export ROS_DOMAIN_ID=28
export ROS_LOCALHOST_ONLY=0
export ROS_DEFAULT_RMW_IMPLEMENTATION=rmw_fastrtps_cpp
