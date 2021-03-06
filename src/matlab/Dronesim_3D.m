%**************************************************************************
%
% Dronesim_3D.m - CA8 - DRONES
%
%**************************************************************************
%
% Group 832 - Control and Automation Msc.
% Aalborg University
% February 2016
%
%**************************************************************************
%
% DESCRIPTION:
% Code to test and check out a DYNAMIC SCENARIO of our drone and ground
% station in 3D
%
% Functions used during the code:
% - LOS_distance_3D.m
% - LOS_angles.m
% - GSantenna3.m
%
%**************************************************************************

clear all;
close all;
clc;

%% Enviroment parameters

prec_d = 200;               % Precision of the distance vector
opPhi = [];
opTheta = [];
theta_gs_vec = [];
theta_d_vec = [];
phi_gs_vec = [];
phi_d_vec = [];

freq = 2.4 * 10^9;          % Frequency [Hz]
lambda = 3*10^8/freq;       % Wavelength [m]
Ptx = 10*log10(1/(10^-3));  % 1mW power transmiter

% Small function to draw arrows
drawArrow = @(x,y,z) quiver3(x(1),y(1),z(1),x(2)-x(1),y(2)-y(1),...
    z(2)-z(1),'LineWidth',2.5,'MaxHeadSize',1.5);  

%% Location of GS and DRONE 

% Ground station position
x_gs = 0;                  % The position X of the GROUND STATION
y_gs = 0;                  % The position Y of the GROUND STATION
z_gs = 0;                  % The position Z of the GROUND STATION

% Drone position: DYNAMIC (Circle)
x_r = 52;
y_r = 52;
x_0 = 0;
y_0 = 0;
circle_angle = [-pi:0.2:pi];

% x_drone = x_0 + x_r*sin(circle_angle);          % The position X of the DRONE
% y_drone = y_0 + y_r*cos(circle_angle);          % The position Y of the DRONE
% z_drone = 0*ones(1,length(circle_angle));    % The position Z of the DRONE
% z_drone = 0.05*abs(sin(circle_angle));
x_drone = 1:2:50;                     % The position X of the DRONE
y_drone = 50*ones(1,length(x_drone));   % The position Y of the DRONE
z_drone = 0.1*ones(1,length(x_drone));  % The position Z of the DRONE


%% WEIRD STUFF
offsetX = 10;
offsetY = 10;
offsetZ = 0.1;
xUpLim = ceil(max([x_gs x_drone]))+offsetX;
xDownLim = floor(min([z_gs x_drone])) - offsetX;
xVector = [xDownLim:(xUpLim-xDownLim)/prec_d:xUpLim];    % World Vector Z [km]
yUpLim = ceil(max([y_gs y_drone])*1000)/1000+offsetY;
yDownLim = floor(min([y_gs y_drone])*1000)/1000 - offsetY;
yVector = [yDownLim:(yUpLim-yDownLim)/prec_d:yUpLim];    % World Vector Z [km]
zUpLim = ceil(max([z_gs z_drone])*1000)/1000 +offsetZ;
zDownLim = floor(min([z_gs z_drone])*1000)/1000 - offsetZ;
zVector = [zDownLim:(zUpLim-zDownLim)/prec_d:zUpLim];    % World Vector Z [km]
% World vectors X, Y, Z [km]
% xVector = [floor(min([x_gs x_drone])):step_x:ceil(max([x_gs x_drone]))];    
% yVector = [floor(min([y_gs y_drone])):step_y:ceil(max([y_gs y_drone]))];    
% zVector = [floor(min([z_gs z_drone])):step_z:ceil(max([z_gs z_drone])*1000)/1000];   

%% Actual calculations
% LOS distance vector construction
for i = 1:length(x_drone)
    [dxVector(i,:),dyVector(i,:),dzVector(i,:),los_d(i)] = ...
        LOS_distance_3D(x_drone(i),y_drone(i),z_drone(i),...
        x_gs,y_gs,z_gs,prec_d);
end

% Optimal Angles
for i = 1:length(x_drone)
%     % Just to make the trick
    opTheta(i) = atan2(y_drone(i)-y_gs,x_drone(i)-x_gs);
    opPhi(i) = atan2(z_drone(i)-z_gs,sqrt(abs(x_gs-x_drone(i))^2+...
        abs(y_gs-y_drone(i))^2));
    
    %% Ground Station definition
    % Polar angle: of the GROUND STATION FRAME [-pi/2:pi/2]. 0 = X-Y plane
    % axis
%     phi_gs = opPhi(i);
    phi_gs = 0;
    phi_gs_vec = [phi_gs_vec phi_gs];

    % Azimuthal angle: of the GROUND STATION FRAME [-pi:pi]. 0 = pointing 
    % along X axis
