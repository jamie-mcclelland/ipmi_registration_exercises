function dispDefField(def_field, spacing, type)
%function to display a deformation field
%
%INPUTS:    def_field: the deformation field as a 3D array
%           spacing: the spacing of the grids/arrows in pixels [5]
%           type: the type of display to use, 'grid' or 'arrows' ['grid']

%set default values if parameters not set
if ~exist('spacing','var') || isempty(spacing)
    spacing = 5;
end
if ~exist('type','var') || isempty(type)
    type = 'grid';
end

%calculate coordinates for plotting grid-lines/arrows
plot_x = 1:spacing:size(def_field,1);
plot_y = 1:spacing:size(def_field,2);

%calculate coordinates for all pixels in def field
all_ys = 1:size(def_field,2);
all_xs = 1:size(def_field,1);


switch type
    case 'grid'
        
        %plot vertical grid lines
        plot(def_field(plot_x, all_ys, 1)', def_field(plot_x, all_ys, 2)', 'k');
        hold on
        %plot horizontal grid lines
        plot(def_field(all_xs, plot_y, 1), def_field(all_xs, plot_y, 2), 'k');
        hold off
        
    case 'arrows'
        
        %calculate displacement field from deformation field
        [X_all, Y_all] = ndgrid(all_xs - 1, all_ys - 1);
        disp_field_x = def_field(:,:,1) - X_all;
        disp_field_y = def_field(:,:,2) - Y_all;
        
        %plot displacements using quiver
        [X_plot, Y_plot] = ndgrid(plot_x - 1, plot_y - 1);
        quiver(X_plot, Y_plot, disp_field_x(plot_x, plot_y), disp_field_y(plot_x, plot_y),0);
        
    otherwise
        error('type must be grid or arrows');
end

%set axis limits and appearance
axis equal
axis tight
xlim([-1 size(def_field,1)]);
ylim([-1 size(def_field,2)]);