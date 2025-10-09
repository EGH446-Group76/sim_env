function VisualiseMap(LogicalMap, WayPoints)

arguments
	LogicalMap 
	WayPoints = []
end


M = LogicalMap;

CellWidth = 10;

figure;
imagesc(M);
colormap([0.25 0.25 0.25; 1 1 1]);
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
	% *Code to plot WayPoints*
end

if ~isempty(WayPoints)
	scatter( ...
		(WayPoints(:,1)*10), (WayPoints(:,2)*10), ...
		100, 'LineWidth',2, 'Marker','X', ...
		'MarkerEdgeColor','r', 'MarkerFaceColor', 'r' ...
	)
end
