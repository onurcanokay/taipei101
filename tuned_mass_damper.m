%% MASS SPRING SYSTEM MODEL FOR TUNED MASS DAMPER (TMD)
% AUTHOR: ONURCAN OKAY
% DATE: 19/10/2024
clear; clc; close all;

%% Initialize Simulation

% Mass values in metric tonnes
m1 = 52696;
m2 = 658.7;

% Damping coefficients in kN*s/m
c1 = 1887.4;
c2 = 59.8026;

% Stifness values in kN/m
k1 = 42250;
k2 = 526.6805;

% External harmonic force amplitude in kN
F_mag = 200;

% External harmonic force frequency in rad/sec
% Also the resonance frequency
F_frq = 0.8954;

%% Run Simulation and Get Data

% Read the displacment data
x = readtable("vibration_data.xlsx");
L12  = 0.6; % Inital distance between blocks

% Create Building and TMD, displacement arrays
x1 = table2array(x(:,2));
x2 = table2array(x(:,3))+L12;
x1_noTMD = table2array(x(:,4));

%% Visualise Data

% Visual models parameter
L01  = 0.35; % Damper-Mass length
L12  = 0.6; % Inital distance between blocks
a1   = 0.1; % Building block length
a2 = 0.08; % TMD block length
baseX = [-0.18 -0.18]; % Ground rod x-coor
baseY = [-0.5 0.5]; % Ground rod y-coor

% Video parameter
tF      = 180; % Video length in sec
fR      = 50; % Frame rate in fps
dt      = 1/fR; % Time resolution in sec
time    = linspace(0,tF,tF*fR); % Time array in sec

% Initialize and format animation layout
tiledlayout(2,1,"TileSpacing","none", "Padding","compact");
set(gcf,'Position',[50 50 1520 720]);
ax1 = nexttile(1);
hold on ; grid on ; axis equal
ax2 = nexttile(2);
hold on ; grid on ; axis equal
set([ax1 ax2],'xlim',[-0.2 1.1],'ylim',[-0.1 0.1])
set([ax1 ax2],'FontName','Verdana','FontSize',12)
title(ax1,'One-Dimensional Mass-Spring-Damper Model of Taipei101 and TMD')
xlabel(ax2, 'x [m]')
ax1.XTick = -0.2:0.1:1.1;
ax2.XTick = -0.2:0.1:1.1;
ax1.XAxis.MinorTickValues = -0.2:0.01:1.1;
ax2.XAxis.MinorTickValues = -0.2:0.01:1.1;
set([ax1 ax2],'YTickLabel',[]);
set([ax1 ax2],'YTick',[]);
ax1.XMinorTick = "on";
ax2.XMinorTick = "on";
ax1.XMinorGrid = "on";
ax2.XMinorGrid = "on";
ax1.YGrid = 'off';
ax2.YGrid = 'off';

% Create and open video writer object
v = VideoWriter('visualisation.mp4','MPEG-4');
v.Quality   = 100;
v.FrameRate = fR;
open(v);

% Read images
taipei101 = flipud(imread("taipei101.jpg"));
TMD = flipud(imread("damper.jpg"));

