function [ this_res ] = GetClusters( max_k, X, kclust )
%Inputs
%max_k - the maximum number of kmeans you want to fit.
%X - the vector, or matrix of points. It should be dataxfeatures in size

%Outputs
%The number of clusters in the data.

flag = 0;
this_max = 0; last_max = 0;
for  k = 1:max_k
    [idx c] = kmeans(X,k,'Distance','cityblock','Replicates',kclust);
    [silh,h] = silhouette(X,idx,'cityblock');
    res = mean(silh);
    this_max = res;
    if(res > .90)  
        flag = 1;
    end
    if((last_max > this_max) && flag == 1)
        break;
    end
    last_max = this_max;
end
this_res = k-1;

end

