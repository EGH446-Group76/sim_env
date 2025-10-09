%% clear Workspace

clear all
clc
disp("Starting Up Ground Environment...")


%% close previously open model

close_system('sl_groundvehicleDynamics',0);
 

%% add toolboxes to path

homedir = pwd; 
addpath( genpath(strcat(homedir,[filesep,'toolboxes'])));

cd('toolboxes/MRTB');
startMobileRoboticsSimulationToolbox;

cd(homedir);


%% open current model

open_system('sl_groundvehicleDynamics'); %differential robot

cd(homedir);


%% load in Part B [map] and [obstacles]

load('complexMap_air_ground.mat');

load('obstacles_air_ground.mat');

% reversing the oder of the rows (Y-pos)
logical_map = flipud(logical_map);


%% creating [Ordered_Waypoints]

Ordered_Waypoints = GenerateWaypoints(logical_map)

% Ordered_Waypoints = [10, 10; 15, 15]