% Animate frame by frame
for i=1:length(time)
    
    % % First Plot % %
    nexttile(1);
    hold on;

    % Building mass visual
    fill([x1(i) x1(i) x1(i)+a1 x1(i)+a1],[-a1/2 a1/2 a1/2 -a1/2],[0.6 0.7 0.9],'LineWidth',2)
    text(x1(i)+0.0225, 0.01-a1/2, "Taipei101")
    image(taipei101, "XData",[x1(i)+0.028235 x1(i)+0.071765], "YData",[0.02-a1/2 a1/2-0.005]);
    
    % TMD mass visual
    fill([x2(i) x2(i) x2(i)+a2 x2(i)+a2],[-a2/2 a2/2 a2/2 -a2/2],[1.0 0.9 0.2],'LineWidth',2)
    text(x2(i)+0.026, 0.01-a2/2, "TMD");
    image(TMD, "XData",[x2(i)+0.005 x2(i)+0.075], "YData",[0.016-a2/2 a2/2-0.005]);

    % Ground visual
    plot(baseX, baseY, Color=[0.7 0.7 0.7], LineWidth=5);
    plot(baseX,baseY,'k',LineWidth=2);

    % Springs visual
    [s_x, s_y] = plot_spring(baseX(1),x1(i),0.02);
    plot(s_x,s_y, 'k', LineWidth=2)
    text((baseX(1)+x1(i))/2-0.01, 0.044, "$k_1$", "FontSize", 18, "Interpreter","latex");
    [s_x, s_y] = plot_spring(x1(i)+a1,x2(i),0.02);
    plot(s_x,s_y, 'k', LineWidth=2)
    text((x1(i)+a1+x2(i))/2-0.01, 0.044, "$k_2$", "FontSize", 18, "Interpreter","latex");

    % Dampers visual
    [d_x1, d_y1, d_x2, d_y2] = plot_damper(baseX(1),x1(i),-0.02);
    plot(d_x1, d_y1, 'k', LineWidth=2);
    plot(d_x2, d_y2, 'k', LineWidth=2);
    text((baseX(1)+x1(i))/2-0.01, -0.05, "$c_1$", "FontSize", 18, "Interpreter","latex");
    [d_x1, d_y1, d_x2, d_y2] = plot_damper(x1(i)+a1,x2(i),-0.02);
    plot(d_x1, d_y1, 'k', LineWidth=2);
    plot(d_x2, d_y2, 'k', LineWidth=2);
    text((x1(i)+a1+x2(i))/2-0.01, -0.05, "$c_2$", "FontSize", 18, "Interpreter","latex");
    
    % Harmonic forcing visual
    F_x = [x1(i), x1(i), x1(i)+0.04*sin(F_frq*i*dt)]; %
    F_y = [a1/2+0.005 a1/2+0.025 a1/2+0.025];
    plot(F_x, F_y, 'Color', [0.8 0.1 0.1], 'LineWidth',2);
    if sin(F_frq*i*dt) > 0
        mrk_arrow = '>';
    else
        mrk_arrow = '<';
    end
    plot(F_x(end), F_y(end), mrk_arrow, MarkerEdgeColor='none', MarkerSize=8,  MarkerFaceColor=[0.8 0.1 0.1]);
    text(F_x(end)+0.006, F_y(end)+0.014, "$F(t)$", "Color", [0.8 0.1 0.1], "FontSize", 14, "Interpreter", "latex");

    % % Second Plot % %
    nexttile(2);
    hold on;

    % Building mass with no TMD visual
    fill([x1_noTMD(i) x1_noTMD(i) x1_noTMD(i)+a1 x1_noTMD(i)+a1],[-a1/2 a1/2 a1/2 -a1/2],[0.6 0.7 0.9],'LineWidth',2)
    text(x1_noTMD(i)+0.025, 0.01-a1/2, "Taipei101")
    image(taipei101, "XData",[x1_noTMD(i)+0.028235 x1_noTMD(i)+0.071765], "YData",[0.02-a1/2 a1/2-0.005]);

    % Ground visual
    plot(baseX, baseY, Color=[0.7 0.7 0.7], LineWidth=5);
    plot(baseX,baseY,'k',LineWidth=2);

    % Spring visual
    [s_x, s_y] = plot_spring(baseX(1),x1_noTMD(i),0.02);
    plot(s_x,s_y, 'k', LineWidth=2)
    text((baseX(1)+x1_noTMD(i))/2-0.01, 0.044, "$k_1$", "FontSize", 18, "Interpreter","latex");

    % Damper visual
    [d_x1, d_y1, d_x2, d_y2] = plot_damper(baseX(1),x1_noTMD(i),-0.02);
    plot(d_x1, d_y1, 'k', LineWidth=2);
    plot(d_x2, d_y2, 'k', LineWidth=2);
    text((baseX(1)+x1_noTMD(i))/2-0.01, -0.05, "$c_1$", "FontSize", 18, "Interpreter","latex");
    
    % Harmonic forcing visual
    F_x = [x1_noTMD(i), x1_noTMD(i), x1_noTMD(i)+0.04*sin(F_frq*i*dt)];
    F_y = [a1/2+0.005 a1/2+0.025 a1/2+0.025];
    plot(F_x, F_y, 'Color', [0.8 0.1 0.1], 'LineWidth',2);
    if sin(F_frq*i*dt) > 0
        mrk_arrow = '>';
    else
        mrk_arrow = '<';
    end
    plot(F_x(end), F_y(end), mrk_arrow, MarkerEdgeColor='none', MarkerSize=8,  MarkerFaceColor=[0.8 0.1 0.1]);
    text(F_x(end)+0.006, F_y(end)+0.014, "$F(t)$", "Color", [0.8 0.1 0.1], "FontSize", 14, "Interpreter", "latex");

    % Save frame and clean plot
    frame = getframe(gcf);
    writeVideo(v,frame);
    cla;
    nexttile(1);
    cla;
end

% Close plot and print complation message
close(v);
close all;
fprintf("Visualisation is done! Video is saved.\n");

%% Plot Functions

function [s_x, s_y] = plot_spring(x_start, x_end, height)
    s_x = [x_start, (0:0.005:0.035)+(x_start+x_end-0.035)/2, x_end];
    s_y = [0, 0, repmat([-0.01 0.01],[1,3]), 0, 0] + height;
end

function [d_x1, d_y1, d_x2, d_y2] = plot_damper(x_start, x_end, height)
    d_x1 = [x_start, (x_start+x_end-0.035)/2 ...
        (x_start+x_end-0.035)/2 ...
        (x_start+x_end+0.035)/2 ...
        (x_start+x_end-0.035)/2 ...
        (x_start+x_end-0.035)/2 ...
        (x_start+x_end+0.035)/2];
    d_y1 = ([0 0 0.012 0.012 0.012 -0.012 -0.012])+height;
    d_x2 = [(x_start+x_end)/2 (x_start+x_end)/2 (x_start+x_end)/2 x_end];
    d_y2 = ([-0.008 0.008 0 0])+height;
end