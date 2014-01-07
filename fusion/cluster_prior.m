% use cluster prior to 

% conf = InitConf();
load( conf.imdbPath );
load( conf.grpInfoPath );
load( conf.grpModelPath );

test = find( imdb.ttSplit == 0 );
testLab = imdb.clsLabel( test );
nSample = length( imdb.clsLabel );
nClass = max( imdb.clsLabel );


% combine all groups' feature
% allFeat = zeros( size( grpModel{ 1 }.mapFeat ) );
allFeat = [];
selGrp = [ 1 2 ];
for s = 1 : length( selGrp );
  g = selGrp( s );
  fprintf( 'Group %d\n', g );
  tryFeat =  grpModel{ g }.mapFeat;

  % % cluster prior
  % cTc = grpInfo{ g }.clsToCluster;
  % % disp( cTc( 1 : 5 ) );
  % % set other cluster score to minimum
  % for t = 1 : nSample
  %   clsIdx = grpInfo{ g }.cluster{ cTc( t ) };
  %   clsIdx = setdiff( ( 1 : nClass )', clsIdx );
  %   tryFeat( t, clsIdx ) = conf.MAP_INIT_VAL;
  % end
  % % disp( tryFeat( 1 : 5, 1 : 5 ) );
  % % one group result


  tryFeat   = NormMapFeat( conf, imdb, tryFeat );
  tryScores = TrainMapReg( conf, imdb, tryFeat, imdb.clsLabel );
  
  [ tryConf{ g }, tryMeanAcc( g ) ] = ScoreToConf( tryScores, testLab );
  fprintf( '\t group %d -- Mean Acc: %.2f %%\n', g, tryMeanAcc( g ) );

  % combine feat
  allFeat = [ allFeat tryFeat ];
end

% all groups results
fprintf( 'All group reg mapping\n' );
allScores = TrainMapReg( conf, imdb, allFeat, imdb.clsLabel );
[ allConf, allMeanAcc ] = ScoreToConf( allScores, testLab );
fprintf( 'Mean Acc: %.2f %%\n', allMeanAcc );