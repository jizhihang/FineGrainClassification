%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: step1_grp_svm.m
% Desc: train group svm
% Author: Zhang Kang
% Date: 2014/01/13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function step1_grp_svm( grpID )

PrintTab();fprintf( 'Run: %s\n', mfilename );

% get configuration
conf = InitConf( );

if( grpID > conf.nGroup )
  PrintTab();fprintf( 'Error: task index esceed maximum group\n' );
  return;
end

cacheGrpInfo = cell( 1, conf.nGroup );
for g = 1 : conf.nGroup
  fName = sprintf( '-tmpGrpInfo%03d.mat',  g );
  cacheGrpInfo{ g } = fullfile( conf.cacheDir, [ conf.prefix, fName ] );
end
cacheGrpModel = cell( 1, conf.nGroup );
for g = 1 : conf.nGroup
  fName = sprintf( '-tmpGrpModel%03d.mat',  g );
  cacheGrpModel{ g } = fullfile( conf.cacheDir, [ conf.prefix, fName ] );
end

% curGrp
if( exist( cacheGrpInfo{ grpID }, 'file' ) )
  % load curGrp
  PrintTab();
  fprintf( 'Load cacheGrpInfo from file %s\n', cacheGrpInfo{ grpID } );
  load( cacheGrpInfo{ grpID } );
  % set grp svm opt
  curGrp.grpSVMOPT = conf.grpSVMOPT{ grpID };
  % save curGrp
  save( cacheGrpInfo{ grpID }, 'curGrp' );
else
  % get curGrp by clusteering
  nCluster = conf.nCluster( grpID );
  % clustering
  curGrp   = GroupClustering( nCluster );
  % cluster labeling
  curGrp  = TrainClusterModel( curGrp );
  % set grp svm opt
  curGrp.grpSVMOPT = conf.grpSVMOPT{ grpID };

  % enlarge each cluster
  if( conf.isOverlap )
    PrintTab();fprintf( 'enlarge cluster\n' );
    load( conf.imdbPath );
    train = find( imdb.ttSplit == 1 );
    for t = 1 : length( train )
      c = curGrp.clsToCluster( train( t ) );
      if( ~ismember( imdb.clsLabel( train( t ) ), curGrp.cluster{ c } ) )
        % train label not in this cluster --> enlarge current cluster
        curGrp.cluster{ c } = [ curGrp.cluster{ c }; imdb.clsLabel( train( t ) ) ];
      end
    end % end for each sample
  end
  
  % sort each cluster class label
  PrintTab();fprintf( 'sort each cluster classes (ascending order)\n' );
  for c = 1 : curGrp.nCluster
    curGrp.cluster{ c } = sort( curGrp.cluster{ c } );
  end
  % save curGrp
  save( cacheGrpInfo{ grpID }, 'curGrp' );
end


% curModel
if(  ~exist( cacheGrpModel{ grpID }, 'file' ) )
  if( conf.isSameSVM )
    % use same svm model
    % just train group 1
    if( grpID == 1 ) 
      curModel = TrainGrpSVM( curGrp );
      save( cacheGrpModel{ grpID }, 'curModel' );
    else
      PrintTab();
      fprintf( 'group %d use same model no need to train\n', grpID );
    end
  else
    curModel = TrainGrpSVM( curGrp );
    save( cacheGrpModel{ grpID }, 'curModel' );
  end
end


% end script step1_train_group