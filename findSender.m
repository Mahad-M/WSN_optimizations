function Sender=findSender(Sensors,Model,Receiver)
   %% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272 
    Sender=[];
 
    n=Model.n;
 
    for i=1:n

        if (Sensors(i).MCH==Receiver & Sensors(i).id~=Receiver)
            Sender=[Sender,Sensors(i).id]; %#ok
        end

    end 

end