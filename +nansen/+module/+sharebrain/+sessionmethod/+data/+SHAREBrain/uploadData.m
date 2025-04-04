function varargout = uploadData(sessionObject, varargin)
%CHANGERAWDATAROOT Summary of this function goes here
%   Detailed explanation goes here


% % % % % % % % % % % % % % % INSTRUCTIONS % % % % % % % % % % % % % % %
% - - - - - - - - - - You can remove this part - - - - - - - - - - - 
% Instructions on how to use this template: 
%   1) If the session method should have parameters, these should be
%      defined in the local function getDefaultParameters at the bottom of
%      this script.
%   2) Scroll down to the custom code block below and write code to do
%   operations on the sessionObjects and it's data.
%   3) Add documentation (summary and explanation) for the session method
%      above. PS: Don't change the function definition (inputs/outputs)
%
%   For examples: Press e on the keyboard while browsing the session
%   methods. (e) should appear after the name in the menu, and when you 
%   select a session method, the m-file will open.


% % % % % % % % % % % % CONFIGURATION CODE BLOCK % % % % % % % % % % % % 
% Create a struct of default parameters (if applicable) and specify one or 
% more attributes (see nansen.session.SessionMethod.setAttributes) for 
% details.
    
    % Get struct of parameters from local function
    params = getDefaultParameters();
    
    % Create a cell array with attribute keywords
    ATTRIBUTES = {'batch', 'queueable'};   
   
    % Get all data location names and make a list of alternatives
    dlm = nansen.DataLocationModel;
    ATTRIBUTES = [ATTRIBUTES, {'Alternatives', dlm.DataLocationNames}];
    
% % % % % % % % % % % % % DEFAULT CODE BLOCK % % % % % % % % % % % % % % 
% - - - - - - - - - - Please do not edit this part - - - - - - - - - - - 
    
    % Create a struct with "attributes" using a predefined pattern
    import nansen.session.SessionMethod
    fcnAttributes = SessionMethod.setAttributes(params, ATTRIBUTES{:});
    
    if ~nargin && nargout > 0
        varargout = {fcnAttributes};   return
    end
    
    params.Alternative = dlm.DataLocationNames{1}; % Set a default value.

    % Parse name-value pairs from function input and update parameters
    params = utility.parsenvpairs(params, [], varargin);
    
    
% % % % % % % % % % % % % % CUSTOM CODE BLOCK % % % % % % % % % % % % % % 
    
    % Get data locations, make a list of available roots, let user select
    % which one to use and then apply that data location to all sessions
    
    import nansen.module.sharebrain.services.ebrains.uploadFileToBucket

    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();
    filePath = fullfile(configFolder, 'ebrains_collab_info.json');
    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiGetBucketId()
    end
    collabInfo = jsondecode( fileread(filePath));
    bucketName = collabInfo.title;

    dataLocName = params.Alternative;

    rootDataFolder = sessionObject.getDataLocationRootDir(dataLocName);
    sessionFolder = sessionObject.getSessionFolder(dataLocName);
    sessionData = sessionObject.Data;
    
    dataVariables = sessionData.getVariableNames();

    L = recursiveDir(sessionFolder, 'Type', 'file', 'OutputType', 'FilePath');

    bucketManifest = []; %


    for i = 1:numel(L)
        filePath = L{i};
    % % for i = 1:numel(dataVariables)
    % %     filePath = sessionObject.getDataFilePath(dataVariables{i});
        % Todo: Check if file is in bucket
        if contains(filePath, rootDataFolder)
            relativeFilePath = strrep(filePath, rootDataFolder, '');
            relativeFilePath = strrep(relativeFilePath, ' ', '_');
            uploadFileToBucket(filePath, relativeFilePath, bucketName)
        end
    end
    
    % Return session object (please do not remove):
    % if nargout; varargout = {sessionObject}; end
end


function params = getDefaultParameters()
%getDefaultParameters Get the default parameters for this session method
%
%   params = getDefaultParameters() should return a struct, params, which 
%   contains fields and values for parameters of this session method.
    
    % Add fields to this struct in order to define parameters for this
    % session method:
    params = struct();
end