function Ordered_Waypoints = GenerateWaypoints(LogicalMap, seed, N_WPs, X_lim, Y_lim, InitPos)

arguments
	LogicalMap
    seed			{mustBeInteger}						= 0
    N_WPs			{mustBeInteger, mustBeNonnegative}	= 10
    X_lim	(1, 2)	{mustBeInteger, mustBeNonnegative}	= [1 52]
    Y_lim	(1, 2)	{mustBeInteger, mustBeNonnegative}	= [1 41]
	InitPos	(1, 2)	{mustBeInteger, mustBeNonnegative}	= [2 2]
end


%% Setting RNG Seed

if (seed == 0),	rng;
else,			rng(seed);
end


%% Generating WPs:

Waypoints = zeros(N_WPs, 2);

for i = 1:N_WPs

	while true
		WP_x = round(X_lim(1) + (X_lim(2)-X_lim(1))*rand(), 1);
		WP_y = round(Y_lim(1) + (Y_lim(2)-Y_lim(1))*rand(), 1);
		if (~LogicalMap( (WP_y*10), (WP_x*10) ))
			break
		end
	end
	
	Waypoints(i, :) = [WP_x; WP_y];
end



%% Parsing and Initialisation of WPs:


WP_List = repmat(struct("Pos", zeros(1, 2), "Visited", false), 1, N_WPs);

% Turning the List of WPs into a Struct Array (so each WP can have its own boolean "Visited" flag):
for k = 1:N_WPs, WP_List(k).Pos = Waypoints(k, :); end



%% Ordering List of WPs:

Optimised_WP_Indices = zeros(1, N_WPs);

CurrentPos = InitPos;

for i = 1:N_WPs
	
	Closest_WP.Idx  = 0;
	Closest_WP.Dist = inf;
	
	for j = 1:N_WPs
		if WP_List(j).Visited == false
		
			Dist_2_WP = sqrt( (WP_List(j).Pos(1)-CurrentPos(1))^2 + (WP_List(j).Pos(2)-CurrentPos(2))^2 );
			if Dist_2_WP < Closest_WP.Dist
				Closest_WP.Idx  = j;
				Closest_WP.Dist = Dist_2_WP;
			end
        
		end
	end


	if Closest_WP.Idx ~= 0
		CurrentPos                      = WP_List(Closest_WP.Idx).Pos;
		Optimised_WP_Indices(i)         = Closest_WP.Idx;
		WP_List(Closest_WP.Idx).Visited = true;
	else
		error('Failed to find an applicable WP upon Optimising Path.');
	end

end


WP_List = WP_List(Optimised_WP_Indices);

Ordered_Waypoints = cell2mat({WP_List.Pos}');
