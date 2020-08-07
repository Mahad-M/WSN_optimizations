clear all
close all
clc

locs = [50; 50];
thresh = 2;
for  i = 1:100
    scatter(locs(1,:), locs(2,:))
    new_num = rand(2, 1)*100;
    dist = min(sqrt((new_num(1,1) - locs(1,:)).^2 + (new_num(2,1) - locs(2,:)).^2))
    while dist < thresh
        new_num = rand(2, 1)*100;
        dist = min(sqrt((new_num(1,1) - locs(1,:)).^2 + (new_num(2,1) - locs(2,:)).^2))
    end
    locs = [locs new_num];
end
locs = locs(:, 2:length(locs));
save('mylocations.mat', 'locs')