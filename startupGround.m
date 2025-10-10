%% Clear Workspace:

clear all
clc
disp("Starting Up Ground Environment...")


%% Close Previously Open Model:

close_system('sl_groundvehicleDynamics',0);
 

%% Add Toolboxes to Path:

homedir = pwd; 
addpath( genpath(strcat(homedir,[filesep,'toolboxes'])));

cd('toolboxes/MRTB');
startMobileRoboticsSimulationToolbox;

cd(homedir);


%% Setup Python Venv and Path:

% Ensure Python Environment is Properly Setup:
[status, ~] = system(sprintf('powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%s"', fullfile(homedir, 'SetupVenv.ps1')), '-echo');
if status ~= 0, error("Failed to run 'SetupEnv.ps1' (status %d):\n%s", status, out); end


% Configure MATLAB to use the Project's Python Venv:
disp(pyenv('Version', fullfile(homedir, 'venv', 'Scripts', 'python.exe')))
disp('')

% Ensure Python Module Path is Included:
if count(py.sys.path, fullfile(pwd, 'Python')) == 0, insert(py.sys.path, int32(0), fullfile(homedir, 'Python')); end


%% Open Current Model:

cd('toolboxes/ground_robot');
open_system('sl_groundvehicleDynamics.slx');
cd(homedir);

close all;



%% Load in Part B [map] and [obstacles]

load('complexMap_air_ground.mat');

load('obstacles_air_ground.mat');

% reversing the oder of the rows (Y-pos)
logical_map = flipud(logical_map);


%% Instansiate Problem Object:

disp("Initialising the Offline Path-Planner...")
OPP = py.OfflinePathPlanner.OfflinePathPlanner(logical_map, 4);
disp("Finished Initialising Offline Path-Planner.")
disp(""); disp("");


%% Initialise Goal Waypoints:


Waypoints = double(OPP.Waypoints)

% Ordered_Waypoints = [10, 10; 15, 15]
