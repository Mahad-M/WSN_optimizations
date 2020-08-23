function Sensors=ConfigureSensors(Model,n,GX,GY)
%% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272
%% Configuration EmptySensor
EmptySensor.xd=0;
EmptySensor.yd=0;
EmptySensor.G=0;
EmptySensor.df=0;
EmptySensor.type='N';
EmptySensor.E=0; 
EmptySensor.id=0;
EmptySensor.dis2sink=0;
EmptySensor.dis2ch=0;
EmptySensor.MCH=n+1;    %Member of CH

%% Configuration Sensors
Sensors=repmat(EmptySensor,n+1,1);
load('data.mat'); 
load('mylocations.mat')
load('energy.mat')
GX = locs(1, :);
GY = locs(2, :);
for i=1:1:n
    %set x location
    Sensors(i).xd=GX(i); 
    %set y location
    Sensors(i).yd=GY(i);
    %Determinate whether in previous periods has been clusterhead or not? not=0 and be=n
    Sensors(i).G=0;
    %dead flag. Whether dead or alive S(i).df=0 alive. S(i).df=1 dead.
    Sensors(i).df=0; 
    %initially there are not each cluster heads 
    Sensors(i).type='N';
    %all sensors have initially random data
    Sensors(i).data = data(i);
    %sensors have 0 neighbours initially
    Sensors(i).neighbour = [];
    %initially all nodes have equal Energy
    %%%Sensors(i).E=Model.Eo;
    %hetrogeneous energy
    Sensors(i).E=Model.Eo+het_E(i);
    %id
    Sensors(i).id=i;
    %Sensors(i).RR=Model.RR;
    %Cluster color
    Sensors(i).color = [0 1 1];
    % cluster ID
    Sensors(i).CID = 0;
    Sensors(i).selected = 0;
    %sleep or awake
    Sensors(i).mode = 'A';
    
end 

Sensors(n+1).xd=Model.Sinkx; 
Sensors(n+1).yd=Model.Sinky;
Sensors(n+1).E=100;
Sensors(n+1).id=n+1;
end