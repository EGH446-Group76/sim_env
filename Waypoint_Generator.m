clc

%% Parameters setup:

N_WPs           = 10;

XWorldLimits = [0 52];
YWorldLimits = [0 41];



%% Generating WPs:

rng;

WP_X = randi(XWorldLimits, N_WPs, 1);
WP_Y = randi(YWorldLimits, N_WPs, 1);

Waypoints = [WP_X(:) WP_Y(:)]




%% Parsing and Initialisation of WPs:


WP_List = repmat(struct("Pos", zeros(1, 2), "Visited", false), 1, N_WPs);

% Turning the List of WPs into a Struct Array (so each WP can have its own boolean "Visited" flag):
for k = 1:N_WPs, WP_List(k).Pos = Waypoints(k, :); end



%% Ordering List of WPs:

Optimised_WP_Indices = zeros(1, N_WPs);

CurrentPos = zeros(1, 2);

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

Ordered_Waypoints = cell2mat({WP_List.Pos}')


