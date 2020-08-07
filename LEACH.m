%% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272

clc;
clear;
close all;
warning off all;
time_start = tic;

%% Create sensor nodes, Set Parameters and Create Energy Model 
%%%%%%%%%%%%%%%%%%%%%%%%% Initial Parameters %%%%%%%%%%%%%%%%%%%%%%%
n=100;                                  %Number of Nodes in the field
[Area,Model]=setParameters(n);     		%Set Parameters Sensors and Network

%%%%%%%%%%%%%%%%%%%%%%%%% configuration Sensors %%%%%%%%%%%%%%%%%%%%
CreateRandomSen(Model,Area);            %Create a random scenario
load Locations                          %Load sensor Location
Sensors=ConfigureSensors(Model,n,X,Y);

%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters initialization %%%%%%%%%%%%%%%%
countCHs=0;         %counter for CHs
flag_first_dead=0;  %flag_first_dead
deadNum=0;          %Number of dead nodes

initEnergy=0;       %Initial Energy
for i=1:n
      initEnergy=Sensors(i).E+initEnergy;
end

SRP=zeros(1,Model.rmax);    %number of sent routing packets
RRP=zeros(1,Model.rmax);    %number of receive routing packets
SDP=zeros(1,Model.rmax);    %number of sent data packets 
RDP=zeros(1,Model.rmax);    %number of receive data packets 

Sum_DEAD=zeros(1,Model.rmax);
CLUSTERHS=zeros(1,Model.rmax);
AllSensorEnergy=zeros(1,Model.rmax);
Sensors = create_pairs(Sensors, 10, 3);  % create pairs of sleep and awake sensors
ploter(Sensors,Model);                  %Plot sensors
%%%%%%%%%%%%%%%%%%%%%%%%% Start Simulation %%%%%%%%%%%%%%%%%%%%%%%%%
global srp rrp sdp rdp
srp=0;          %counter number of sent routing packets
rrp=0;          %counter number of receive routing packets
sdp=0;          %counter number of sent data packets 
rdp=0;          %counter number of receive data packets 

%Sink broadcast start message to all nodes
Sender=n+1;     %Sink
Receiver=1:n;   %All nodes
Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);

% All sensor send location information to Sink .
 Sensors=disToSink(Sensors,Model);
% Sender=1:n;     %All nodes
% Receiver=n+1;   %Sink
% Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);

%Save metrics
SRP(1)=srp;
RRP(1)=rrp;  
SDP(1)=sdp;
RDP(1)=rdp;

time_round = tic;
%% Main loop program
for r=1:1:Model.rmax
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
    %This section Operate for each epoch   
    member=[];              %Member of each cluster in per period
    countCHs=0;             %Number of CH in per period
    %counter for bit transmitted to Bases Station and Cluster Heads
    srp=0;          %counter number of sent routing packets
    rrp=0;          %counter number of receive routing packets
    sdp=0;          %counter number of sent data packets to sink
    rdp=0;          %counter number of receive data packets by sink
    %initialization per round
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;   
    pause(0.000001)    %pause simulation
    hold off;       %clear figure
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Sensors=resetSensors(Sensors,Model);
    %allow to sensor to become cluster-head. LEACH Algorithm  
    AroundClear=10;
    if(mod(r,AroundClear)==0) 
        for i=1:1:n
            Sensors(i).G=0;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot sensors %%%%%%%%%%%%%%%%%%%%%%%
    deadNum=ploter(Sensors,Model);
    
    %Save r'th period When the first node dies
    if (deadNum>=1)      
        if(flag_first_dead==0)
            first_dead=r;
            flag_first_dead=1;
        end  
    end
    
%%%%%%%%%%%%%%%%%%%%%%% cluster head election %%%%%%%%%%%%%%%%%%%
    % Sensors = Sensors([Sensors(:).mode] == 'A');
    %Selection Candidate Cluster Head Based on LEACH Set-up Phase
    [TotalCH,Sensors]=SelectCH(Sensors,Model,r); 
    
    %Broadcasting CHs to All Sensor that are in Radio Rage CH.
    for i=1:length(TotalCH)
        
        Sender=TotalCH(i).id;
        SenderRR=Model.RR;
        Receiver=findReceiver(Sensors,Model,Sender,SenderRR);   
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);
            
    end 
    
    %Sensors join to nearest CH 
    Sensors=JoinToNearestCH(Sensors,Model,TotalCH);
    
