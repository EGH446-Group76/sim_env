function VisualiseMap(LogicalMap, WallPadding, WayPoints)

arguments
	LogicalMap
	WallPadding	= []
	WayPoints	= []
end

CellWidth = 10;


M = min((double(LogicalMap)+0.25), 1);

if (~isempty(WallPadding)), M = min((M + double(WallPadding)*0.25), 1); end

M = cat(3, M, M, M);


figure;
image(M)
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

if ~isempty(WayPoints)
	scatter( ...
		(WayPoints(:,1)*10), (WayPoints(:,2)*10), ...
		100, 'LineWidth',2, 'Marker','X', ...
		'MarkerEdgeColor','r', 'MarkerFaceColor', 'r' ...
	)
end
