%%
clc

% WP = GenerateWaypoints(logical_map, 2)
% WP = [10, 10; 15, 15]

OPP.GenerateWaypoints(2)

WPs = double(OPP.Ordered_Waypoints)


VisualiseMap(logical_map, OPP.WallPadding, WPs)


%%
clc

lower = 1;
upper = 41;
disp(round(lower + (upper-lower)*rand(), 2))


%%
clc

disp(find(logical_map))


%%

CellWidth = 10;


% M = double(LogicalMap)+0.25;
% M = cat(3, M, M, M);
% 
% if (~isempty(WallPadding))
% 	L = double(LogicalMap)*0.5;
% 	M = M + cat(3, L, L, L);
% end
% 
% M = min(M, 1);


M = logical(Problem.WallPadding);


figure;
imagesc(M);
% colormap([0.25 0.25 0.25; 1 1 1]);
colormap gray
axis image;
set(gca,'YDir','normal');	% Flips Y-axis (vertical flip).
hold on;

% Turn on gridlines:
xticks(0.5:CellWidth:size(M,2)+0.5);
yticks(0.5:CellWidth:size(M,1)+0.5);
grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 1, 'LineWidth', 0.5);

% Optional: hide tick labels
ax = gca;
ax.XTickLabel = (0:1:(520/CellWidth));
ax.YTickLabel = (0:1:(420/CellWidth));