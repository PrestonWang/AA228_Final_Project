%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nathan Wei
% Stanford University Department of Mechanical Engineering
% AA 228 Final Project, Fall 2019
%
% Script for formatting figures for use in written materials. Adapted from
% formatfigs.m from the Göttingen active-grid project (2017) and the same
% script from the Darmstadt unsteady-aerodynamics projects (2017-2019).
% Dependencies: export_fig
% Created: 29.05.2018
% Updated: 04.12.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------------------- USER INPUTS ---------------------------- %%

pick_fig    = 1; % override fig_name / fig_dir and get figure manually if 1
save_fig    = 1; % export as .eps and save revised .fig if 1
% These fields are only used if pick_fig = 0
fig_name    = 'all correlations paper.fig'; % figure to modify
save_name   = 'Fig9.eps'; % name to save .eps version under
fig_dir     = 'C:\Users\njwei\Documents\Stanford\Research\Publications\2019 3D-PTV\Figures'; % where .fig lives

fsize_axesL = 18; % font size for axes labels [16]
fsize_axesT = 14; % font size for axes tick labels [14]
fsize_title = 18; % font size for plot title [18]
fsize_leg   = 16; % font size for legend [14]
linesize    = 1.5;  % line width [1.5]
markersize  = 10; % marker size [10]
figsize     = [600, 300]; % dimensions for figure (pixels)
renderer    = 'opengl';% use 'painters' normally, 'opengl' for transparent patches
% [800, 600] for most figures
% [600, 300] for histograms

%% ---------------------------- ORGANIZATION --------------------------- %%

if pick_fig
    [fig_name, fig_dir] = uigetfile(fullfile(fig_dir, '*.fig'));
    save_name = [fig_name(1:end-4), '.eps'];
end

%% ---------------------------- FORMATTING ----------------------------- %%

og_dir = pwd();

f1 = open(fullfile(fig_dir, fig_name)); % find and open figure
hax = gca;

% Set parameters
set(f1, 'WindowStyle', 'normal');
set(f1, 'Renderer', renderer);
set(f1,'color','w'); % figure must be in black and white
set(findall(f1,'-property','fontsize'),'fontsize',fsize_axesT);
axesLX = get(hax, 'XLabel');
set(axesLX, 'fontsize', fsize_axesL);
axesLY = get(hax, 'YLabel');
set(axesLY, 'fontsize', fsize_axesL);
set(findall(f1,'-property','linewidth'),'linewidth',linesize); % comment out after manual changes
% set(findall(f1,'-property','MarkerSize'),'MarkerSize',markersize);
set(findall(f1,'-property','interpreter'),'interpreter','latex');
ttl = get(hax, 'Title');
set(ttl, 'fontsize', fsize_title, 'fontweight', 'bold');
% delete(ttl);
leg = findobj(f1, 'Type', 'Legend');
set(leg, 'fontsize', fsize_leg);
% set(leg, 'location', 'northwest');
f1 = gcf;
f1_size = [0, 0, figsize(1), figsize(2)]; % set new dimensions of figure
set(f1,'Units','Pixels');
% set(f1,'Position',f1_size);
set(f1,'PaperSize',f1_size(3:4));
set(f1,'Position',f1_size);
% grid on;

% Special handling instructions
q1 = findobj(f1, 'Type', 'quiver');
if ~isempty(q1)
    set(q1,'linewidth',1); % keep vectors in vector field small
end

if save_fig
    cd(fig_dir);
    saveas(gcf, fig_name); % save revised figure under same name
    export_fig(save_name, '-r300', '-eps', ['-', renderer]);
    cd(og_dir);
    close(gcf);
end