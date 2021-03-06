%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Data analysis of dataset SPUELER2015
% Feature evaluation and visualization
% 
% Input:    connectivity information (e.g. correlation matrices)
% Output:   connected topoplots
%
% Author: Jianyu Zhao
% Last revised: 07.07.2016
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%clearvars;

% for unknown reason FEAT doesnt change when running just the section
%{
    inpath = strcat(pwd,'/data_feat/');
    outpath = strcat(pwd,'/data_parametric/');
    filename = 'S01';
    load(strcat(inpath,filename));
%}
N = 10;

%FEAT.conn3 = single(FEAT.conn3);

cov1 = FEAT.conn3(:,:,FEAT.labels==2);
cov0 = FEAT.conn3(:,:,FEAT.labels==0);

n_ch = size(FEAT.temp,1);
[d dp df dfp] = deal(zeros(n_ch,n_ch));

%% Discriminating ability between exe error and no error
for i=1:n_ch
    for j=i+1:n_ch
        [d(i,j) dp(i,j) df(i,j) dfp(i,j)] = ...
            feature_eval_nParametric(squeeze(cov1(i,j,:)),squeeze(cov0(i,j,:)));
        if isnan(df(i,j))
            df(i,j) = 0;
        end    
        if isnan(dfp(i,j))
            dfp(i,j) = 0;
        end 
    end
end

%% Choose the best N features with the highest df
[sortedDf,idx] = sort(df(:),'descend');
maxDfs = sortedDf(1:N);
maxIdx = idx(1:N);
[I,J] = ind2sub(size(df),maxIdx);

%maxDfs

%%
%[sortedD,idxn] = sort(d(:),'descend');
%[sortedDp,idxn] = sort(dp(:),'descend');
%[sortedDfp,idxn] = sort(dfp(:),'descend');
%save(strcat(outpath,'out-exe'),'sortedD','sortedDp','sortedDf','sortedDfp');

%plot(sortedDf);

%gscatter(squeeze(real(log(FEAT.conn2(I(1),J(1),:)))/log(1.01)),squeeze(real(log(FEAT.conn2(I(2),J(2),:)))/log(1.01)),FEAT.labels)

%figure;
%gscatter(squeeze(FEAT.conn3(I(1),J(1),:)),squeeze(FEAT.conn3(I(2),J(2),:)),FEAT.labels)

%% Split the connections into poitive and negative ones
% luckily, all we have are neg-more-neg, pos-more-pos conns
mcov1 = mean(cov1,3);
mcov0 = mean(cov0,3);

%for i=1:N
    
%% Polarity check
for i=1:N
    if sign(mcov1(I(i),J(i)))~= sign(mcov0(I(i),J(i)))
        fprintf('The %dth pair changed polarity from %f\n', i ,sign(mcov1(I(i),J(i))))
    end
end

%% Draw the topoplots
% for execution errors

displayStr.chanPairs = [I J];
mcov1 = mean(cov1,3);
mcov0 = mean(cov0,3);
if 1
    strth = [];
    for i=1:size(I)
        strth = [strth;df(I(i),J(i))];
        %strth = [strth;mcov1(I(i),J(i))-mcov0(I(i),J(i))];
        %strth = [strth;mcov1(I(i),J(i))];
    end
    displayStr.connectStrength = strth;
    %displayStr.connectStrengthLimits = [-0.18 0.22];
    displayStr.connectStrengthLimits = [0 0.65];
    figure;
    set (gcf,'Position',[200 200 320 320]);
    %box on;
    %subplot(2,2,[1 3]);
    topoplot_connect_nocb(displayStr, FEAT.chanlocs);
    %topoplot_connect(displayStr, FEAT.chanlocs);
    title('execution error - no error');
    clear strth;
end

%{
xp = min(strth);
yp = max(strth);
label = xp:(yp-xp)/10:yp;
label = round((label*100))/100; % round to 2 decimals
st = cell(1,11);
for i=1:11
    st{i} = num2str(label(i));
end
%}

% for exe-error situation
if 0
    %mcov1 = mean(cov1,3);
    strth = [];
    for i=1:size(I)
        strth = [strth;mcov1(I(i),J(i))];
    end
    displayStr.connectStrength = strth;
    displayStr.connectStrengthLimits = [-0.6 0.8];
    subplot(2,2,2);
    topoplot_connect(displayStr, FEAT.chanlocs);

    title('Correlation (execution error)');
end

% for no-error situation
if 0
    %mcov0 = mean(cov0,3);
    strth = [];
    for i=1:size(I)
        strth = [strth;mcov0(I(i),J(i))];
    end
    displayStr.connectStrength = strth;
    displayStr.connectStrengthLimits = [-0.6 0.8];
    subplot(2,2,4);
    topoplot_connect(displayStr, FEAT.chanlocs);
    title('Correlation (no error)');
end

%% Variation of Fisher scores
figure;
set (gcf,'Position',[200 200 440 320]);
plot(1:20,corr1,'m',1:20,covv1,'c','LineWidth',0.75);
legend('correlation','covariance');
xlabel('Order');
ylabel('Fisher score');
title('Descending of Fisher Scores: Execution Error vs. No Error');

figure;
set (gcf,'Position',[200 200 440 320]);
plot(1:20,corr2,'m',1:20,covv2,'c','LineWidth',0.75);
legend('correlation','covariance');
xlabel('Order');
ylabel('Fisher score');
title('Descending of Fisher Scores: Outcome Error vs. No Error');

figure;
set (gcf,'Position',[200 200 440 320]);
plot(1:20,corr3,'m',1:20,covv3,'c','LineWidth',0.75);
legend('correlation','covariance');
xlabel('Order');
ylabel('Fisher score');
title('Descending of Fisher Scores: Outcome Error vs. Execution Error');