%     theta_gs = opTheta(i);
    theta_gs = 0;
    theta_gs_vec = [theta_gs_vec theta_gs];
    
    % POINTING ANTENNA GS FRAME
    x_start_gs = x_gs;
    y_start_gs = y_gs;
    z_start_gs = z_gs;
    x_end_gs = x_gs + los_d(i)/5*cos(phi_gs)*cos(theta_gs);
    y_end_gs = y_gs + los_d(i)/5*cos(phi_gs)*sin(theta_gs);
    z_end_gs = z_gs + los_d(i)/5*sin(phi_gs);
    
    
    %% Drone definition
    % Polar angle: of the DRONE [-pi/2:pi/2]. 0 = X-Y plane
%     phi_d = -opPhi(i)
    phi_d = 0;
    phi_d_vec = [phi_d_vec phi_d];
    
    % Azimuthal angle: of the DRONE [-pi:pi]. 0 = pointing along X axis
%     theta_d = pi + opTheta(i);
    theta_d = 0;
    theta_d_vec = [theta_d_vec theta_d];
    
    
    % POINTING ANNTENA DRONE FRAME
    x_start_d(i) = x_drone(i);
    y_start_d(i) = y_drone(i);
    z_start_d(i) = z_drone(i);
    x_end_d(i) = x_drone(i) + los_d(i)/5*cos(phi_d)*cos(theta_d);
    y_end_d(i) = y_drone(i) + los_d(i)/5*cos(phi_d)*sin(theta_d);
    z_end_d(i) = z_drone(i) + los_d(i)/5*sin(phi_d);
    
%     x_end_d(i) = x_drone(i) + 5*cos(phi_d)*cos(theta_d);
%     y_end_d(i) = y_drone(i) + 0.02*cos(phi_d)*sin(theta_d);
%     z_end_d(i) = z_drone(i) + 0*sin(phi_d);
    
    
    %% Error Angle and Gain calculations
    [alpha_d(i),alpha_gs(i),gamma_d(i),gamma_gs(i),opt_theta_gs(i),...
    opt_theta_d(i),opt_phi_gs(i),opt_phi_d(i)] = LOS_angles_3D(...
        x_drone(i),y_drone(i),z_drone(i),theta_d,phi_d,x_gs,y_gs,z_gs,...
        theta_gs,phi_gs);
    fprintf('Alpha Drone: %.3f | Gamma Drone: %.3f\n',alpha_d(i),...
        gamma_d(i));
    fprintf('Alpha GS: %.3f | Gamma GS: %.3f\n',alpha_gs(i),gamma_gs(i));
    
    [GSgain(i),angle3db_gs] = GSantenna3(alpha_gs(i),gamma_gs(i),0);
    [Dgain(i),angle3db_d] = GSantenna3(alpha_d(i),gamma_d(i),0);
    fprintf('Gain Drone: %.3f \nGain GS: %.3f\n',Dgain(i),GSgain(i));
    
    Lfs(i) = -20*log10(4*pi*los_d(i)*10^3/lambda);
    Prx(i) = Ptx + GSgain(i) + Dgain(i) + Lfs(i);
    
    %% Representation SCENARIO 3D
    
    
    f1 = figure(1);
    clf(f1);
    view(45,25);
    hold on
    plot3(x_drone(i),y_drone(i),z_drone(i),'o','LineWidth',2);
    plot3(x_gs,y_gs,z_gs,'X','LineWidth',2);
    drawArrow([x_start_gs,x_end_gs],[y_start_gs,y_end_gs],...
        [z_start_gs,z_end_gs]);
    drawArrow([x_start_d(i),x_end_d(i)],[y_start_d(i),y_end_d(i)],...
        [z_start_d(i),z_end_d(i)]);
    plot3(dxVector(i,:),dyVector(i,:),dzVector(i,:),'LineWidth',1.5);
    plot3(x_drone(1:i),y_drone(1:i),z_drone(1:i));
