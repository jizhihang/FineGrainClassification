function [ wSoftmax, bayesProb, probFeat ] = TrainMapSoft( conf, imdb, curGrp, svmScore )
%% TrainMapSoft
%  Desc: softmax regression to map each cluster SVM bayesProb to prob
%  In: 
%    conf, imdb -- basic variables
%    curGrp -- (struct) group cluster info
%    svmScore -- (nSample * nClass) SVM feature with test SVM feat
%  Out:
%    wSoftMax -- (1 * nCluster) cell each contain cluster softmax paramters
%    bayesProb  -- (nSample * nClass) probability output for each cluster
%%

PrintTab();fprintf( 'function: %s\n', mfilename );
tic;

% init basic variables
nSample = length( imdb.clsLabel );
nClass  = max( imdb.clsLabel );
nCluster = curGrp.nCluster;
train   = find( imdb.ttSplit == 1 );
% final bayes probability
bayesProb = zeros( nSample, nClass );
% each cluster inner probability
probFeat = cell( 1, nCluster );
% each clluster softmax paramters
wSoftmax = cell( 1, nCluster );

for t = 1 : nCluster
  PrintTab();fprintf( '\t cluster %d\n', t );
  grpCls = curGrp.cluster{ t };

  % get cluster prior prob
  clusterProb = curGrp.clusterProb( :, t );

  % train feature
  curTrain = intersect( find( ismember( imdb.clsLabel, grpCls ) ), train );
  trainScore = svmScore{ t }( curTrain, grpCls );
  % map class label sequentially
  tmpLabel = imdb.clsLabel( curTrain );
  trainLabel = zeros( size( tmpLabel ) );
  for c = 1 : length( grpCls )
    trainLabel( tmpLabel == grpCls( c ) ) = c;
  end
  % softmax L2 regression
  allScore = svmScore{ t }( :, grpCls );
  [ wSoftmax{ t }, probFeat{ t } ] = MultiLRL2( trainScore, trainLabel, allScore, 1, ones( length( trainLabel ), 1 ) );
  % use cluster probability as bias
  % [ ~, proAll ] = MultiLRL2( trainScore, trainLabel, allScore, 1, clusterProb( curTrain ) );
  % set final probability
  clusterProb = repmat( clusterProb, [ 1 length( grpCls ) ] );
  % bayes combine
  bayesProb( :, grpCls ) = bayesProb( :, grpCls ) + probFeat{ t } .* clusterProb;
end % end for each cluster

PrintTab();fprintf( 'function: %s -- time: %.2f (s)\n', mfilename, toc );

% end function TrainMapSoft
