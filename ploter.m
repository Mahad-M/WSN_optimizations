function deadNum=ploter(Sensors,Model)
    %% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272
    deadNum=0;
    n=Model.n;
    
    for i=1:n
        %check dead node
        if (Sensors(i).E>0)
            
            if(Sensors(i).type=='N' )      
                plot(Sensors(i).xd,Sensors(i).yd,'o', 'MarkerSize',10, 'MarkerFaceColor', Sensors(i).color, 'Color', Sensors(i).color);     
            else %Sensors.type=='C'       
                plot(Sensors(i).xd,Sensors(i).yd,'kx','MarkerSize',10);
            end
            
        else
            deadNum=deadNum+1;
            plot(Sensors(i).xd,Sensors(i).yd,'.', 'Color', Sensors(i).color);
        end
        
        hold on;
        
    end 
    plot(Sensors(n+1).xd,Sensors(n+1).yd,'g*','MarkerSize',15); 
    axis square

end