%     axis([0 60 0 1 0 0.1]);
    axis([xVector(1) xVector(end) yVector(1) yVector(end) ...
        zVector(1) zVector(end)]);
    grid on;
    grid minor;
    str = sprintf('Scenario Simulation 3D - Full View');
    %     str = sprintf(strcat(str,'\nGS Antenna Gain: %.3f dB | Drone Antenna Gain: %.3f dB'),GSgain,Dgain);
    %     str = sprintf(strcat(str,'\nAlpha GS: %.3f | Alpha D: %.3f'),alpha_gs,alpha_d);
    %     str = sprintf(strcat(str,'\nGamma GS: %.3f | Gamma D: %.3f'),gamma_gs,gamma_d);
    title(str);
    xlabel('X world axis');
    ylabel('Y world axis');
    zlabel('Z world axis');
    legend('Drone','Ground Station','GS Frame','Drone Frame',...
        'LOS distance','Location','Best');
    pause(0.1);
    M(i) = getframe;
    movegui(f1,'north');
    
    % Plotting Power in the receiver
    f2 = figure(2);
    clf(f2);
    hold on;
    plot(Prx);
    grid on;
    grid minor;
    str = sprintf('Prx');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    axis([0 length(x_drone) -200 0]);
    pause(0.1);
    movegui(f2,'south');
    
    % Plotting error angles for DRONE
    f3 = figure(3);
    clf(f3);
    subplot(211);
    plot(alpha_d);
    hold on;
    grid on;
    grid minor;    
    str = sprintf('Error angle Theta Drone');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
%     axis([0 length(x_drone) 0 180]);    
    subplot(212);
    plot(alpha_gs);
    hold on;
    grid on;
    grid minor;
    str = sprintf('Error angle Theta Ground Station');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
%     axis([0 length(x_drone) 0 180]);
    pause(0.1);
    movegui(f3,'northwest');
    
    % Plotting error angles for GS
    f4 = figure(4);
    clf(f4);   
    subplot(211);
    plot(gamma_d);
    hold on;
    grid on;
    grid minor;    
    str = sprintf('Error angle Phi Drone');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    xlim([0 length(x_drone)]);   
    subplot(212);
    plot(gamma_gs);
    hold on;
    grid on;
    grid minor;
    str = sprintf('Error angle Phi Ground Station');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    xlim([0 length(x_drone)]);
    pause(0.1);
    movegui(f4,'southwest');    
    
    f5 = figure(5);
    clf(f5);   
    subplot(211);
    hold on;
    plot(theta_gs_vec);
    plot(opt_theta_gs);
    grid on;
    grid minor;    
    str = sprintf('Theta GS and Optimal');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    legend('Theta','Optimal','Location','Best');
    xlim([0 length(x_drone)]);   
    subplot(212);
    hold on;
    plot(phi_gs_vec);
    plot(opt_phi_gs);
    grid on;
    grid minor;
    str = sprintf('Phi GS and Optimal');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    legend('Phi','Optimal','Location','Best');
    xlim([0 length(x_drone)]);
    pause(0.1);
    movegui(f5,'northeast'); 
    
    f6 = figure(6);
    clf(f6);   
    subplot(211);
    hold on;
    plot(theta_d_vec);
    plot(opt_theta_d);
    grid on;
    grid minor;    
    str = sprintf('Theta Drone and Optimal');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    legend('Theta','Optimal','Location','Best');
    xlim([0 length(x_drone)]);   
    subplot(212);
    hold on;
    plot(phi_d_vec);
    plot(opt_phi_d);
    grid on;
    grid minor;
    str = sprintf('Phi GS and Optimal');
    title(str);
    xlabel('Time sample');
    ylabel('Relative Amplitude');
    legend('Phi','Optimal','Location','Best');
    xlim([0 length(x_drone)]);
    pause(0.1); 
    movegui(f6,'southeast'); 
end

% Save movie and figures
% movie2avi(M,'fig/Dronesim_3D.avi','compression','None');
% print(2,'fig/Prx','-depsc');
% print(3,'fig/Drone_angles','-depsc');
% print(4,'fig/GS_angles','-depsc');

%% STATIONARY PLOTS (JUST IN CASE)

% % Plotting Power in the receiver
% figure(2);
% plot(Prx);
% grid on;
% grid minor;
% str = sprintf('Prx');
% title(str);
% xlabel('Time sample');
% ylabel('Relative Amplitude');
% axis([0 length(Prx) -200 0]);
% print('fig/Prx','-depsc');

% % Plotting error angles for DRONE
% figure(3);
% plot(alpha_d);
% hold on;
% plot(gamma_d);
% grid on;
% grid minor;
% str = sprintf('Error angles Drone');
% title(str);
% xlabel('Time sample');
% ylabel('Relative Amplitude');
% legend('Alpha D','Gamma D');
% axis([0 length(gamma_d) 0 180]);
% print('fig/Drone_angles','-depsc');

% Plotting error angles for GS
% figure(4);
% plot(alpha_gs);
% hold on;
% plot(gamma_gs);
% grid on;
% grid minor;
% str = sprintf('Error angles Ground Station');
% title(str);
% xlabel('Time sample');
% ylabel('Relative Amplitude');
% legend('Alpha GS','Gamma GS');
% axis([0 length(gamma_gs) 0 180]);
% print('fig/GS_angles','-depsc');
