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


%% creating [Ordered_Waypoints]

run("Waypoint_Generator.m")
