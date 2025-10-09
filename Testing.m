clc

WP = GenerateWaypoints(logical_map, 2)
% WP = [10, 10; 15, 15]

VisualiseMap(logical_map, WP)



% lower = 1;
% upper = 41;
% disp(round(lower + (upper-lower)*rand(), 2))