function data = crosstalk(source_data, nwin)

if ~mod(nwin,2)
    nwin = nwin + 1;
end

Y_new = zeros(size(source_data));
Y_means = Y_new; Y_mod = Y_new;
T2s = zeros(4,size(source_data,2));

for i = 1:size(source_data,2)
    % indices with which to calculate average
    if i<=size(source_data,2)-nwin+1
        avg_ind_min=i;
        avg_ind_max=i+nwin-1;
    else
        avg_ind_min=size(source_data,2)-nwin+1;
        avg_ind_max=size(source_data,2);
    end

    % calculate average
    Y_mean=mean(source_data(:,avg_ind_min:avg_ind_max),2);

    % derivative for temporal shift
    dY_mean=[diff(Y_mean);0];
    dY2_mean=[diff(dY_mean);0];

    X2=[ones(size(source_data,1),1),Y_mean,dY_mean,dY2_mean];
    %X2=[ones(size(ts,1),1),Y_mean,dY_mean];
    %X2=[ones(size(Y,1),1),Y_mean];

    % least-squares fit
    T2=pinv(X2'*X2)*X2'*source_data(:,i);

    % subtract fit
    Y_new(:,i)=source_data(:,i)-X2*T2;

    % store variables
    Y_means(:,i)=Y_mean;
    Y_mod(:,i)=X2*T2;
    T2s(:,i)=T2;
end

data = Y_new;