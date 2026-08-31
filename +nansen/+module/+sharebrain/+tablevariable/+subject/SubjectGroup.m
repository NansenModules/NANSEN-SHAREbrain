classdef SubjectGroup < nansen.metadata.abstract.TableVariable
%SubjectGroup Editable subject table variable with a dynamic dropdown.
%
%   SubjectGroup is an editable table variable for the Subject metadata
%   table. It renders as a dropdown in the NANSEN metatable, where the
%   selectable options (the experimental groups) are stored per project and
%   can be updated on demand.
%
%   The list of options is persisted as a JSON file in the project's custom
%   options folder, so it survives between sessions and can be changed at
%   runtime without editing this class:
%
%       % Inspect / replace the full list of options
%       opts = nansen.module.sharebrain.tablevariable.subject.SubjectGroup.getGroupOptions();
%       nansen.module.sharebrain.tablevariable.subject.SubjectGroup.setGroupOptions(["control","6-OHDA","sham"]);
%
%       % Add or remove a single option
%       nansen.module.sharebrain.tablevariable.subject.SubjectGroup.addGroupOption("stim");
%       nansen.module.sharebrain.tablevariable.subject.SubjectGroup.removeGroupOption("sham");
%
%   Because LIST_ALTERNATIVES is a dependent property, the dropdown reflects
%   the stored options the next time the project's TableVariable attribute
%   table is rebuilt. setGroupOptions/add/remove trigger that rebuild; an
%   already open metatable viewer picks up the change when its columns are
%   next refreshed.
%
%   The class also registers an update function (the static update method),
%   so the value can be set programmatically via the metadata entity, e.g.
%
%       subjectObj.updateDynamicVariable("SubjectGroup")
%
%   The update method derives the group from the subject's genotype and
%   age category. It and the default dropdown options are built from the
%   same vocabulary (GROUP_PREFIX, STRAIN_TOKENS, AGE_TOKENS), so a value
%   set programmatically is always one the dropdown offers.
%
%   See also nansen.metadata.abstract.TableVariable,
%            nansen.module.general.core.tablevariable.subject.Species

    properties (Constant)
        IS_EDITABLE = true
        DEFAULT_VALUE = {'N/A'}
    end

    properties (Dependent)
        % LIST_ALTERNATIVES - Dropdown options, read from the project store.
        %   Dependent rather than Constant so setGroupOptions and its
        %   siblings take effect on the next attribute-table rebuild,
        %   without reloading the class definition. The table machinery
        %   reads this from an instance, so a dependent property works.
        LIST_ALTERNATIVES
    end

    properties (Constant, Access = private)
        % Project configuration subfolder and file name holding the options.
        OPTIONS_SUBFOLDER = "custom_options"
        OPTIONS_FILE_NAME = "subject_group_options.json"

        % Vocabulary this project's groups are built from. update composes
        % its return value from these, and the default dropdown options are
        % every combination of them, so a value set programmatically is
        % always one the dropdown offers.
        GROUP_PREFIX = 'roth2026_SubjectGroup'
        STRAIN_TOKENS = {'WT', 'Scn1a-Wildtype'; 'Scn1a+/-', 'Scn1a-Heterozygous'}
        AGE_TOKENS = {'young_adult', 'Young-adult'; 'juvenile', 'Juvenile'}
    end

    methods
        function obj = SubjectGroup(varargin)
            obj@nansen.metadata.abstract.TableVariable(varargin{:});
        end

        function options = get.LIST_ALTERNATIVES(~)
            options = nansen.module.sharebrain.tablevariable.subject.SubjectGroup.getGroupOptions();
        end
    end

    methods (Static)
        function value = update(subjectObj)
        %update Update function for programmatic value assignment.
        %
        %   value = update() returns the null value. The table variable
        %       machinery calls update with no arguments to determine the
        %       expected data type.
        %
        %   value = update(subjectObj) derives the group from the subject's
        %       genotype and age category, composing the name from the same
        %       vocabulary the default dropdown options are built from. A
        %       subject whose genotype or age category is not one of the
        %       recognised values keeps the null value.

            value = {'N/A'};
            if nargin < 1; return; end

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            strainToken = SubjectGroup.lookupToken( ...
                SubjectGroup.STRAIN_TOKENS, subjectObj.Genotype);
            ageToken = SubjectGroup.lookupToken( ...
                SubjectGroup.AGE_TOKENS, subjectObj.AgeCategory);

            if isempty(strainToken) || isempty(ageToken)
                return
            end

            value = SubjectGroup.composeGroupName(strainToken, ageToken);
        end

        function options = getGroupOptions()
        %getGroupOptions Return the current list of dropdown options.
        %
        %   Returns the default options when none have been stored for the
        %   project, or when no project is available (for example while the
        %   attribute table is being built outside an active user session).

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            defaultOptions = SubjectGroup.getDefaultGroupOptions();
            try
                filePath = SubjectGroup.getOptionsFilePath();
            catch
                options = defaultOptions;
                return
            end

            if ~isfile(filePath)
                options = defaultOptions;
                return
            end

            S = utility.io.loadjson(filePath);
            if ~isfield(S, "Options") || isempty(S.Options)
                options = defaultOptions;
                return
            end

            % Normalize to a row cell array of character vectors. This is
            % robust to jsonencode collapsing a single-element list to a
            % scalar string on a previous save.
            options = reshape(cellstr(string(S.Options)), 1, []);
        end

        function setGroupOptions(options)
        %setGroupOptions Replace the full list of dropdown options.
        %
        %   setGroupOptions(options) persists options (a string array or
        %   cell array of character vectors) for the current project and
        %   refreshes the project's TableVariable attribute table so the new
        %   options are picked up.

            arguments
                options (1,:) string {mustBeNonempty}
            end

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            S.Options = cellstr(options);
            utility.io.savejson(SubjectGroup.getOptionsFilePath(), S);

            SubjectGroup.refreshAttributeTable();
        end

        function addGroupOption(optionName)
        %addGroupOption Add a single option to the dropdown list.
        %
        %   addGroupOption(optionName) appends optionName to the stored
        %   options if it is not already present.

            arguments
                optionName (1,1) string {mustBeNonzeroLengthText}
            end

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            options = string(SubjectGroup.getGroupOptions());
            if ~any(options == optionName)
                SubjectGroup.setGroupOptions([options, optionName]);
            end
        end

        function removeGroupOption(optionName)
        %removeGroupOption Remove a single option from the dropdown list.
        %
        %   removeGroupOption(optionName) removes optionName from the stored
        %   options. If this empties the list, it falls back to the null
        %   value so the dropdown always has at least one option.

            arguments
                optionName (1,1) string {mustBeNonzeroLengthText}
            end

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            options = string(SubjectGroup.getGroupOptions());
            options(options == optionName) = [];
            if isempty(options)
                options = "N/A";
            end
            SubjectGroup.setGroupOptions(options);
        end
    end

    methods (Static, Access = private)
        function options = getDefaultGroupOptions()
        %getDefaultGroupOptions Null value plus every derivable group.
            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            strainTokens = SubjectGroup.STRAIN_TOKENS(:, 2);
            ageTokens = SubjectGroup.AGE_TOKENS(:, 2);

            derived = cell(1, numel(strainTokens) * numel(ageTokens));
            k = 0;
            for i = 1:numel(strainTokens)
                for j = 1:numel(ageTokens)
                    k = k + 1;
                    derived{k} = SubjectGroup.composeGroupName( ...
                        strainTokens{i}, ageTokens{j});
                end
            end

            options = [SubjectGroup.DEFAULT_VALUE, derived];
        end

        function name = composeGroupName(strainToken, ageToken)
        %composeGroupName Assemble a group name from its two tokens.
            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup
            name = sprintf('%s_%s_%s', SubjectGroup.GROUP_PREFIX, ...
                strainToken, ageToken);
        end

        function token = lookupToken(tokenMap, key)
        %lookupToken Token for key, or empty when key is not recognised.
        %   tokenMap is a two-column cell array of subject values in the
        %   first column and the token each contributes in the second.
            token = '';
            if isempty(key); return; end

            isMatch = strcmp(tokenMap(:, 1), key);
            if any(isMatch)
                token = tokenMap{find(isMatch, 1), 2};
            end
        end

        function filePath = getOptionsFilePath()
        %getOptionsFilePath Full path to the options JSON in the project.
        %   Does not create the folder; saving the file creates it on
        %   demand, so reading the options has no filesystem side effects.
            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup
            project = nansen.getCurrentProject();
            folderPath = project.getConfigurationFolder( ...
                "Subfolder", SubjectGroup.OPTIONS_SUBFOLDER, "NoCreate", true);
            filePath = fullfile(folderPath, SubjectGroup.OPTIONS_FILE_NAME);
        end

        function refreshAttributeTable()
        %refreshAttributeTable Rebuild the project's TableVariable table.
        %   Forces re-evaluation of LIST_ALTERNATIVES so a subsequent column
        %   refresh in the metatable viewer shows the updated options.
            try
                project = nansen.getCurrentProject();
                project.getTable('TableVariable', true);
            catch
                % No active project/user session: nothing to refresh.
            end
        end
    end
end
