%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: initConf
% Desc: initial configuration paramters for classification
% Author: Zhang Kang
% Date: 2013/12/05
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf( 1, '\n Init Configuration Paramters ... \n' );

if ( strcmp( computer(), 'GLNXA64' ) ) 
    % run vl_setup explicitly on Linux platform
    run( '~/vlfeat/toolbox/vl_setup' );
end

% declare global variable
%   conf - configuration paramters
%   imdb - image database
%   encoder - feature encoder
%   model - classification model
global conf imdb;

conf.lite = false;                        % lite version for debug

conf.dataset = 'CUB11';                  % dataset name
conf.prefix  = 'seg-fv-all';               % name prefix for all output
conf.isLRFlip = false;                   % enable left-right flip
conf.isStandImg = true;                  % standarize max size < 300
                                          % !!! conflict with seg mask !!
                                          % to handle seg mask 
                                          % use nearest neigbour inter
if( conf.isStandImg )
	conf.maxImgSz = 300;
end

conf.useBoundingBox = true;               % enable crop of bounding box
conf.useSegMask = true;                   % enable segment mask

%-----------------------------------------------
% feature&encoder paramters
%-----------------------------------------------
conf.encoderParam = { 'type', 'fv', ...
  'numWords', 256, ...
  'layouts', {'1x1'}, ...    % spatial pyramid layouts
  'numPcaDimensions', 192, ...            % PCA dimenssion PCA FLAG
  'whitening', true, ...                  % PCA whiten PCA FLAG
  'whiteningRegul', 0.01, ...              % PCA whiten + regularize
  'renormalize', true, ...                % PCA l2 renormalize
  'seed', 1
  };                                       % encoder paramter
conf.featParam = { 'Sizes' [ 4 6 8 10 ], ...
  'Step', 3, ... 
  'Color', 'opponent', ...
  'FloatDescriptors', true };
                                          % PHOW paramter
if( conf.useSegMask )
  conf.maskType = [ 64 / 255, 128 / 255, 192 / 255, 255 / 255 ];
end
%-----------------------------------------------
% model paramters
%-----------------------------------------------

conf.svm.C = 10;
conf.svm.kernel = 'linear';


conf.randSeed = 1 ;                       % initial random seed
randn('state',conf.randSeed) ;
rand('state',conf.randSeed) ;
vl_twister('state',conf.randSeed) ;

%-----------------------------------------------
% path paramters
%-----------------------------------------------
conf.outDir  = 'data';                    % output direcotry and files
conf.imdbPath = fullfile(conf.outDir, [conf.dataset '-imdb.mat']);
conf.encoderPath = fullfile(conf.outDir, [conf.prefix '-encoder.mat']);
conf.modelPath = fullfile(conf.outDir, [conf.prefix '-model.mat']);
conf.resultPath = fullfile(conf.outDir, [conf.prefix '-result.mat']);
% final features
conf.featPath = fullfile(conf.outDir, [conf.prefix '-feat.mat']);


fprintf( 1, '\n ... Done\n' );

