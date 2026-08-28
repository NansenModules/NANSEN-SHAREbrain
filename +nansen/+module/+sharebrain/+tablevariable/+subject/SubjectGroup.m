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
%   The default update returns the null value. There is no general rule for
%   deriving a subject's group automatically, so plug any project-specific
%   derivation logic into the update method.
%
%   See also nansen.metadata.abstract.TableVariable,
%            nansen.module.general.core.tablevariable.subject.Species

    properties (Constant)
        IS_EDITABLE = true
        DEFAULT_VALUE = {'N/A'}
    end

    properties (Constant)
        % LIST_ALTERNATIVES - Dropdown options, read from the project store.
        %   Dependent (not constant) so the options can change on demand
        %   without reloading the class definition.
        LIST_ALTERNATIVES = {'roth2026_subjectgroup_Scn1a-Heterozygous', 'roth2026_subjectgroup_Scn1a-Wildtype'}
    end

    properties (Constant, Access = private)
        % Project configuration subfolder and file name holding the options.
        OPTIONS_SUBFOLDER = "custom_options"
        OPTIONS_FILE_NAME = "subject_group_options.json"
    end

    methods
        function obj = SubjectGroup(varargin)
            obj@nansen.metadata.abstract.TableVariable(varargin{:});
        end

        % function options = get.LIST_ALTERNATIVES(~)
        %     options = nansen.module.sharebrain.tablevariable.subject.SubjectGroup.getGroupOptions();
        % end
    end

    methods (Static)
        function value = update(subjectObj) %#ok<INUSD>
        %update Update function for programmatic value assignment.
        %
        %   value = update() returns the null value. The table variable
        %       machinery calls update with no arguments to determine the
        %       expected data type.
        %
        %   value = update(subjectObj) returns the value for a single
        %       subject. By default this is the null value, because there is
        %       no general rule for deriving a subject's group. Insert
        %       project-specific derivation logic here if the group can be
        %       computed from the subject (for example a subjectId-to-group
        %       lookup).

            value = {'N/A'};
            if nargin < 1; return; end

            % Insert subject-specific derivation logic here.
            if strcmp(subjectObj.Genotype, 'WT')
                if strcmp(subjectObj.AgeCategory, 'young_adult')
                    value = 'roth2026_SubjectGroup_Scn1a-Wildtype_Young-adult';
                elseif strcmp(subjectObj.AgeCategory, 'juvenile')
                    value = 'roth2026_SubjectGroup_Scn1a-Wildtype_Juvenile';
                end
            elseif strcmp(subjectObj.Genotype, 'Scn1a+/-')
                if strcmp(subjectObj.AgeCategory, 'young_adult')
                    value = 'roth2026_SubjectGroup_Scn1a-Heterozygous_Young-adult';
                elseif strcmp(subjectObj.AgeCategory, 'juvenile')
                    value = 'roth2026_SubjectGroup_Scn1a-Heterozygous_Juvenile';
                end
            end
        end

        function options = getGroupOptions()
        %getGroupOptions Return the current list of dropdown options.
        %
        %   Returns the null value as the only option when no options have
        %   been stored for the project, or when no project is available
        %   (for example while the attribute table is being built outside an
        %   active user session).

            import nansen.module.sharebrain.tablevariable.subject.SubjectGroup

            defaultOptions = {'N/A'};
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
