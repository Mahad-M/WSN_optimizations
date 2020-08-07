function [Node] = create_pairs(Network_nodes, dist_thresh, data_thresh)
    % num_nodes: Number of nodes in the network
    % dist_thresh: Threshold distance for nodes to be paired
    % data_thresh: Threshold of data
    
    Node = Network_nodes(1:length(Network_nodes) -1);
    for i = 1:numel(Node)
        if Node(i).selected == 0 && Node(i).E > 0
            for j = 1:numel(Node)
                if i ~=j && Node(j).E > 0 && Node(j).selected == 0
                    dist = sqrt((Node(i).xd - Node(j).xd)^2 + (Node(i).yd - Node(j).yd)^2);  % distance between the nodes
                    dat = abs(Node(i).data - Node(j).data);  % difference of data
                    if dist < dist_thresh && dat <data_thresh
                        Node(i).neighbour = unique([Node(i).neighbour j]);
                        Node(j).neighbour = unique([Node(j).neighbour i]);
                        Node(i).selected = 1;
                        Node(j).selected = 1;
                    end
                end
            end
        end
        group = [i Node(i).neighbour];
        color = rand(1,3);
        while color == [0 0 1]
            color = [rand(), rand(), rand()];
        end
        for k =1:length(Node(i).neighbour)
            Node(i).color = color;
            group_ = group;
            group_(group==Node(i).neighbour(k)) = [];
            Node(Node(i).neighbour(k)).neighbour = group_;
            Node(Node(i).neighbour(k)).color = color;
        end
    end
    Node = [Node; Network_nodes(length(Network_nodes))];
end
