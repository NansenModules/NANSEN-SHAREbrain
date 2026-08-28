function value = toCamelCase(value)
%toCamelCase - Join a spaced phrase into camel case
%   VALUE = toCamelCase(VALUE) removes the spaces from VALUE and
%   capitalizes the first letter of every word after the first, so that
%   "young adult" becomes "youngAdult". VALUE is returned as a string,
%   and cell input is converted to string first.
%
%   The case of the first character is preserved, so an input that
%   starts with a capital yields UpperCamelCase: "Mus musculus" becomes
%   "MusMusculus".
%
%   See also utility.string.snake2camel

    if iscell(value)
        value = string(value);
    end

    value = strrep(value, ' ', '_');
    value = utility.string.snake2camel(char(value));
    value = string(value);
end