%%%%%%%%%%%%%%%%%%%%%%% end of cluster head election phase %%%%%%

%%%%%%%%%%%%%%%%%%%%%%% plot network status in end of set-up phase 

    for i=1:n
        
        if (Sensors(i).type=='N' && Sensors(i).dis2ch<Sensors(i).dis2sink && ...
                Sensors(i).E>0)
            
            XL=[Sensors(i).xd ,Sensors(Sensors(i).MCH).xd];
            YL=[Sensors(i).yd ,Sensors(Sensors(i).MCH).yd];
            hold on
            line(XL,YL)
            
        end
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% steady-state phase %%%%%%%%%%%%%%%%%
    NumPacket=Model.NumPacket;
    for i=1:1:1%NumPacket 
        
        %Plotter     
        deadNum=ploter(Sensors,Model);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% All sensor send data packet to  CH 
        for j=1:length(TotalCH)
            
            Receiver=TotalCH(j).id;
            Sender=findSender(Sensors,Model,Receiver); 
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
        end
        
    end
    
    
%%%%%%%%%%%% send Data packet from CH to Sink after Data aggregation
    for i=1:length(TotalCH)
            
        Receiver=n+1;               %Sink
        Sender=TotalCH(i).id;       %CH 
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
    end
%%% send data packet directly from other nodes(that aren't in each cluster) to Sink
    for i=1:n
        if(Sensors(i).MCH==Sensors(n+1).id)
            Receiver=n+1;               %Sink
            Sender=Sensors(i).id;       %Other Nodes 
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
        end
    end
 
%%%%%%%%%%%%%%% Sleep awake %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elapsed_round = toc(time_round);
    if elapsed_round >= 10 
        clusters = unique([Sensors(:).CID]);
        for i = clusters
            all_CID = [Sensors(:).CID];
            i_CID = all_CID == i;
            group = find(i_CID);
            energies = [Sensors(group).E];
            energies(energies <= 0) = inf;
            index_min = group(find(energies == min(energies)));
            for k = group
                if k ~= index_min
                    Sensors(k).mode = 'S';
                else
                    Sensors(k).mode = 'A';
                end
            end
        end
%     for i = 1:n
%         if Sensors(i).mode == 'A' && ~isempty([Sensors(i).neighbour])
%             neighs = Sensors(i).neighbour;
%             group = [i neighs];
%             energies = [Sensors(group).E];
%             index_min = group(find(energies == min(energies)));
%             for k = group
%                 if k ~= index_min
%                     Sensors(k).mode = 'S';
%                 end
%             end
%         end
%     end
    time_round = tic;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%% STATISTICS
     
    Sum_DEAD(r+1)=deadNum;
    
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;
    
    CLUSTERHS(r+1)=countCHs;
    n_awake_round = numel(Sensors([Sensors(1:100).mode] == 'A' & [Sensors(1:100).E] > 0))
    n_awake(r) = n_awake_round;
    r
    asleep_sensors = Sensors([Sensors(1:100).mode] == 'S' & [Sensors(1:100).E] > 0);
    data_loss_round = sum([asleep_sensors.data])
    data_loss(r) = data_loss_round;
    alive=0;
    SensorEnergy=0;
    for i=1:n
        if Sensors(i).E>0
            alive=alive+1;
            SensorEnergy=SensorEnergy+Sensors(i).E;
        end
    end
    AliveSensors(r)=alive; %#ok
    
    SumEnergyAllSensor(r+1)=SensorEnergy; %#ok
    
    AvgEnergyAllSensor(r+1)=SensorEnergy/alive; %#ok
    
    ConsumEnergy(r+1)=(initEnergy-SumEnergyAllSensor(r+1))/n; %#ok
    
    En=0;
    for i=1:n
        if Sensors(i).E>0
            En=En+(Sensors(i).E-AvgEnergyAllSensor(r+1))^2;
        end
    end
    
    Enheraf(r+1)=En/alive; %#ok
    
    title(sprintf('Round=%d,Dead nodes=%d', r+1, deadNum)) 
    
   %dead
   if(n==deadNum)
       
       lastPeriod=r;  
       break;
       
   end
  
end % for r=0:1:rmax

disp('End of Simulation');
toc(time_start);
disp('Create Report...')

filename=sprintf('leach%d.mat',n);

%% Save Report
save(filename);
