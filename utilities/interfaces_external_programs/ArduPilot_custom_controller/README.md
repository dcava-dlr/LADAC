# Implement your MATLAB/Simulink controller in ArduPilot for flight tests

This is a toolchain which implements your MATLAB/Simulink controller in ArduPilot.
Currently supported: ArduCopter and ArduPlane.  
Note that the ArduPlane patch also contains a custom interface to ArduPilot SITL with UDP connection (see [ArduPilot SITL interface of LADAC](../ArduPilot_SITL)).

## Motivation

If you design your controllers for an existing vehicle, you have to implement your controller on the electronic control unit of your vehicle.
Since the controller is only a (small) part of the software running on the electronic control unit, it might be beneficial to implement the controller in an existing software like ArduPilot. 
ArduPilot supports different boards and sensors, it allows communication via MAVLink and also provides a state estimator (EKF) if needed. 
Moreover, you can perform software in the loop (SITL) simulations and keep standard ArduPilot flight modes if you want.
Here, the implementation of your MATLAB/Simulink controller in ArduPilot is discribed.

## Installation

- You must install [LADAC](../../../README.md) (you need the MATLAB Coder and Simulink Embedded Coder).
- You must install the [ArduPilot SITL](https://ardupilot.org/dev/docs/SITL-setup-landingpage.html).
- Assumption: These instruction assume that you have a basic understanding of ArduPilot and the ArduPilot SITL. Please also note the [ArduPilot SITL interface of LADAC](../ArduPilot_SITL).


## Tests

This unit test shows you how it works and it can be used for verification.
Therefore, a dummy controller from MATLAB/Simulink is implemented in ArduCopter or ArduPlane.
Take a look at the Simulink model `ArduCopter_TemplateController` in the [ArduCopter](ArduCopter) subfolder and the `ArduPlane_ManualMode` in the [ArduPlane](ArduPlane) subfolder.
They contain the dummy controller in the middle.
On the left and on the right, there are interfaces to the ArduPilot code.
In this case, the dummy controller sends constant values to the actuators and it logs some states.  
Brief explanation: To get to run your MATLAB/Simulink controller in ArduPilot you must modify the ArduPilot code (files provided here) and generate C++ code from your Simulink model that you must insert in the ArduPilot code.

Note that the steps are different for ArduCopter and ArduPlane because the patches are not based on the same ArduPilot version/commit (this will be changed in the future).  
The ArduCopter test is explained first, the ArduPlane test is explained afterwards.

### ArduCopter

1. Checkout commit `999c269` of your ArduPilot clone (only tested for this commit).
   ```
   cd <path_to_ardupilot>
   git checkout -b matlab_test 999c269
   git submodule update --init --recursive
   ```
2. Copy and apply the ArduCopter patch to your local ArduPilot repository.
   ```
   cp <path_to_LADAC>/utilities/interfaces_external_programs/ArduPilot_custom_controller/ArduCopter/Patch/LADAC_ArduCopter_f69be707.patch <path_to_ardupilot>/..
   git apply ../LADAC_ArduCopter.patch
   ./waf clean
   ```
3. Test the code in ArduPilot software in the loop (SITL).
   - Compile the code and start the ArduCopter SITL:
      ```
      sim_vehicle.py -v ArduCopter
      ```
   - Switch to the MATLAB/Simulink flight mode via the [MAVProxy command prompt](https://ardupilot.org/dev/docs/copter-sitl-mavproxy-tutorial.html#copter-sitl-mavproxy-tutorial) (same console that runs `sim_vehicle.py`):  
     ```
     mode 29
     ```
   - Arm the vehicle:
     ```
     arm throttle
     ```
   - Terminate the simulation with `Cntrl+C`.
   - You can now review the [logs](https://ardupilot.org/dev/docs/using-sitl-for-ardupilot-testing.html). The actuator commands should be equal to the outputs of the MATLAB/Simulink dummy controller.
   Moreover, there should be a `ML` struct which contains the custom logs of the MATLAB/Simulink dummy controller.
4. Upload the code on your board.  
  - You can build the code for supported boards and upload it according to the [Building ArduPilot documentation](https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md).
  - For example, if your board is a Pixhawk 1, use the following commands:
    ```
    ./waf configure --board Pixhawk1
    ./waf copter
    ./waf --upload copter
    ```
    (Note that you have to replace `copter` with `plane` if you want to build ArduPlane.)
5. Test the MATLAB/Simulink controller in flight tests **(CAUTION: THIS MIGHT BE DANGEROUS, PLEASE ASSURE SAFETY ARRANGEMENTS!)**.
   - Only do flight tests after careful and comprehensive [SITL tests](../ArduPilot_SITL/README.md).
   - Only do flight tests at dedicated terrain.
   - Only do flight tests if you are sure that you can deactivate the MATLAB/Simulink controller at all times.
   - Only do flight tests if you have implemented a radio failsafe action that will cause acceptable reactions of the quadcopter in case of transmitter/receiver connection loss.


### ArduPlane

For ArduPlane the procedure is very similar to the procedure of ArduCopter.
Step 1-3 must be adjusted as follows. For the remaining steps please follow the ArduCopter procedure.

1. Checkout commit `6711c479` of your ArduPilot clone (only tested for this commit).
   ```
   cd <path_to_ardupilot>
   git checkout -b matlab_test 6711c479
   git submodule update --init --recursive
   ```
2. Copy and apply the ArduPlane patch to your local ArduPilot repository.
   ```
   cp <path_to_LADAC>/utilities/interfaces_external_programs/ArduPilot_custom_controller/ArduCopter/Patch/LADAC_ArduPlane_6711c479.patch <path_to_ardupilot>/..
   git apply ../LADAC_ArduPlane_6711c479.patch
   ./waf clean
   ```
3. Test the code in ArduPilot software in the loop (SITL).
   - Compile the code and start the ArduPlane SITL:
      ```
      sim_vehicle.py -v ArduPlane
      ```
   - Switch to the MATLAB/Simulink flight mode via the [MAVProxy command prompt](https://ardupilot.org/dev/docs/copter-sitl-mavproxy-tutorial.html#copter-sitl-mavproxy-tutorial) (same console that runs `sim_vehicle.py`):  
     ```
     mode 25
     ```
   - follow ArduCopter procedure.


## How to use?

- Work through the [Tests](#Tests) section in the first place.
- Make a copy of one of the `MatlabController` template Simulink files, insert your controller block and connect the inputs and outputs with the Simulink blocks in `LADAC/utilities/interfaces_external_programs/ardupilot_custom_controller`. You have to initialize the Simulink bus objects and the sample time in the first place in Matlab:
  ```
  initInterfaceBuses
  cntrl.sample_time = 1/400
  ```
  If you need interfaces that are not supported by the LADAC blocks, you have to adjust the `initInterfaceBuses.m` and the `mode_custom.cpp` in the ArduPilot patch and probably other files in the ArduPilot patch, see [Contribute](Contribure) section.
- Generate C/C++ code from the Simulink file: https://de.mathworks.com/help/dsp/ug/generate-c-code-from-simulink-model.html
Note that floating points should be 32-bit! This is assured in the Simulink template files because the following parameters were set: `set_param(gcs, 'DefaultUnderspecifiedDataType', 'single')` and `set_param(gcs, 'DataTypeOverride', 'Single','DataTypeOverrideAppliesTo','Floating-point')`
- You need only four files of the generated code: `MatlabController.cpp`, `MatlabController.h`, `MatlabController_data.cpp` and `rtwtypes.h`. 
  If you used referenced systems, there might be additional files (the code generation report will tell you which files are needed).
  Store these files in one folder and copy the content into your local ArduPilot repository.  
  **ArduCopter:**
  ```
  cp -rf <your_source_folder>/. <path_to_ardupilot>/libraries/AC_AttitudeControl/
  ```
  **ArduPlane:**
  ```
  cp -rf <your_source_folder>/. <path_to_ardupilot>/libraries/AP_Common/
  ```
  (Note that the folder must be on the ArduPilot path or you will get a linker error.)
- You should now be able to compile the modified ArduPilot project and use flight mode 26 (ArduCopter) or mode 25 (ArduPlane).  
Note that it is probably required to delete the `build` folder in your local ArduPilot repository or to perform a `./waf clean`.


## Contribute

The ArduPilot modifications were developed in an [ArduPilot fork on Github](https://github.com/ybeyer/ardupilot.git).  
The ArduCopter modifications were developed in the `Copter-Matlab` branch.
The ArduPlane modifications were developed in the `Plane-Matlab` branch.  

If you generally want to understand how the interface works or if you want to use a different ArduPilot commit, you may have to look inside the ArduPilot code. 
This is a guide of how to adjust the code.

For each step there is a git commit in the ArduPilot fork. 
Please study the git commits. 
The diff and the commit message should be comprehensible.
In general, it is recommended to [learn the ArduPilot code](https://ardupilot.org/dev/docs/learning-the-ardupilot-codebase.html) and to [use an IDE with debugger (e.g. VS Code with GDB)](https://ardupilot.org/dev/docs/debugging-with-gdb-on-linux.html).  
The Ardupilot Version was updated to 4.2.0 and some minior changes implemented.

**ArduCopter:**
  1. Create new custom flight mode (see commit `fa17eec3`).
  2. Change a compiler flag to avoid errors (see commit `49a72363`).
  3. Get measured values and commanded values in the new custom flight mode (see commit `c878dc3b`).
  4. Integrate the MATLAB/Simulink controller (C/C++ code) (see commit `fca5741a`).
  5. Send motor commands (This is somewhat complicated because no way was found without modifying the ArduCopter main loop. Two soluations are presented.).
     1. Send motor commands directly and deactivate all standard ArduCopter flight modes (easy) (see commit `d3561c69`).
     2. Send motor command maintaining all standard ArduCopter flight modes (more difficult) (see commit `3ee0bbc1`).  

**ArduPlane:**  
Take a look at the commits `ac83a79a`, `d7de0039`, `7d5df96d`, `9170301e`, `b7032a62`, `77f85326`, `71be8f5d`.